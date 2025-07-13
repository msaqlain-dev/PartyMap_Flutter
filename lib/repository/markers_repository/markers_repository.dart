import 'package:partymap_app/data/network/network_api_services.dart';
import 'package:partymap_app/res/app_url/app_url.dart';

class MarkersRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

  Future<dynamic> getMarkers() {
    return _apiService.get(AppUrl.markersApi);
  }
}
