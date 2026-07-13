import 'package:dio/dio.dart';
import 'api_response.dart'; // Cần để sử dụng extension unwrap gốc

class PageResponse<T> {
  final List<T> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool isLast;

  PageResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.isLast,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final list = json['content'] as List<dynamic>;
    return PageResponse<T>(
      content: list.map((item) => fromJsonT(item)).toList(),
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      isLast: json['isLast'] as bool,
    );
  }
}

extension ResponsePageUnpacker on Response {
  // Hàm unwrapPage tự động unwrap ApiResponse chứa một PageResponse bên trong
  PageResponse<T> unwrapPage<T>(T Function(Object? json) fromJsonT) {
    return unwrap<PageResponse<T>>(
      (json) => PageResponse<T>.fromJson(
        json as Map<String, dynamic>,
        fromJsonT,
      ),
    );
  }
}
