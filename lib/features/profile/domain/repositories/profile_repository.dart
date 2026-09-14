import 'package:lorofy/features/auth/data/models/user_profile.dart';
import 'package:lorofy/features/profile/domain/models/country_model.dart';
import 'package:lorofy/features/profile/domain/models/point_history_model.dart';

abstract class ProfileRepository {
  Future<({String id, String url})> uploadAvatar(List<int> bytes, String filename);
  Future<List<CountryModel>> getCountries();
  Future<List<PointHistoryModel>> getPointHistory({int page = 0, int size = 20});
  Future<UserProfile> repairStreak({required bool useFreezeItem, required bool useCoins});
}

