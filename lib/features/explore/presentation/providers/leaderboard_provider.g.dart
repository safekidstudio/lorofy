// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(leaderboard)
final leaderboardProvider = LeaderboardFamily._();

final class LeaderboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<Leaderboard>,
          Leaderboard,
          FutureOr<Leaderboard>
        >
    with $FutureModifier<Leaderboard>, $FutureProvider<Leaderboard> {
  LeaderboardProvider._({
    required LeaderboardFamily super.from,
    required ({String timeframe, String? countryCode}) super.argument,
  }) : super(
         retry: null,
         name: r'leaderboardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leaderboardHash();

  @override
  String toString() {
    return r'leaderboardProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Leaderboard> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Leaderboard> create(Ref ref) {
    final argument = this.argument as ({String timeframe, String? countryCode});
    return leaderboard(
      ref,
      timeframe: argument.timeframe,
      countryCode: argument.countryCode,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LeaderboardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leaderboardHash() => r'15513ec1f9184ac926c5051314e1455f1e3af6e0';

final class LeaderboardFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Leaderboard>,
          ({String timeframe, String? countryCode})
        > {
  LeaderboardFamily._()
    : super(
        retry: null,
        name: r'leaderboardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LeaderboardProvider call({required String timeframe, String? countryCode}) =>
      LeaderboardProvider._(
        argument: (timeframe: timeframe, countryCode: countryCode),
        from: this,
      );

  @override
  String toString() => r'leaderboardProvider';
}

@ProviderFor(leaderboardRealtimeStream)
final leaderboardRealtimeStreamProvider = LeaderboardRealtimeStreamProvider._();

final class LeaderboardRealtimeStreamProvider
    extends
        $FunctionalProvider<AsyncValue<FomoEvent>, FomoEvent, Stream<FomoEvent>>
    with $FutureModifier<FomoEvent>, $StreamProvider<FomoEvent> {
  LeaderboardRealtimeStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaderboardRealtimeStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaderboardRealtimeStreamHash();

  @$internal
  @override
  $StreamProviderElement<FomoEvent> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<FomoEvent> create(Ref ref) {
    return leaderboardRealtimeStream(ref);
  }
}

String _$leaderboardRealtimeStreamHash() =>
    r'2bda4814f67d110a728c47458ee17cd2df7b378e';
