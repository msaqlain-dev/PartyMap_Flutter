import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:partymap_app/Screens/dashboard/dashboard_notifier.dart';
import 'package:partymap_app/Screens/home/widgets/venue_details.dart';
import 'package:partymap_app/repository/markers_repository/markers_repository.dart';
import 'package:partymap_app/res/assets/image_assets.dart';
import 'package:partymap_app/res/colors/app_color.dart';

final mapControllerProvider =
    StateNotifierProvider<MapControllerNotifier, MapControllerState>(
      (ref) => MapControllerNotifier(ref),
    );

final selectedVenueProvider = StateProvider<VenueDetails?>((ref) => null);

class MapControllerState {
  final MapboxMap? mapboxMap;
  final PointAnnotationManager? pointAnnotationManager;
  final PolygonAnnotationManager? polygonAnnotationManager;
  final Map<String, VenueDetails> annotationDetails;
  final Map<MarkerType, List<Map<String, dynamic>>> points;
  final Map<MarkerType, List<VenueDetails>> details;
  final String mapType;

  MapControllerState({
    this.mapboxMap,
    this.pointAnnotationManager,
    this.polygonAnnotationManager,
    this.annotationDetails = const {},
    this.points = const {
      MarkerType.parties: [],
      MarkerType.bars: [],
      MarkerType.restaurants: [],
    },
    this.details = const {
      MarkerType.parties: [],
      MarkerType.bars: [],
      MarkerType.restaurants: [],
    },
    this.mapType = "Dark",
  });

  MapControllerState copyWith({
    MapboxMap? mapboxMap,
    PointAnnotationManager? pointAnnotationManager,
    PolygonAnnotationManager? polygonAnnotationManager,
    Map<String, VenueDetails>? annotationDetails,
    Map<MarkerType, List<Map<String, dynamic>>>? points,
    Map<MarkerType, List<VenueDetails>>? details,
    String? mapType,
  }) {
    return MapControllerState(
      mapboxMap: mapboxMap ?? this.mapboxMap,
      pointAnnotationManager:
          pointAnnotationManager ?? this.pointAnnotationManager,
      polygonAnnotationManager:
          polygonAnnotationManager ?? this.polygonAnnotationManager,
      annotationDetails: annotationDetails ?? this.annotationDetails,
      points: points ?? this.points,
      details: details ?? this.details,
      mapType: mapType ?? this.mapType,
    );
  }
}

class MapControllerNotifier extends StateNotifier<MapControllerState> {
  final Ref ref;
  final _api = MarkersRepository();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  MapControllerNotifier(this.ref) : super(MapControllerState()) {
    ref.listen(dashboardProvider.select((s) => s.selectedMarkers), (
      prev,
      next,
    ) {
      updateMarkers();
    });
  }

  // Public getter for annotationDetails
  Map<String, VenueDetails> get annotationDetails => state.annotationDetails;

  Future<void> onMapCreated(MapboxMap mapboxMap) async {
    final pointManager = await mapboxMap.annotations
        .createPointAnnotationManager();
    final polygonManager = await mapboxMap.annotations
        .createPolygonAnnotationManager();

    state = state.copyWith(
      mapboxMap: mapboxMap,
      pointAnnotationManager: pointManager,
      polygonAnnotationManager: polygonManager,
    );

    await _addDummyPolygons();
    await updateMarkers();
    _setupPointAnnotationListener();
  }

  void updateMapType(String newType) {
    state = state.copyWith(mapType: newType);
  }

