import 'package:lorofy/features/explore/domain/models/focus_stats.dart';
import 'package:lorofy/features/explore/domain/repositories/explore_repository.dart';
import 'package:lorofy/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:lorofy/features/focus/domain/models/focus_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explore_stats_provider.g.dart';

@riverpod
Future<FocusStats> exploreStats(Ref ref) async {
  final ExploreRepository repository = ref.watch(exploreRepositoryProvider);
  return await repository.getFocusStats();
}

@riverpod
Future<List<FocusSession>> todayActivities(Ref ref) async {
  final ExploreRepository repository = ref.watch(exploreRepositoryProvider);
  return await repository.getTodayActivities();
}
