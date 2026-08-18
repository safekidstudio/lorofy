import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lorofy/core/network/dio_client.dart';
import 'package:lorofy/features/profile/domain/models/country_model.dart';
import 'package:lorofy/features/profile/domain/repositories/profile_repository.dart';

part 'profile_repository_impl.g.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final Dio _dio;

  ProfileRepositoryImpl(this._dio);

  @override
  Future<({String id, String url})> uploadAvatar(List<int> bytes, String filename) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });

    final response = await _dio.post(
      '/media/upload',
      data: formData,
      options: Options(
        extra: {'requiresAuth': true},
        contentType: 'multipart/form-data',
      ),
    );

    final responseData = response.data;
    if (responseData != null) {
      final dataField = responseData['data'];
      if (dataField != null) {
        return (
          id: dataField['id'] as String,
          url: dataField['url'] as String,
        );
      }
    }
    throw Exception('Failed to upload avatar: invalid response data');
  }

  @override
  Future<List<CountryModel>> getCountries() async {
    final response = await _dio.get(
      '/profiles/countries',
      options: ApiOptions.protected,
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  final dio = ref.read(dioProvider);
  return ProfileRepositoryImpl(dio);
}
