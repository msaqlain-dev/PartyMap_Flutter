import 'package:partymap_app/data/network/network_api_services.dart';
import 'package:partymap_app/res/app_url/app_url.dart';

class SignupRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

  Future<dynamic> register(Map<String, dynamic> data) {
    return _apiService.post(AppUrl.registerApi, data: data);
  }
}
