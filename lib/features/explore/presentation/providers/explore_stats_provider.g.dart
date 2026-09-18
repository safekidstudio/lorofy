// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exploreStats)
final exploreStatsProvider = ExploreStatsProvider._();

final class ExploreStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<FocusStats>,
          FocusStats,
          FutureOr<FocusStats>
        >
    with $FutureModifier<FocusStats>, $FutureProvider<FocusStats> {
  ExploreStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreStatsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreStatsHash();

  @$internal
  @override
  $FutureProviderElement<FocusStats> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<FocusStats> create(Ref ref) {
    return exploreStats(ref);
  }
}

String _$exploreStatsHash() => r'37bf43f675d3e0980f0c96184984d1034c905ce6';

@ProviderFor(todayActivities)
final todayActivitiesProvider = TodayActivitiesProvider._();

final class TodayActivitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FocusSession>>,
          List<FocusSession>,
          FutureOr<List<FocusSession>>
        >
    with
        $FutureModifier<List<FocusSession>>,
        $FutureProvider<List<FocusSession>> {
  TodayActivitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayActivitiesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayActivitiesHash();

  @$internal
  @override
  $FutureProviderElement<List<FocusSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FocusSession>> create(Ref ref) {
    return todayActivities(ref);
  }
}

String _$todayActivitiesHash() => r'6c5c7abcfceb1f7daf88b16cececfbda5458c0d2';

@ProviderFor(monthActivities)
final monthActivitiesProvider = MonthActivitiesProvider._();

final class MonthActivitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FocusSession>>,
          List<FocusSession>,
          FutureOr<List<FocusSession>>
        >
    with
        $FutureModifier<List<FocusSession>>,
        $FutureProvider<List<FocusSession>> {
  MonthActivitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthActivitiesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthActivitiesHash();

  @$internal
  @override
  $FutureProviderElement<List<FocusSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FocusSession>> create(Ref ref) {
    return monthActivities(ref);
  }
}

String _$monthActivitiesHash() => r'585cdcebdeea370d56ef2fccaf32069900f26184';
