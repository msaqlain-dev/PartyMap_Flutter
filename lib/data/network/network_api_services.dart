import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:partymap_app/data/app_exceptions.dart';
import 'package:partymap_app/data/network/base_api_services.dart';

class NetworkApiServices extends BaseApiServices {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://your-api-base-url.com", // Replace with your base URL
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
    ),
  );

  @override
  Future get(String url, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParams);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future post(String url, {dynamic data}) async {
    try {
      log("POST [$url] => Data: $data");
      final response = await _dio.post(url, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future put(String url, {dynamic data}) async {
    try {
      log("PUT [$url] => Data: $data");
      final response = await _dio.put(url, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future delete(String url, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.delete(url, queryParameters: queryParams);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  dynamic _handleResponse(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        return response.data;
      case 400:
        throw BadRequestException(response.data.toString());
      case 401:
        throw UnAuthorizedException(response.data.toString());
      case 403:
        throw UnAuthorizedException("Access Denied");
      case 404:
        throw NotFoundException("Not Found");
      case 422:
        throw ValidationException(response.data.toString());
      case 500:
        throw InternalServerException("Internal Server Error");
      default:
        throw FetchDataException(
          'Unexpected error: ${response.statusCode} - ${response.statusMessage}',
        );
    }
  }

  Never _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw RequestTimeOutException("Request timeout");
    } else if (e.type == DioExceptionType.unknown &&
        e.error is SocketException) {
      throw InternetException("No internet connection");
    } else if (e.response != null) {
      throw FetchDataException(
        'Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}',
      );
    } else {
      throw FetchDataException("Unexpected error: ${e.message}");
    }
  }
}
