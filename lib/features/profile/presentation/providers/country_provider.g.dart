// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(countries)
final countriesProvider = CountriesProvider._();

final class CountriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CountryModel>>,
          List<CountryModel>,
          FutureOr<List<CountryModel>>
        >
    with
        $FutureModifier<List<CountryModel>>,
        $FutureProvider<List<CountryModel>> {
  CountriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'countriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$countriesHash();

  @$internal
  @override
  $FutureProviderElement<List<CountryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CountryModel>> create(Ref ref) {
    return countries(ref);
  }
}

String _$countriesHash() => r'85979e3a03caff63d83e4df79e615f1d2b1e97c3';
