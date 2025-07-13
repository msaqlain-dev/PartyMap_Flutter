class AppException implements Exception {
  final String message;
  AppException(this.message);
  @override
  String toString() => message;
}

class InternetException extends AppException {
  InternetException(super.message);
}

class RequestTimeOutException extends AppException {
  RequestTimeOutException(super.message);
}

class FetchDataException extends AppException {
  FetchDataException(super.message);
}

class BadRequestException extends AppException {
  BadRequestException(super.message);
}

class UnAuthorizedException extends AppException {
  UnAuthorizedException(super.message);
}

class NotFoundException extends AppException {
  NotFoundException(super.message);
}

class InternalServerException extends AppException {
  InternalServerException(super.message);
}

class ValidationException extends AppException {
  ValidationException(super.message);
}
