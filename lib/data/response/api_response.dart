import 'package:partymap_app/data/response/status.dart';

class ApiResponse<T> {
  final Status status;
  final T? data;
  final String? message;

  const ApiResponse._({required this.status, this.data, this.message});

  factory ApiResponse.loading() => const ApiResponse._(status: Status.loading);

  factory ApiResponse.completed(T data) =>
      ApiResponse._(status: Status.completed, data: data);

  factory ApiResponse.error(String message) =>
      ApiResponse._(status: Status.error, message: message);

  @override
  String toString() {
    return 'Status: $status\nMessage: $message\nData: $data';
  }
}
