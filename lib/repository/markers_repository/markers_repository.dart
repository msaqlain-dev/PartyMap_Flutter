import 'package:partymap_app/data/network/network_api_services.dart';
import 'package:partymap_app/res/app_url/app_url.dart';

class MarkersRepository {
  final NetworkApiServices _apiService = NetworkApiServices.instance;

  Future<dynamic> getMarkers() {
    return _apiService.get(AppUrl.markersApi);
  }

  Future<dynamic> getPolygons({String? type, bool visible = true}) {
    final queryParams = <String, dynamic>{'visible': visible.toString()};

    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }

    return _apiService.get(AppUrl.polygonsApi, queryParams: queryParams);
  }
}
