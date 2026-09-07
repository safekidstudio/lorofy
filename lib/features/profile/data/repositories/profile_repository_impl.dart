import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lorofy/core/errors/exceptions.dart';
import 'package:lorofy/core/network/dio_client.dart';
import 'package:lorofy/features/profile/domain/models/country_model.dart';
import 'package:lorofy/features/profile/domain/repositories/profile_repository.dart';

part 'profile_repository_impl.g.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final Dio _dio;

  ProfileRepositoryImpl(this._dio);

  @override
  Future<({String id, String url})> uploadAvatar(List<int> bytes, String filename) async {
    try {
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
    } catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<CountryModel>> getCountries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_countries');
      
      if (cachedData != null) {
        final decoded = jsonDecode(cachedData) as List<dynamic>;
        
        // Trigger background fetch to refresh cache silently
        _fetchAndCacheCountries(prefs).catchError((_) {});

        return decoded
            .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    try {
      // Fallback to direct network call if cache is empty
      final response = await _dio.get(
        '/profiles/countries',
        options: ApiOptions.protected,
      );
      final data = response.data['data'] as List<dynamic>;

      // Save to cache asynchronously
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('cached_countries', jsonEncode(data));
      }).catchError((_) {});

      return data
          .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toFailure();
    }
  }

  Future<void> _fetchAndCacheCountries(SharedPreferences prefs) async {
    final response = await _dio.get(
      '/profiles/countries',
      options: ApiOptions.protected,
    );
    final data = response.data['data'] as List<dynamic>;
    await prefs.setString('cached_countries', jsonEncode(data));
  }
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  final dio = ref.read(dioProvider);
  return ProfileRepositoryImpl(dio);
}
