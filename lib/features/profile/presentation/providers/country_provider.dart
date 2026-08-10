import 'package:lorofy/core/network/dio_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'country_provider.g.dart';

class CountryModel {
  final String code;
  final String name;
  final String? flagUrl;

  const CountryModel({
    required this.code,
    required this.name,
    this.flagUrl,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: json['code'] as String,
      name: json['name'] as String,
      flagUrl: json['flagUrl'] as String?,
    );
  }
}

@Riverpod(keepAlive: true)
Future<List<CountryModel>> countries(Ref ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get(
    '/profiles/countries',
    options: ApiOptions.protected,
  );
  final data = response.data['data'] as List<dynamic>;
  return data
      .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
      .toList();
}
