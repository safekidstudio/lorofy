import 'package:dio/dio.dart';

class ApiResponse<T> {
  final int status;
  final String message;
  final T? data;
  final int timestamp;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      status: json['status'] as int,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      timestamp: json['timestamp'] as int,
    );
  }
}

extension ResponseUnpacker on Response {
  T unwrap<T>(T Function(Object? json) fromJsonT) {
    final apiResponse = ApiResponse<T>.fromJson(
      data as Map<String, dynamic>,
      fromJsonT,
    );
    return apiResponse.data!;
  }
}
