abstract class BaseApiServices {
  Future<dynamic> get(String url, {Map<String, dynamic>? queryParams});
  Future<dynamic> post(String url, {dynamic data});
  Future<dynamic> put(String url, {dynamic data});
  Future<dynamic> delete(String url, {Map<String, dynamic>? queryParams});
}
