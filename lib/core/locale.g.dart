// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selected language, persisted across launches.
///
/// Falls back to the device language when nothing was chosen yet, then to
/// English for unsupported locales.

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// Selected language, persisted across launches.
///
/// Falls back to the device language when nothing was chosen yet, then to
/// English for unsupported locales.
final class LocaleControllerProvider
    extends $NotifierProvider<LocaleController, AppLocale> {
  /// Selected language, persisted across launches.
  ///
  /// Falls back to the device language when nothing was chosen yet, then to
  /// English for unsupported locales.
  LocaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLocale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLocale>(value),
    );
  }
}

String _$localeControllerHash() => r'd1a663075742aec6a7e2e7d6f4ad359e6a76b73b';

/// Selected language, persisted across launches.
///
/// Falls back to the device language when nothing was chosen yet, then to
/// English for unsupported locales.

abstract class _$LocaleController extends $Notifier<AppLocale> {
  AppLocale build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppLocale, AppLocale>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppLocale, AppLocale>,
              AppLocale,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
