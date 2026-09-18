import 'package:lorofy/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:lorofy/features/explore/domain/repositories/explore_repository.dart';
import 'package:lorofy/features/focus/domain/models/focus_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activities_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<FocusSession>> filteredActivities(
  Ref ref, {
  required String timeframe,
  String? status,
}) async {
  final ExploreRepository repository = ref.watch(exploreRepositoryProvider);

  String? startDate;
  String? endDate;
  final now = DateTime.now();

  if (timeframe == 'TODAY') {
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
      999,
    );
    startDate = todayStart.toUtc().toIso8601String();
    endDate = todayEnd.toUtc().toIso8601String();
  } else if (timeframe == 'WEEK') {
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final weekEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    startDate = weekStart.toUtc().toIso8601String();
    endDate = weekEnd.toUtc().toIso8601String();
  }

  String? statusParam;
  if (status != null && status != 'ALL') {
    statusParam = status;
  }

  return await repository.getFilteredActivities(
    status: statusParam,
    startDate: startDate,
    endDate: endDate,
    page: 0,
    size: 50,
  );
}
