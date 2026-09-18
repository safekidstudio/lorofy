// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activities_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(filteredActivities)
final filteredActivitiesProvider = FilteredActivitiesFamily._();

final class FilteredActivitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FocusSession>>,
          List<FocusSession>,
          FutureOr<List<FocusSession>>
        >
    with
        $FutureModifier<List<FocusSession>>,
        $FutureProvider<List<FocusSession>> {
  FilteredActivitiesProvider._({
    required FilteredActivitiesFamily super.from,
    required ({String timeframe, String? status}) super.argument,
  }) : super(
         retry: null,
         name: r'filteredActivitiesProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredActivitiesHash();

  @override
  String toString() {
    return r'filteredActivitiesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<FocusSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FocusSession>> create(Ref ref) {
    final argument = this.argument as ({String timeframe, String? status});
    return filteredActivities(
      ref,
      timeframe: argument.timeframe,
      status: argument.status,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredActivitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredActivitiesHash() =>
    r'bb98872424b5fd2ad3f6565b888f1e91f5bc4b17';

final class FilteredActivitiesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<FocusSession>>,
          ({String timeframe, String? status})
        > {
  FilteredActivitiesFamily._()
    : super(
        retry: null,
        name: r'filteredActivitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  FilteredActivitiesProvider call({
    required String timeframe,
    String? status,
  }) => FilteredActivitiesProvider._(
    argument: (timeframe: timeframe, status: status),
    from: this,
  );

  @override
  String toString() => r'filteredActivitiesProvider';
}
