import 'package:partymap_app/data/network/network_api_services.dart';
import 'package:partymap_app/res/app_url/app_url.dart';

class LoginRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

  Future<dynamic> login(Map<String, dynamic> data) {
    return _apiService.post(AppUrl.loginApi, data: data);
  }
}
