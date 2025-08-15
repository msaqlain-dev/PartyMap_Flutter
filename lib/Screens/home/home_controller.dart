import 'dart:async';
import 'dart:convert';
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
  final Map<String, VenueDetails> annotationDetails;
  final Map<MarkerType, List<Map<String, dynamic>>> points;
  final Map<MarkerType, List<VenueDetails>> details;
  final String mapType;
  final bool isLoading;
  final bool isLoadingPolygons;
  final int polygonCount;
  final GeoJsonSource? polygonSource;

  MapControllerState({
    this.mapboxMap,
    this.pointAnnotationManager,
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
    this.isLoading = false,
    this.isLoadingPolygons = false,
    this.polygonCount = 0,
    this.polygonSource,
  });

  MapControllerState copyWith({
    MapboxMap? mapboxMap,
    PointAnnotationManager? pointAnnotationManager,
    Map<String, VenueDetails>? annotationDetails,
    Map<MarkerType, List<Map<String, dynamic>>>? points,
    Map<MarkerType, List<VenueDetails>>? details,
    String? mapType,
    bool? isLoading,
    bool? isLoadingPolygons,
    int? polygonCount,
    GeoJsonSource? polygonSource,
  }) {
    return MapControllerState(
      mapboxMap: mapboxMap ?? this.mapboxMap,
      pointAnnotationManager:
          pointAnnotationManager ?? this.pointAnnotationManager,
      annotationDetails: annotationDetails ?? this.annotationDetails,
      points: points ?? this.points,
      details: details ?? this.details,
      mapType: mapType ?? this.mapType,
      isLoading: isLoading ?? this.isLoading,
      isLoadingPolygons: isLoadingPolygons ?? this.isLoadingPolygons,
      polygonCount: polygonCount ?? this.polygonCount,
      polygonSource: polygonSource ?? this.polygonSource,
    );
  }
}

class MapControllerNotifier extends StateNotifier<MapControllerState> {
  final Ref ref;
  final _api = MarkersRepository();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  // Cache for marker icon
  static Uint8List? _cachedMarkerIcon;

  // Debounce timer for API calls
  Timer? _debounceTimer;
  Timer? _polygonDebounceTimer;

