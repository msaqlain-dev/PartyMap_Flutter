import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:partymap_app/data/app_exceptions.dart';
import 'package:partymap_app/data/network/base_api_services.dart';

class NetworkApiServices extends BaseApiServices {
  static const String liveUrl = 'https://anwar.shahfahad.info/';
  static const String localURL = 'http://10.0.2.2:8080/';
  static const String localPhysicalDeviceURL = 'http://192.168.1.102:8080/';

  String _sanitizeUrl(String url) {
    return url.startsWith('/') ? url.substring(1) : url;
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: localURL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
    ),
  );

  @override
  Future get(String url, {Map<String, dynamic>? queryParams}) async {
    try {
      log("GET [$url] => Query Params: $queryParams");
      final response = await _dio.get(_sanitizeUrl(url), queryParameters: queryParams);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future post(String url, {dynamic data}) async {
    try {
      log("POST [$url] => Data: $data");
      final response = await _dio.post(_sanitizeUrl(url), data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future put(String url, {dynamic data}) async {
    try {
      log("PUT [$url] => Data: $data");
      final response = await _dio.put(_sanitizeUrl(url), data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future delete(String url, {Map<String, dynamic>? queryParams}) async {
    try {
      log("DELETE [$url] => Query Params: $queryParams");
      final response = await _dio.delete(_sanitizeUrl(url), queryParameters: queryParams);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  dynamic _handleResponse(Response response) {
    log("Response: ${response.statusCode} - ${response.data}");
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
    log("DioException: $e");
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
