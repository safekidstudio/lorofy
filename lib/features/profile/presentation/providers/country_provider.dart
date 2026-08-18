import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lorofy/features/profile/domain/models/country_model.dart';
import 'package:lorofy/features/profile/data/repositories/profile_repository_impl.dart';

part 'country_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<CountryModel>> countries(Ref ref) async {
  return await ref.read(profileRepositoryProvider).getCountries();
}
