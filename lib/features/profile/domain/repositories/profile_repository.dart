import 'package:lorofy/features/profile/domain/models/country_model.dart';

abstract class ProfileRepository {
  Future<({String id, String url})> uploadAvatar(List<int> bytes, String filename);
  Future<List<CountryModel>> getCountries();
}
