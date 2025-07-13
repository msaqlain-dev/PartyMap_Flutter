import 'package:partymap_app/Screens/dashboard/dashboard_notifier.dart';

class VenueDetails {
  final String? name;
  final String? description;
  final MarkerType? type;
  final String? imageUrl;
  final String? partyIcon;
  final String? placeImage;
  final String? partyImage;
  final double longitude;
  final double latitude;
  final String? website;
  final String? time;
  final List<double>? data;
  final List<String>? times;

  VenueDetails({
    this.name,
    this.description,
    this.type,
    this.imageUrl,
    this.partyIcon,
    this.placeImage,
    this.partyImage,
    this.longitude = 0,
    this.latitude = 0,
    this.website,
    this.time,
    this.data,
    this.times,
  });
}