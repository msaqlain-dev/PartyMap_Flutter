import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:partymap_app/data/app_exceptions.dart';
import 'package:partymap_app/data/network/base_api_services.dart';

class NetworkApiServices extends BaseApiServices {
  // static const String liveUrl = 'https://anwar.shahfahad.info/';
  static const String liveUrl = 'https://party-map-backend.vercel.app/';
  static const String localURL = 'http://10.0.2.2:8080/';
  static const String localPhysicalDeviceURL = 'http://192.168.0.102:8080/';

  // Singleton pattern for better resource management
  static NetworkApiServices? _instance;
  static NetworkApiServices get instance =>
      _instance ??= NetworkApiServices._internal();

  NetworkApiServices._internal();

  String _sanitizeUrl(String url) {
    return url.startsWith('/') ? url.substring(1) : url;
  }

  late final Dio _dio;

  // Initialize Dio with optimized settings
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: liveUrl,
        connectTimeout: const Duration(seconds: 15), // Increased timeout
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.acceptHeader: "application/json",
        },
        // Enable response compression
        responseType: ResponseType.json,
        followRedirects: true,
        maxRedirects: 3,
      ),
    );

    // Add interceptors for better debugging and performance
    // if (log.level <= Level.INFO) {
    //   _dio.interceptors.add(
    //     LogInterceptor(
    //       requestBody: true,
    //       responseBody: true,
    //       requestHeader: false,
    //       responseHeader: false,
    //       error: true,
    //     ),
    //   );
    // }

    // Add retry interceptor for failed requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            try {
              final response = await _retry(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final retryDio = Dio();
    retryDio.options = requestOptions.copyWith() as BaseOptions;

    return retryDio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }

  // Initialize on first use
  Dio get dio {
    if (!_isInitialized) {
      _initializeDio();
      _isInitialized = true;
    }
    return _dio;
  }

  bool _isInitialized = false;

  @override
  Future get(String url, {Map<String, dynamic>? queryParams}) async {
    try {
      log("GET [$url] => Query Params: $queryParams");

      // Use a shorter timeout for GET requests to markers API
      final options = url.contains('markers')
          ? Options(receiveTimeout: const Duration(seconds: 10))
          : null;

      final response = await dio.get(
        _sanitizeUrl(url),
        queryParameters: queryParams,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw FetchDataException("Unexpected error: $e");
    }
  }

  @override
  Future post(String url, {dynamic data}) async {
    try {
      log("POST [$url] => Data: ${data != null ? 'Data present' : 'No data'}");
      final response = await dio.post(_sanitizeUrl(url), data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw FetchDataException("Unexpected error: $e");
    }
  }

  @override
  Future put(String url, {dynamic data}) async {
    try {
      log("PUT [$url] => Data: ${data != null ? 'Data present' : 'No data'}");
      final response = await dio.put(_sanitizeUrl(url), data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw FetchDataException("Unexpected error: $e");
    }
  }

  @override
  Future delete(String url, {Map<String, dynamic>? queryParams}) async {
    try {
      log("DELETE [$url] => Query Params: $queryParams");
      final response = await dio.delete(
        _sanitizeUrl(url),
        queryParameters: queryParams,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw FetchDataException("Unexpected error: $e");
    }
  }

  dynamic _handleResponse(Response response) {
    log("Response: ${response.statusCode} - Success");

    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        return response.data;
      case 400:
        throw BadRequestException(response.data?.toString() ?? "Bad Request");
      case 401:
        throw UnAuthorizedException(
          response.data?.toString() ?? "Unauthorized",
        );
      case 403:
        throw UnAuthorizedException("Access Denied");
      case 404:
        throw NotFoundException("Resource Not Found");
      case 422:
        throw ValidationException(
          response.data?.toString() ?? "Validation Error",
        );
      case 500:
        throw InternalServerException("Internal Server Error");
      default:
        throw FetchDataException(
          'Unexpected error: ${response.statusCode} - ${response.statusMessage}',
        );
    }
  }

  Never _handleDioError(DioException e) {
    log("DioException: ${e.type} - ${e.message}");

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw RequestTimeOutException(
          "Request timeout. Please check your connection.",
        );

      case DioExceptionType.badResponse:
        if (e.response != null) {
          throw FetchDataException(
            'Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}',
          );
        }
        throw FetchDataException("Bad response from server");

      case DioExceptionType.cancel:
        throw FetchDataException("Request was cancelled");

      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          throw InternetException(
            "No internet connection. Please check your network.",
          );
        } else if (e.error is TimeoutException) {
          throw RequestTimeOutException("Request timeout. Please try again.");
        }
        throw FetchDataException("Network error: ${e.message}");

      default:
        throw FetchDataException("Unexpected error: ${e.message}");
    }
  }

  // Method to check network connectivity
  Future<bool> checkConnectivity() async {
    try {
      final response = await dio.get(
        'https://www.google.com',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Cancel all pending requests
  void cancelRequests([String? reason]) {
    dio.close(force: true);
    _isInitialized = false;
  }
}

// import 'dart:developer';
// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:partymap_app/data/app_exceptions.dart';
// import 'package:partymap_app/data/network/base_api_services.dart';

// class NetworkApiServices extends BaseApiServices {
//   static const String liveUrl = 'https://anwar.shahfahad.info/';
//   static const String localURL = 'http://10.0.2.2:8080/';
//   static const String localPhysicalDeviceURL = 'http://192.168.0.102:8080/';

//   String _sanitizeUrl(String url) {
//     return url.startsWith('/') ? url.substring(1) : url;
//   }

//   final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: localURL,
//       connectTimeout: Duration(seconds: 10),
//       receiveTimeout: Duration(seconds: 10),
//       headers: {HttpHeaders.contentTypeHeader: "application/json"},
//     ),
//   );

//   @override
//   Future get(String url, {Map<String, dynamic>? queryParams}) async {
//     try {
//       log("GET [$url] => Query Params: $queryParams");
//       final response = await _dio.get(_sanitizeUrl(url), queryParameters: queryParams);
//       return _handleResponse(response);
//     } on DioException catch (e) {
//       _handleDioError(e);
//     }
//   }

//   @override
//   Future post(String url, {dynamic data}) async {
//     try {
//       log("POST [$url] => Data: $data");
//       final response = await _dio.post(_sanitizeUrl(url), data: data);
//       return _handleResponse(response);
//     } on DioException catch (e) {
//       _handleDioError(e);
//     }
//   }

//   @override
//   Future put(String url, {dynamic data}) async {
//     try {
//       log("PUT [$url] => Data: $data");
//       final response = await _dio.put(_sanitizeUrl(url), data: data);
//       return _handleResponse(response);
//     } on DioException catch (e) {
//       _handleDioError(e);
//     }
//   }

//   @override
//   Future delete(String url, {Map<String, dynamic>? queryParams}) async {
//     try {
//       log("DELETE [$url] => Query Params: $queryParams");
//       final response = await _dio.delete(_sanitizeUrl(url), queryParameters: queryParams);
//       return _handleResponse(response);
//     } on DioException catch (e) {
//       _handleDioError(e);
//     }
//   }

//   dynamic _handleResponse(Response response) {
//     log("Response: ${response.statusCode} - ${response.data}");
//     switch (response.statusCode) {
//       case 200:
//       case 201:
//       case 204:
//         return response.data;
//       case 400:
//         throw BadRequestException(response.data.toString());
//       case 401:
//         throw UnAuthorizedException(response.data.toString());
//       case 403:
//         throw UnAuthorizedException("Access Denied");
//       case 404:
//         throw NotFoundException("Not Found");
//       case 422:
//         throw ValidationException(response.data.toString());
//       case 500:
//         throw InternalServerException("Internal Server Error");
//       default:
//         throw FetchDataException(
//           'Unexpected error: ${response.statusCode} - ${response.statusMessage}',
//         );
//     }
//   }

//   Never _handleDioError(DioException e) {
//     log("DioException: $e");
//     if (e.type == DioExceptionType.connectionTimeout ||
//         e.type == DioExceptionType.sendTimeout ||
//         e.type == DioExceptionType.receiveTimeout) {
//       throw RequestTimeOutException("Request timeout");
//     } else if (e.type == DioExceptionType.unknown &&
//         e.error is SocketException) {
//       throw InternetException("No internet connection");
//     } else if (e.response != null) {
//       throw FetchDataException(
//         'Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}',
//       );
//     } else {
//       throw FetchDataException("Unexpected error: ${e.message}");
//     }
//   }
// }
