import 'package:lorofy/features/auth/data/models/user_profile.dart';
import 'package:lorofy/features/profile/domain/repositories/profile_repository.dart';

class RepairStreakUseCase {
  final ProfileRepository repository;

  RepairStreakUseCase(this.repository);

  Future<UserProfile> call({required bool useFreezeItem, required bool useCoins}) {
    return repository.repairStreak(useFreezeItem: useFreezeItem, useCoins: useCoins);
  }
}
