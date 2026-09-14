import 'package:lorofy/features/profile/domain/models/point_history_model.dart';
import 'package:lorofy/features/profile/domain/repositories/profile_repository.dart';

class GetPointHistoryUseCase {
  final ProfileRepository repository;

  GetPointHistoryUseCase(this.repository);

  Future<List<PointHistoryModel>> call({int page = 0, int size = 20}) {
    return repository.getPointHistory(page: page, size: size);
  }
}
