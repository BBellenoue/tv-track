const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");

const tmdbApiKey = defineSecret("TMDB_API_KEY");
const tvdbApiKey = defineSecret("TVDB_API_KEY");

initializeApp();

const upstreams = {
  tmdb: {
    base: "https://api.themoviedb.org/3",
    authorize: (url) => url.searchParams.set("api_key", tmdbApiKey.value()),
  },
  tvdb: {
    base: "https://api4.thetvdb.com/v4",
    authorize: async (url, headers) => {
      headers.authorization = `Bearer ${await tvdbBearer()}`;
    },
  },
};

// Cached well inside TheTVDB's own expiry, so a warm instance logs in once and
// a cold one logs in again. Concurrent callers share the in-flight login.
let tvdbToken = null;
let tvdbTokenExpiry = 0;
let tvdbLogin = null;

async function tvdbBearer() {
  if (tvdbToken && Date.now() < tvdbTokenExpiry) return tvdbToken;
  tvdbLogin ??= login().finally(() => {
    tvdbLogin = null;
  });
  return tvdbLogin;
}

async function login() {
  const r = await fetch(`${upstreams.tvdb.base}/login`, {
    method: "POST",
    headers: {"content-type": "application/json"},
    body: JSON.stringify({apikey: tvdbApiKey.value()}),
  });
  if (!r.ok) throw new Error(`TheTVDB login failed: ${r.status}`);
  const body = await r.json();
  const token = body.data && body.data.token;
  if (!token) throw new Error("TheTVDB login returned no token");
  tvdbToken = token;
  tvdbTokenExpiry = Date.now() + 24 * 60 * 60 * 1000;
  return token;
}

async function isSignedIn(req) {
  const header = req.get("authorization") || "";
  if (!header.startsWith("Bearer ")) return false;
  try {
    await getAuth().verifyIdToken(header.slice(7));
    return true;
  } catch (_) {
    return false;
  }
}

// Read-only proxy for the metadata providers: it holds the API keys so the
// APK never carries them, and answers only signed-in callers.
exports.metadata = onRequest(
    {
      region: "europe-west1",
      secrets: [tmdbApiKey, tvdbApiKey],
      maxInstances: 10,
      timeoutSeconds: 30,
    },
    async (req, res) => {
      if (req.method !== "GET") {
        res.status(405).json({error: "Only GET is proxied"});
        return;
      }
      if (!(await isSignedIn(req))) {
        res.status(401).json({error: "Sign-in required"});
        return;
      }

      const segments = req.path.split("/").filter((s) => s.length > 0);
      const upstream = upstreams[segments.shift()];
      if (!upstream || segments.some((s) => s === "..")) {
        res.status(404).json({error: "Unknown provider"});
        return;
      }

      const url = new URL(`${upstream.base}/${segments.join("/")}`);
      for (const [key, value] of Object.entries(req.query)) {
        url.searchParams.set(key, String(value));
      }

      const headers = {accept: "application/json"};
      for (const name of ["if-none-match", "if-modified-since"]) {
        const value = req.get(name);
        if (value) headers[name] = value;
      }
      await upstream.authorize(url, headers);

      try {
        const response = await fetch(url, {headers});
        for (const name of ["etag", "last-modified"]) {
          const value = response.headers.get(name);
          if (value) res.set(name, value);
        }
        // Never "public": the payload is public metadata but the route is
        // gated, so only the caller's own cache may keep a copy.
        res.set("cache-control", "private, no-cache");
        if (response.status === 304) {
          res.status(304).end();
          return;
        }
        res
            .status(response.status)
            .type(response.headers.get("content-type") || "application/json")
            .send(await response.text());
      } catch (e) {
        res.status(502).json({error: "Upstream unreachable"});
      }
    },
);
