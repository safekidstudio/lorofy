import 'package:lorofy/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:lorofy/features/profile/domain/models/point_history_model.dart';
import 'package:lorofy/features/profile/domain/repositories/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'point_history_provider.g.dart';

@riverpod
Future<List<PointHistoryModel>> pointHistory(Ref ref) async {
  final ProfileRepository repository = ref.watch(profileRepositoryProvider);
  return await repository.getPointHistory(page: 0, size: 50);
}
