class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([super.message = "Can't connect to the server"]);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = "Session expired"]);
}

class ServerException extends AppException {
  ServerException([super.message = "Server error"]);
}

class BadRequestException extends AppException {
  BadRequestException([super.message = "Bad request"]);
}
