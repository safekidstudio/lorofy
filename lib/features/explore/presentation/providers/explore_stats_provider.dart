import 'package:lorofy/features/explore/domain/models/focus_stats.dart';
import 'package:lorofy/features/explore/domain/repositories/explore_repository.dart';
import 'package:lorofy/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:lorofy/features/focus/domain/models/focus_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explore_stats_provider.g.dart';

@Riverpod(keepAlive: true)
Future<FocusStats> exploreStats(Ref ref) async {
  final ExploreRepository repository = ref.watch(exploreRepositoryProvider);
  return await repository.getFocusStats();
}

@Riverpod(keepAlive: true)
Future<List<FocusSession>> todayActivities(Ref ref) async {
  final ExploreRepository repository = ref.watch(exploreRepositoryProvider);
  return await repository.getTodayActivities();
}

@Riverpod(keepAlive: true)
Future<List<FocusSession>> monthActivities(Ref ref) async {
  final ExploreRepository repository = ref.watch(exploreRepositoryProvider);
  return await repository.getMonthActivities();
}
