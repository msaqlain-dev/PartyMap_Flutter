import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:partymap_app/Screens/home/widgets/venue_details.dart';
import 'package:partymap_app/repository/markers_repository/markers_repository.dart';

final locationSearchProvider =
    StateNotifierProvider<LocationSearchController, LocationSearchState>(
      (ref) => LocationSearchController(),
    );

class LocationSearchState {
  final List<VenueDetails> venues;
  final List<VenueDetails> suggestions;
  final bool showSuggestions;
  final bool isLoading;
  final String? errorMessage;

  LocationSearchState({
    this.venues = const [],
    this.suggestions = const [],
    this.showSuggestions = false,
    this.isLoading = false,
    this.errorMessage,
  });

  LocationSearchState copyWith({
    List<VenueDetails>? venues,
    List<VenueDetails>? suggestions,
    bool? showSuggestions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LocationSearchState(
      venues: venues ?? this.venues,
      suggestions: suggestions ?? this.suggestions,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LocationSearchController extends StateNotifier<LocationSearchState> {
  LocationSearchController() : super(LocationSearchState()) {
    _initializeVenues();
  }

  final _api = MarkersRepository();
  static const int _maxSuggestions = 5; // Limit suggestions for performance

  Future<void> _initializeVenues() async {
    if (state.venues.isNotEmpty) return; // Don't fetch if already loaded

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.getMarkers();

      if (response is List) {
        final venues = response
            .where((item) => item['placeName'] != null) // Filter out null names
            .map<VenueDetails>((venueData) {
              return VenueDetails(
                name: venueData['placeName']?.toString()?.trim(),
                latitude:
                    double.tryParse(venueData['latitude']?.toString() ?? '0') ??
                    0,
                longitude:
                    double.tryParse(
                      venueData['longitude']?.toString() ?? '0',
                    ) ??
                    0,
              );
            })
            .where((venue) => venue.name != null && venue.name!.isNotEmpty)
            .toList();

        // Sort venues alphabetically for better UX
        venues.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

        state = state.copyWith(venues: venues);
      }
    } catch (e) {
      log("Error fetching venues: $e");
      state = state.copyWith(errorMessage: "Failed to load locations");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void searchLocation(String query) {
    if (query.trim().isEmpty) {
      state = state.copyWith(suggestions: [], showSuggestions: false);
      return;
    }

    final queryLower = query.toLowerCase().trim();
    final filteredVenues = state.venues
        .where((venue) {
          final name = venue.name?.toLowerCase() ?? '';
          return name.contains(queryLower);
        })
        .take(_maxSuggestions) // Limit results for performance
        .toList();

    state = state.copyWith(
      suggestions: filteredVenues,
      showSuggestions: filteredVenues.isNotEmpty,
    );
  }

  void clearSuggestions() {
    state = state.copyWith(suggestions: [], showSuggestions: false);
  }
}

// import 'dart:developer';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:partymap_app/Screens/home/widgets/venue_details.dart';
// import 'package:partymap_app/repository/markers_repository/markers_repository.dart';

// final locationSearchProvider =
//     StateNotifierProvider<LocationSearchController, LocationSearchState>(
//       (ref) => LocationSearchController(),
//     );

// class LocationSearchState {
//   final List<VenueDetails> venues;
//   final List<VenueDetails> suggestions;
//   final bool showSuggestions;
//   final bool isLoading;

//   LocationSearchState({
//     this.venues = const [],
//     this.suggestions = const [],
//     this.showSuggestions = false,
//     this.isLoading = false,
//   });

//   LocationSearchState copyWith({
//     List<VenueDetails>? venues,
//     List<VenueDetails>? suggestions,
//     bool? showSuggestions,
//     bool? isLoading,
//   }) {
//     return LocationSearchState(
//       venues: venues ?? this.venues,
//       suggestions: suggestions ?? this.suggestions,
//       showSuggestions: showSuggestions ?? this.showSuggestions,
//       isLoading: isLoading ?? this.isLoading,
//     );
//   }
// }

// class LocationSearchController extends StateNotifier<LocationSearchState> {
//   LocationSearchController() : super(LocationSearchState()) {
//     fetchVenuesFromApi();
//   }

//   final _api = MarkersRepository();

//   void fetchVenuesFromApi() async {
//     state = state.copyWith(isLoading: true);
//     try {
//       dynamic response = await _api.getMarkers();

//       if (response is List) {
//         final venues = response.map<VenueDetails>((venueData) {
//           return VenueDetails(
//             name: venueData['placeName'] ?? '',
//             latitude: double.tryParse(venueData['latitude'] ?? '0') ?? 0,
//             longitude: double.tryParse(venueData['longitude'] ?? '0') ?? 0,
//           );
//         }).toList();

//         state = state.copyWith(venues: venues);
//       }
//     } catch (e) {
//       log("Error fetching venues: $e");
//     } finally {
//       state = state.copyWith(isLoading: false);
//     }
//   }

//   void searchLocation(String query) {
//     if (query.isNotEmpty) {
//       final result = state.venues
//           .where(
//             (venue) =>
//                 (venue.name != null &&
//                 venue.name!.toLowerCase().contains(query.toLowerCase())),
//           )
//           .toList();
//       state = state.copyWith(suggestions: result, showSuggestions: true);
//     } else {
//       state = state.copyWith(suggestions: [], showSuggestions: false);
//     }
//   }
// }