  MapControllerNotifier(this.ref) : super(MapControllerState()) {
    // Listen to dashboard changes with debouncing
    ref.listen(dashboardProvider.select((s) => s.selectedMarkers), (
      prev,
      next,
    ) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        updateMarkers();
      });
    });
  }

  Map<String, VenueDetails> get annotationDetails => state.annotationDetails;

  Future<void> onMapCreated(MapboxMap mapboxMap) async {
    try {
      final pointManager = await mapboxMap.annotations
          .createPointAnnotationManager();

      state = state.copyWith(
        mapboxMap: mapboxMap,
        pointAnnotationManager: pointManager,
      );

      // Load both markers and polygons concurrently
      await Future.wait([
        updateMarkers(),
        loadPolygonsFromBackend(), // Load from backend instead of dummy
      ]);
      
      _setupPointAnnotationListener();
    } catch (e) {
      if (kDebugMode) print("Map creation error: $e");
    }
  }

  void updateMapType(String newType) {
    state = state.copyWith(mapType: newType);
  }

  // Optimized marker icon loading with caching
  Future<Uint8List> _loadMarkerIcon() async {
    if (_cachedMarkerIcon != null) return _cachedMarkerIcon!;

    try {
      final ByteData bytes = await rootBundle.load(ImageAssets.markerIconSmall);
      _cachedMarkerIcon = bytes.buffer.asUint8List();
      return _cachedMarkerIcon!;
    } catch (e) {
      if (kDebugMode) print("Error loading marker icon: $e");
      rethrow;
    }
  }

  // Helper function to convert hex color to ARGB int
  int _hexToArgb(String hexColor) {
    try {
      // Remove # if present
      String hex = hexColor.replaceAll('#', '');
      
      // Add alpha if not present (assume full opacity)
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      
      // Convert to int
      return int.parse(hex, radix: 16);
    } catch (e) {
      if (kDebugMode) print("Error converting hex color $hexColor: $e");
      return 0xFF0000FF; // Default to blue
    }
  }

  // Helper function to process polygon data and convert colors
  Map<String, dynamic> _processPolygonFeature(Map<String, dynamic> feature) {
    try {
      final properties = Map<String, dynamic>.from(feature['properties'] ?? {});
      
      // Convert hex color to ARGB format for Mapbox
      if (properties['color'] is String) {
        final hexColor = properties['color'] as String;
        final argbColor = _hexToArgb(hexColor);
        properties['color'] = argbColor.toRGBA();
      }
      
      // Ensure height is a number
      if (properties['height'] is String) {
        properties['height'] = double.tryParse(properties['height']) ?? 50.0;
      }
      
      return {
        ...feature,
        'properties': properties,
      };
    } catch (e) {
      if (kDebugMode) print("Error processing polygon feature: $e");
      return feature;
    }
  }

  // Load polygons from your backend API with color conversion
  Future<void> loadPolygonsFromBackend({String? type}) async {
    if (state.isLoadingPolygons) return;

    state = state.copyWith(isLoadingPolygons: true);

    try {
      if (kDebugMode) print("Loading polygons from backend...");
      
      // Fetch from your backend
      final response = await _api.getPolygons(type: type, visible: true);
      
      if (response != null) {
        if (kDebugMode) print("Received polygons data: ${response['features']?.length ?? 0} polygons");
        
        // Clear existing polygons
        await _clearPolygons();
        
        // Process features and convert colors to RGBA format
        final features = (response['features'] as List<dynamic>? ?? [])
            .map((feature) => _processPolygonFeature(Map<String, dynamic>.from(feature)))
            .toList();
        
        final processedResponse = {
          'type': 'FeatureCollection',
          'features': features,
        };
        
        // Process the GeoJSON response from backend
        final geoJsonData = jsonEncode(processedResponse);
        
        if (kDebugMode) print("Processed GeoJSON data: $geoJsonData");
        
        // Create and add source
        final polygonSource = GeoJsonSource(id: 'polygon-source', data: geoJsonData);
        await state.mapboxMap?.style.addSource(polygonSource);
        
        if (kDebugMode) print("GeoJSON source added from backend");

        // Add FillExtrusionLayer with proper styling
        final fillExtrusionLayer = FillExtrusionLayer(
          id: 'extrusion-layer',
          sourceId: 'polygon-source',
          fillExtrusionColor: 0xFF0000FF, // Default blue color in RGBA format
          fillExtrusionColorExpression: ["get", "color"], // Get color from properties
          fillExtrusionHeight: 50.0, // Default height
          fillExtrusionHeightExpression: ["get", "height"], // Get height from properties
          fillExtrusionOpacity: 0.8,
          fillExtrusionVerticalGradient: true,
          slot: 'top',
        );

        await state.mapboxMap?.style.addLayer(fillExtrusionLayer);
        
        final polygonCount = features.length;
        
        state = state.copyWith(
          polygonSource: polygonSource,
          polygonCount: polygonCount,
        );
        
        if (kDebugMode) print("FillExtrusionLayer added with $polygonCount polygons from backend");
      } else {
        if (kDebugMode) print("No polygon data received from backend");
      }
    } catch (e) {
      if (kDebugMode) print("Failed to load polygons from backend: $e");
    } finally {
      state = state.copyWith(isLoadingPolygons: false);
    }
  }

  // Method to refresh polygons from backend
  Future<void> refreshPolygons({String? type}) async {
    _polygonDebounceTimer?.cancel();
    _polygonDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      loadPolygonsFromBackend(type: type);
    });
  }

  // Fixed dummy polygons with correct color format
  Future<void> _addDummyPolygons() async {
    try {
      final geoJsonData = jsonEncode({
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Polygon',
              'coordinates': [
                [
                  [-115.1710, 36.1120],
                  [-115.1705, 36.1120],
                  [-115.1705, 36.1115],
                  [-115.1700, 36.1115],
                  [-115.1700, 36.1110],
                  [-115.1710, 36.1110],
                  [-115.1710, 36.1120],
                ],
              ],
            },
            'properties': {
              'height': 150,
              'color': 0xFFFF0000.toRGBA(), // Red in correct RGBA format
              'id': 'polygon_1',
            },
          },
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Polygon',
              'coordinates': [
                [
                  [-115.1706, 36.1105],
                  [-115.1701, 36.1105],
                  [-115.1701, 36.1100],
                  [-115.1706, 36.1100],
                  [-115.1706, 36.1105],
                ],
              ],
            },
            'properties': {
              'height': 70,
              'color': 0xFF00FF00.toRGBA(), // Green in correct RGBA format
              'id': 'polygon_2',
            },
          },
        ],
      });

      // Clear existing polygons first
      await _clearPolygons();

      // Add GeoJSON source
      final polygonSource = GeoJsonSource(id: 'polygon-source', data: geoJsonData);
      await state.mapboxMap?.style.addSource(polygonSource);
      
      if (kDebugMode) print("GeoJSON source added");

      // Add FillExtrusionLayer with optimized styling
      final fillExtrusionLayer = FillExtrusionLayer(
        id: 'extrusion-layer',
        sourceId: 'polygon-source',
        fillExtrusionColorExpression: ['get', 'color'],
        fillExtrusionHeightExpression: ['get', 'height'],
        fillExtrusionOpacity: 0.7,
        fillExtrusionVerticalGradient: true,
        slot: 'top',
      );
      
      await state.mapboxMap?.style.addLayer(fillExtrusionLayer);
      if (kDebugMode) print("FillExtrusionLayer added");

      state = state.copyWith(polygonSource: polygonSource, polygonCount: 2);

      // Focus camera on polygons with smooth animation
      await updateCamera(36.1100, -115.1701, 15);
    } catch (e) {
      if (kDebugMode) print("Polygon Error: $e");
    }
  }

  // Method to remove all polygons
  Future<void> _clearPolygons() async {
    try {
      // Remove layer first
      try {
        await state.mapboxMap?.style.removeStyleLayer('extrusion-layer');
        if (kDebugMode) print("Extrusion layer removed");
      } catch (e) {
        if (kDebugMode) print("Layer removal error (may not exist): $e");
      }

      // Then remove source
      try {
        await state.mapboxMap?.style.removeStyleSource('polygon-source');
        if (kDebugMode) print("Polygon source removed");
      } catch (e) {
        if (kDebugMode) print("Source removal error (may not exist): $e");
      }

      // Clear from state
      state = state.copyWith(polygonSource: null, polygonCount: 0);
      
      if (kDebugMode) print("Polygons cleared");
    } catch (e) {
      if (kDebugMode) print("Clear polygons error: $e");
    }
  }

  // Public method to clear polygons
  Future<void> clearPolygons() async {
    await _clearPolygons();
  }

  // Updated method with color conversion
  Future<void> updatePolygonsFromApi(
    List<Map<String, dynamic>> polygonData,
  ) async {
    try {
      final features = polygonData.map((polygon) {
        // Convert hex color to ARGB for Mapbox
        String colorHex = polygon['color']?.toString() ?? "#0000FF";
        int colorArgb = _hexToArgb(colorHex);
        
        return {
          'type': 'Feature',
          'geometry': {
            'type': 'Polygon',
            'coordinates': polygon['coordinates'],
          },
          'properties': {
            'height': polygon['height'] ?? 50,
            'color': colorArgb.toRGBA(), // Convert to RGBA format
            'id': polygon['id'] ?? 'polygon_${polygon.hashCode}',
            'name': polygon['name'] ?? '',
            'description': polygon['description'] ?? '',
          },
        };
      }).toList();

      final geoJsonData = jsonEncode({
        'type': 'FeatureCollection',
        'features': features,
      });

      // Remove and re-add source
      await _clearPolygons();
      
      // Create new source with updated data
      final polygonSource = GeoJsonSource(id: 'polygon-source', data: geoJsonData);
      await state.mapboxMap?.style.addSource(polygonSource);
      
      // Re-add the layer
      final fillExtrusionLayer = FillExtrusionLayer(
        id: 'extrusion-layer',
        sourceId: 'polygon-source',
        fillExtrusionColor: 0xFF0000F, // Default color
        fillExtrusionColorExpression: ["get", "color"],
        fillExtrusionHeight: 50.0,
        fillExtrusionHeightExpression: ["get", "height"],
        fillExtrusionOpacity: 0.8,
        fillExtrusionVerticalGradient: true,
        slot: 'top',
      );

      await state.mapboxMap?.style.addLayer(fillExtrusionLayer);
      
      state = state.copyWith(
        polygonSource: polygonSource,
        polygonCount: features.length,
      );

      if (kDebugMode)
        print("Polygons updated from API: ${features.length} polygons");
    } catch (e) {
      if (kDebugMode) print("API Polygons Error: $e");
    }
  }

  static Future<Map<String, dynamic>> _processMarkersInIsolate(
    List<dynamic> rawData,
  ) async {
    return await compute(_processMarkersData, rawData);
  }

  // Static function for isolate computation
  static Map<String, dynamic> _processMarkersData(List<dynamic> response) {
    final Map<String, VenueDetails> annotationsData = {};
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

    for (final marker in response) {
      try {
        final type = _getTypeFromStringStatic(marker['markerType']);
        final lat =
            double.tryParse(marker['latitude']?.toString() ?? '0') ?? 0.0;
        final lng =
            double.tryParse(marker['longitude']?.toString() ?? '0') ?? 0.0;

        if (lat == 0.0 || lng == 0.0) continue; // Skip invalid coordinates

        final detail = VenueDetails(
          name: marker['placeName']?.toString() ?? 'Unknown',
          description: marker['partyDescription']?.toString() ?? '',
          type: type,
          website: marker['website']?.toString() ?? '',
          time: marker['partyTime']?.toString() ?? '',
          partyIcon: marker['partyIcon']?.toString(),
          placeImage: marker['placeImage']?.toString(),
          partyImage: marker['partyImage']?.toString(),
          latitude: lat,
          longitude: lng,
          data: _extractTicketData(marker['tickets']),
          times: _extractTicketTimes(marker['tickets']),
        );

        points[type]!.add({
          'type': 'Point',
          'coordinates': [lng, lat],
          'detail': detail,
        });
        details[type]!.add(detail);
      } catch (e) {
        if (kDebugMode) print("Error processing marker: $e");
        continue; // Skip invalid markers
      }
    }

    return {
      'points': points,
      'details': details,
      'annotationsData': annotationsData,
    };
  }

  static List<double> _extractTicketData(dynamic tickets) {
    if (tickets is! List) return [];
    return tickets
        .map<double>(
          (ticket) => (ticket['availableTickets'] as num?)?.toDouble() ?? 0.0,
        )
        .toList();
  }

  static List<String> _extractTicketTimes(dynamic tickets) {
    if (tickets is! List) return [];
    return tickets
        .map<String>((ticket) => ticket['hour']?.toString() ?? '')
        .toList();
  }

  Future<void> updateMarkers() async {
    if (state.isLoading) return; // Prevent concurrent updates

    state = state.copyWith(isLoading: true);

    try {
      final dashboard = ref.read(dashboardProvider);
      final selectedTypes = dashboard.selectedMarkers;
      final image = await _loadMarkerIcon();
      final response = await _api.getMarkers();

      log("SearchAPI Response: $response");

      // Process data in isolate to avoid blocking main thread
      final processedData = await _processMarkersInIsolate(response);
      final points =
          processedData['points']
              as Map<MarkerType, List<Map<String, dynamic>>>;
      final details =
          processedData['details'] as Map<MarkerType, List<VenueDetails>>;

      // Clear existing annotations efficiently
      await state.pointAnnotationManager?.deleteAll();
      final Map<String, VenueDetails> annotationsMap = {};

      // Create annotations only for selected types
      for (final type in MarkerType.values) {
        if (selectedTypes.isNotEmpty && !selectedTypes.contains(type)) continue;

        final typePoints = points[type] ?? [];
        for (final pointData in typePoints) {
          final detail = pointData['detail'] as VenueDetails;
          final coordinates = pointData['coordinates'] as List<dynamic>;

          try {
            final annotation = await state.pointAnnotationManager?.create(
              PointAnnotationOptions(
                geometry: Point(
                  coordinates: Position(coordinates[0], coordinates[1]),
                ),
                image: image,
                textField: detail.name,
                textSize: 14,
                textColor: AppColor.whiteColor.value,
                textHaloColor: AppColor.primaryColor.value,
                textHaloWidth: 5.0,
                textHaloBlur: 5.0,
                textOffset: [0.0, 1.5],
              ),
            );

            if (annotation != null) {
              annotationsMap[annotation.id] = detail;
            }
          } catch (e) {
            if (kDebugMode) print("Error creating annotation: $e");
          }
        }
      }

      state = state.copyWith(
        annotationDetails: annotationsMap,
        points: points,
        details: details,
      );
    } catch (e) {
      if (kDebugMode) print("Marker Update Error: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateCamera(double lat, double lng, double zoom) async {
    try {
      final camera = CameraOptions(
        center: Point(coordinates: Position(lng, lat)),
        zoom: zoom,
        pitch: 75.0,
      );
      final animation = MapAnimationOptions(duration: 1000);
      await state.mapboxMap?.flyTo(camera, animation);
      if (kDebugMode)
        print("Camera updated to lat: $lat, lng: $lng, zoom: $zoom");
    } catch (e) {
      if (kDebugMode) print("Camera update error: $e");
    }
  }

  static MarkerType _getTypeFromStringStatic(String? value) {
    switch (value?.toLowerCase()) {
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
    _debounceTimer?.cancel();
    _polygonDebounceTimer?.cancel();
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

// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// import 'package:partymap_app/Screens/dashboard/dashboard_notifier.dart';
// import 'package:partymap_app/Screens/home/widgets/venue_details.dart';
// import 'package:partymap_app/repository/markers_repository/markers_repository.dart';
// import 'package:partymap_app/res/assets/image_assets.dart';
// import 'package:partymap_app/res/colors/app_color.dart';

// final mapControllerProvider =
//     StateNotifierProvider<MapControllerNotifier, MapControllerState>(
//       (ref) => MapControllerNotifier(ref),
//     );

// final selectedVenueProvider = StateProvider<VenueDetails?>((ref) => null);

// class MapControllerState {
//   final MapboxMap? mapboxMap;
//   final PointAnnotationManager? pointAnnotationManager;
//   final Map<String, VenueDetails> annotationDetails;
//   final Map<MarkerType, List<Map<String, dynamic>>> points;
//   final Map<MarkerType, List<VenueDetails>> details;
//   final String mapType;
//   final bool isLoading;

//   MapControllerState({
//     this.mapboxMap,
//     this.pointAnnotationManager,
//     this.annotationDetails = const {},
//     this.points = const {
//       MarkerType.parties: [],
//       MarkerType.bars: [],
//       MarkerType.restaurants: [],
//     },
//     this.details = const {
//       MarkerType.parties: [],
//       MarkerType.bars: [],
//       MarkerType.restaurants: [],
//     },
//     this.mapType = "Dark",
//     this.isLoading = false,
//   });

//   MapControllerState copyWith({
//     MapboxMap? mapboxMap,
//     PointAnnotationManager? pointAnnotationManager,
//     Map<String, VenueDetails>? annotationDetails,
//     Map<MarkerType, List<Map<String, dynamic>>>? points,
//     Map<MarkerType, List<VenueDetails>>? details,
//     String? mapType,
//     bool? isLoading,
//   }) {
//     return MapControllerState(
//       mapboxMap: mapboxMap ?? this.mapboxMap,
//       pointAnnotationManager:
//           pointAnnotationManager ?? this.pointAnnotationManager,
//       annotationDetails: annotationDetails ?? this.annotationDetails,
//       points: points ?? this.points,
//       details: details ?? this.details,
//       mapType: mapType ?? this.mapType,
//       isLoading: isLoading ?? this.isLoading,
//     );
//   }
// }

// class MapControllerNotifier extends StateNotifier<MapControllerState> {
//   final Ref ref;
//   final _api = MarkersRepository();
//   final TextEditingController searchController = TextEditingController();
//   final FocusNode searchFocusNode = FocusNode();

//   // Cache for marker icon
//   static Uint8List? _cachedMarkerIcon;

//   // Debounce timer for API calls
//   Timer? _debounceTimer;

//   MapControllerNotifier(this.ref) : super(MapControllerState()) {
//     // Listen to dashboard changes with debouncing
//     ref.listen(dashboardProvider.select((s) => s.selectedMarkers), (
//       prev,
//       next,
//     ) {
//       _debounceTimer?.cancel();
//       _debounceTimer = Timer(const Duration(milliseconds: 300), () {
//         updateMarkers();
//       });
//     });
//   }

//   Map<String, VenueDetails> get annotationDetails => state.annotationDetails;

//   Future<void> onMapCreated(MapboxMap mapboxMap) async {
//     try {
//       final pointManager = await mapboxMap.annotations
//           .createPointAnnotationManager();

//       state = state.copyWith(
//         mapboxMap: mapboxMap,
//         pointAnnotationManager: pointManager,
//       );

//       // Add polygons first, then markers
//       await _addDummyPolygons();
//       await updateMarkers();
//       _setupPointAnnotationListener();
//     } catch (e) {
//       if (kDebugMode) print("Map creation error: $e");
//     }
//   }

//   void updateMapType(String newType) {
//     state = state.copyWith(mapType: newType);
//   }

//   // Optimized marker icon loading with caching
//   Future<Uint8List> _loadMarkerIcon() async {
//     if (_cachedMarkerIcon != null) return _cachedMarkerIcon!;

//     try {
//       final ByteData bytes = await rootBundle.load(ImageAssets.markerIconSmall);
//       _cachedMarkerIcon = bytes.buffer.asUint8List();
//       return _cachedMarkerIcon!;
//     } catch (e) {
//       if (kDebugMode) print("Error loading marker icon: $e");
//       rethrow;
//     }
//   }

//   // Optimized polygon rendering with performance improvements
//   Future<void> _addDummyPolygons() async {
//     try {
//       final geoJsonData = jsonEncode({
//         'type': 'FeatureCollection',
//         'features': [
//           {
//             'type': 'Feature',
//             'geometry': {
//               'type': 'Polygon',
//               'coordinates': [
//                 [
//                   [-115.1710, 36.1120], // Point 1
//                   [-115.1705, 36.1120], // Point 2
//                   [-115.1705, 36.1115], // Point 3
//                   [-115.1700, 36.1115], // Point 4
//                   [-115.1700, 36.1110], // Point 5
//                   [-115.1710, 36.1110], // Point 6
//                   [-115.1710, 36.1120], // Close polygon (back to Point 1)
//                 ],
//               ],
//             },
//             'properties': {
//               'height': 150,
//               'color': 0xFFFF0000.toRGBA(), // Red (ARGB)
//               'id': 'polygon_1',
//             },
//           },
//           {
//             'type': 'Feature',
//             'geometry': {
//               'type': 'Polygon',
//               'coordinates': [
//                 [
//                   [-115.1706, 36.1105],
//                   [-115.1701, 36.1105],
//                   [-115.1701, 36.1100],
//                   [-115.1706, 36.1100],
//                   [-115.1706, 36.1105],
//                 ],
//               ],
//             },
//             'properties': {
//               'height': 70,
//               'color': 0xFF00FF00.toRGBA(), // Green (ARGB)
//               'id': 'polygon_2',
//             },
//           },
//         ],
//       });

//       // Check if source already exists to avoid duplicates
//       final existingSources = await state.mapboxMap?.style.getStyleSources();
//       final sourceExists =
//           existingSources?.any((source) => source?.id == 'polygon-source') ??
//           false;

//       if (!sourceExists) {
//         // Add GeoJSON source
//         await state.mapboxMap?.style.addSource(
//           GeoJsonSource(id: 'polygon-source', data: geoJsonData),
//         );
//         if (kDebugMode) print("GeoJSON source added");
//       } else {
//         // Update existing source data
//         // await state.mapboxMap?.style.updateStyleSourceProperty(
//         //   'polygon-source',
//         //   'data',
//         //   geoJsonData,
//         // );
//         if (kDebugMode) print("GeoJSON source updated");
//       }

//       // Check if layer already exists
//       final existingLayers = await state.mapboxMap?.style.getStyleLayers();
//       final layerExists =
//           existingLayers?.any((layer) => layer?.id == 'extrusion-layer') ??
//           false;

//       if (!layerExists) {
//         // Add FillExtrusionLayer with optimized styling
//         await state.mapboxMap?.style.addLayer(
//           FillExtrusionLayer(
//             id: 'extrusion-layer',
//             sourceId: 'polygon-source',
//             fillExtrusionColorExpression: ['get', 'color'],
//             fillExtrusionHeightExpression: ['get', 'height'],
//             fillExtrusionOpacity: 0.7,
//             fillExtrusionVerticalGradient: true, // Better visual effect
//             slot: 'top', // Place above other layers
//           ),
//         );
//         if (kDebugMode) print("FillExtrusionLayer added");
//       }

//       // Verify layer exists
//       final layers = await state.mapboxMap?.style.getStyleLayers();
//       if (kDebugMode) print("Style layers count: ${layers?.length}");

//       // Focus camera on polygons with smooth animation
//       await updateCamera(36.1100, -115.1701, 15); // Slightly closer zoom
//     } catch (e) {
//       if (kDebugMode) print("Polygon Error: $e");
//       // Don't let polygon errors break the entire map
//     }
//   }

//   // Method to add polygons from backend data (for future implementation)
//   Future<void> addPolygonsFromApi(
//     List<Map<String, dynamic>> polygonData,
//   ) async {
//     try {
//       final features = polygonData.map((polygon) {
//         return {
//           'type': 'Feature',
//           'geometry': {
//             'type': 'Polygon',
//             'coordinates': polygon['coordinates'],
//           },
//           'properties': {
//             'height': polygon['height'] ?? 50,
//             'color': polygon['color'] ?? 0xFF0000FF,
//             'id': polygon['id'] ?? 'polygon_${polygon.hashCode}',
//             'name': polygon['name'] ?? '',
//             'description': polygon['description'] ?? '',
//           },
//         };
//       }).toList();

//       // final geoJsonData = jsonEncode({
//       //   'type': 'FeatureCollection',
//       //   'features': features,
//       // });

//       // Update polygon source with new data
//       // await state.mapboxMap?.style.updateStyleSourceProperty(
//       //   'polygon-source',
//       //   'data',
//       //   geoJsonData,
//       // );

//       if (kDebugMode)
//         print("Polygons updated from API: ${features.length} polygons");
//     } catch (e) {
//       if (kDebugMode) print("API Polygons Error: $e");
//     }
//   }

//   // Method to remove all polygons
//   Future<void> clearPolygons() async {
//     try {
//       await state.mapboxMap?.style.removeStyleLayer('extrusion-layer');
//       await state.mapboxMap?.style.removeStyleSource('polygon-source');
//       if (kDebugMode) print("Polygons cleared");
//     } catch (e) {
//       if (kDebugMode) print("Clear polygons error: $e");
//     }
//   }

//   static Future<Map<String, dynamic>> _processMarkersInIsolate(
//     List<dynamic> rawData,
//   ) async {
//     return await compute(_processMarkersData, rawData);
//   }

//   // Static function for isolate computation
//   static Map<String, dynamic> _processMarkersData(List<dynamic> response) {
//     final Map<String, VenueDetails> annotationsData = {};
//     final Map<MarkerType, List<Map<String, dynamic>>> points = {
//       MarkerType.parties: [],
//       MarkerType.bars: [],
//       MarkerType.restaurants: [],
//     };
//     final Map<MarkerType, List<VenueDetails>> details = {
//       MarkerType.parties: [],
//       MarkerType.bars: [],
//       MarkerType.restaurants: [],
//     };

//     for (final marker in response) {
//       try {
//         final type = _getTypeFromStringStatic(marker['markerType']);
//         final lat =
//             double.tryParse(marker['latitude']?.toString() ?? '0') ?? 0.0;
//         final lng =
//             double.tryParse(marker['longitude']?.toString() ?? '0') ?? 0.0;

//         if (lat == 0.0 || lng == 0.0) continue; // Skip invalid coordinates

//         final detail = VenueDetails(
//           name: marker['placeName']?.toString() ?? 'Unknown',
//           description: marker['partyDescription']?.toString() ?? '',
//           type: type,
//           website: marker['website']?.toString() ?? '',
//           time: marker['partyTime']?.toString() ?? '',
//           partyIcon: marker['partyIcon']?.toString(),
//           placeImage: marker['placeImage']?.toString(),
//           partyImage: marker['partyImage']?.toString(),
//           latitude: lat,
//           longitude: lng,
//           data: _extractTicketData(marker['tickets']),
//           times: _extractTicketTimes(marker['tickets']),
//         );

//         points[type]!.add({
//           'type': 'Point',
//           'coordinates': [lng, lat],
//           'detail': detail,
//         });
//         details[type]!.add(detail);
//       } catch (e) {
//         if (kDebugMode) print("Error processing marker: $e");
//         continue; // Skip invalid markers
//       }
//     }

//     return {
//       'points': points,
//       'details': details,
//       'annotationsData': annotationsData,
//     };
//   }

//   static List<double> _extractTicketData(dynamic tickets) {
//     if (tickets is! List) return [];
//     return tickets
//         .map<double>(
//           (ticket) => (ticket['availableTickets'] as num?)?.toDouble() ?? 0.0,
//         )
//         .toList();
//   }

//   static List<String> _extractTicketTimes(dynamic tickets) {
//     if (tickets is! List) return [];
//     return tickets
//         .map<String>((ticket) => ticket['hour']?.toString() ?? '')
//         .toList();
//   }

//   Future<void> updateMarkers() async {
//     if (state.isLoading) return; // Prevent concurrent updates

//     state = state.copyWith(isLoading: true);

//     try {
//       final dashboard = ref.read(dashboardProvider);
//       final selectedTypes = dashboard.selectedMarkers;
//       final image = await _loadMarkerIcon();
//       final response = await _api.getMarkers();

//       log("SearchAPI Response: $response");

//       // Process data in isolate to avoid blocking main thread
//       final processedData = await _processMarkersInIsolate(response);
//       final points =
//           processedData['points']
//               as Map<MarkerType, List<Map<String, dynamic>>>;
//       final details =
//           processedData['details'] as Map<MarkerType, List<VenueDetails>>;

//       // Clear existing annotations efficiently
//       await state.pointAnnotationManager?.deleteAll();
//       final Map<String, VenueDetails> annotationsMap = {};

//       // Create annotations only for selected types
//       for (final type in MarkerType.values) {
//         if (selectedTypes.isNotEmpty && !selectedTypes.contains(type)) continue;

//         final typePoints = points[type] ?? [];
//         for (final pointData in typePoints) {
//           final detail = pointData['detail'] as VenueDetails;
//           final coordinates = pointData['coordinates'] as List<dynamic>;

//           try {
//             final annotation = await state.pointAnnotationManager?.create(
//               PointAnnotationOptions(
//                 geometry: Point(
//                   coordinates: Position(coordinates[0], coordinates[1]),
//                 ),
//                 image: image,
//                 textField: detail.name,
//                 textSize: 14,
//                 textColor: AppColor.whiteColor.value,
//                 textHaloColor: AppColor.primaryColor.value,
//                 textHaloWidth: 5.0,
//                 textHaloBlur: 5.0,
//                 textOffset: [0.0, 1.5],
//               ),
//             );

//             if (annotation != null) {
//               annotationsMap[annotation.id] = detail;
//             }
//           } catch (e) {
//             if (kDebugMode) print("Error creating annotation: $e");
//           }
//         }
//       }

//       state = state.copyWith(
//         annotationDetails: annotationsMap,
//         points: points,
//         details: details,
//       );
//     } catch (e) {
//       if (kDebugMode) print("Marker Update Error: $e");
//     } finally {
//       state = state.copyWith(isLoading: false);
//     }
//   }

//   Future<void> updateCamera(double lat, double lng, double zoom) async {
//     try {
//       final camera = CameraOptions(
//         center: Point(coordinates: Position(lng, lat)),
//         zoom: zoom,
//         pitch: 75.0,
//       );
//       final animation = MapAnimationOptions(duration: 1000);
//       await state.mapboxMap?.flyTo(camera, animation);
//       if (kDebugMode)
//         print("Camera updated to lat: $lat, lng: $lng, zoom: $zoom");
//     } catch (e) {
//       if (kDebugMode) print("Camera update error: $e");
//     }
//   }

//   static MarkerType _getTypeFromStringStatic(String? value) {
//     switch (value?.toLowerCase()) {
//       case 'party':
//         return MarkerType.parties;
//       case 'bar':
//         return MarkerType.bars;
//       case 'restaurant':
//         return MarkerType.restaurants;
//       default:
//         return MarkerType.parties;
//     }
//   }

//   void _setupPointAnnotationListener() {
//     state.pointAnnotationManager?.addOnPointAnnotationClickListener(
//       MyAnnotationClickListener(this),
//     );
//   }

//   void selectVenue(VenueDetails details) {
//     ref.read(selectedVenueProvider.notifier).state = details;
//   }

//   @override
//   void dispose() {
//     _debounceTimer?.cancel();
//     searchController.dispose();
//     searchFocusNode.dispose();
//     super.dispose();
//   }
// }

// class MyAnnotationClickListener implements OnPointAnnotationClickListener {
//   final MapControllerNotifier controller;

//   MyAnnotationClickListener(this.controller);

//   @override
//   void onPointAnnotationClick(PointAnnotation annotation) {
//     final details = controller.annotationDetails[annotation.id];
//     if (details == null) {
//       log("No details found for annotation ID: ${annotation.id}");
//       return;
//     }

//     log("Clicked on annotation: ${details.name}");

//     if (details.type == MarkerType.parties) {
//       controller.selectVenue(details);
//     } else {
//       if (kDebugMode) {
//         print("Clicked on a non-party marker: ${details.name}");
//       }
//     }
//   }
// }