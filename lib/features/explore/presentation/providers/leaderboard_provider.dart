import 'dart:async';
import 'package:lorofy/features/explore/domain/models/leaderboard.dart';
import 'package:lorofy/features/explore/domain/repositories/explore_repository.dart';
import 'package:lorofy/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'leaderboard_provider.g.dart';

@riverpod
Future<Leaderboard> leaderboard(
  Ref ref, {
  required String timeframe,
  String? countryCode,
}) async {
  final ExploreRepository repository = ref.watch(exploreRepositoryProvider);
  return await repository.getLeaderboard(
    timeframe: timeframe,
    countryCode: countryCode,
  );
}

@riverpod
Stream<FomoEvent> leaderboardRealtimeStream(Ref ref) {
  final ExploreRepository repository = ref.watch(exploreRepositoryProvider);
  final stream = repository.getLeaderboardUpdateStream();

  Timer? debounceTimer;

  final subscription = stream.listen((event) {
    // Debounce the invalidation of leaderboard REST queries by 3 seconds
    debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(seconds: 3), () {
      ref.invalidate(leaderboardProvider);
    });
  });

  ref.onDispose(() {
    subscription.cancel();
    debounceTimer?.cancel();
  });

  return stream;
}