  Future<void> updateMarkers() async {
    final dashboard = ref.read(dashboardProvider);
    final selectedTypes = dashboard.selectedMarkers;
    final ByteData bytes = await rootBundle.load(ImageAssets.markerIconSmall);
    final Uint8List image = bytes.buffer.asUint8List();

    try {
      final response = await _api.getMarkers();
      log("API Response: $response");

      // Clear existing annotations
      await state.pointAnnotationManager?.deleteAll();
      final Map<String, VenueDetails> annotationsMap = {};
      final Map<MarkerType, List<Map<String, dynamic>>> points = {
        MarkerType.parties: [],
        MarkerType.bars: [],
        MarkerType.restaurants: [],
      };
      final Map<MarkerType, List<VenueDetails>> details = {
        MarkerType.parties: [],
        MarkerType.bars: [],
        MarkerType.restaurants: [],
      };

      double avgLat = 0, avgLng = 0;
      int count = 0;

      // Process API response
      for (final marker in response) {
        final type = _getTypeFromString(marker['markerType']);
        if (selectedTypes.isNotEmpty && !selectedTypes.contains(type)) continue;

        final lat = double.parse(marker['latitude']);
        final lng = double.parse(marker['longitude']);
        final detail = VenueDetails(
          name: marker['placeName'],
          description: marker['partyDescription'],
          type: type,
          website: marker['website'],
          time: marker['partyTime'],
          partyIcon: marker['partyIcon'],
          placeImage: marker['placeImage'],
          partyImage: marker['partyImage'],
          latitude: lat,
          longitude: lng,
          data: (marker['tickets'] as List<dynamic>)
              .map<double>(
                (ticket) =>
                    (ticket['availableTickets'] as num?)?.toDouble() ?? 0.0,
              )
              .toList(),
          times: (marker['tickets'] as List<dynamic>)
              .map<String>((ticket) => ticket['hour'] ?? '')
              .toList(),
        );

        points[type]!.add({
          'type': 'Point',
          'coordinates': [lng, lat],
        });
        details[type]!.add(detail);

        final annotation = await state.pointAnnotationManager?.create(
          PointAnnotationOptions(
            geometry: Point(coordinates: Position(lng, lat)),
            image: image,
            textField: detail.name,
            textSize: 14,
            textColor: AppColor.whiteColor.value,
            textHaloColor:
                AppColor.primaryColor.value, // Use Color object directly
            textHaloWidth: 5.0,
            textHaloBlur: 5.0,
            textOffset: [0.0, 1.5],
          ),
        );

        if (annotation != null) {
          annotationsMap[annotation.id] = detail;
        }

        avgLat += lat;
        avgLng += lng;
        count++;
      }

      state = state.copyWith(
        annotationDetails: annotationsMap,
        points: points,
        details: details,
      );

      if (count > 0) {
        avgLat /= count;
        avgLng /= count;
        await updateCamera(avgLat, avgLng, 16);
        if (kDebugMode) {
          print(
            '<=====================Latitude: $avgLat , Longitude: $avgLng =====================>',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print("Marker Update Error: $e");
    }
  }

  Future<void> updateCamera(double lat, double lng, double zoom) async {
    final camera = CameraOptions(
      center: Point(coordinates: Position(lng, lat)),
      zoom: zoom,
      pitch: 75.0, // Set to 0 to avoid shader issues
    );
    final animation = MapAnimationOptions(duration: 1000);
    await state.mapboxMap?.flyTo(camera, animation);
  }

  MarkerType _getTypeFromString(String value) {
    switch (value.toLowerCase()) {
      case 'party':
        return MarkerType.parties;
      case 'bar':
        return MarkerType.bars;
      case 'restaurant':
        return MarkerType.restaurants;
      default:
        return MarkerType.parties;
    }
  }

  Future<void> _addDummyPolygons() async {
    if (state.polygonAnnotationManager == null) return;

    final dummyPolygons = [
      {
        "coordinates": [
          [
            Position(-115.1249, 36.1288),
            Position(-115.1259, 36.1288),
            Position(-115.1259, 36.1278),
            Position(-115.1249, 36.1278),
            Position(-115.1249, 36.1288),
          ],
        ],
        "fillColor": Colors.blue, // Use Color object
        "fillOpacity": 0.5,
        "fillOutlineColor": Colors.black, // Use Color object
      },
      {
        "coordinates": [
          [
            Position(-115.1239, 36.1298),
            Position(-115.1249, 36.1298),
            Position(-115.1249, 36.1288),
            Position(-115.1239, 36.1288),
            Position(-115.1239, 36.1298),
          ],
        ],
        "fillColor": Colors.green, // Use Color object
        "fillOpacity": 0.3,
        "fillOutlineColor": Colors.red, // Use Color object
      },
    ];

    for (final polygonData in dummyPolygons) {
      final geometry = Polygon(
        coordinates: polygonData["coordinates"] as List<List<Position>>,
      );
      final options = PolygonAnnotationOptions(
        geometry: geometry,
        fillColor: (polygonData["fillColor"] as Color).value, // Convert to int
        fillOpacity: polygonData["fillOpacity"] as double,
        fillOutlineColor:
            (polygonData["fillOutlineColor"] as Color).value, // Convert to int
      );
      try {
        await state.polygonAnnotationManager?.create(options);
      } catch (e) {
        if (kDebugMode) print("Polygon Error: $e");
      }
    }
  }

  void _setupPointAnnotationListener() {
    state.pointAnnotationManager?.addOnPointAnnotationClickListener(
      MyAnnotationClickListener(this),
    );
  }

  void selectVenue(VenueDetails details) {
    ref.read(selectedVenueProvider.notifier).state = details;
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }
}

class MyAnnotationClickListener implements OnPointAnnotationClickListener {
  final MapControllerNotifier controller;

  MyAnnotationClickListener(this.controller);

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    final details = controller.annotationDetails[annotation.id];
    if (details == null) {
      log("No details found for annotation ID: ${annotation.id}");
      return;
    }

    log("Clicked on annotation: ${details.name}");

    if (details.type == MarkerType.parties) {
      controller.selectVenue(details);
    } else {
      if (kDebugMode) {
        print("Clicked on a non-party marker: ${details.name}");
      }
    }
  }
}
