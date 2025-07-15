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

  LocationSearchState({
    this.venues = const [],
    this.suggestions = const [],
    this.showSuggestions = false,
    this.isLoading = false,
  });

  LocationSearchState copyWith({
    List<VenueDetails>? venues,
    List<VenueDetails>? suggestions,
    bool? showSuggestions,
    bool? isLoading,
  }) {
    return LocationSearchState(
      venues: venues ?? this.venues,
      suggestions: suggestions ?? this.suggestions,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationSearchController extends StateNotifier<LocationSearchState> {
  LocationSearchController() : super(LocationSearchState()) {
    fetchVenuesFromApi();
  }

  final _api = MarkersRepository();

  void fetchVenuesFromApi() async {
    state = state.copyWith(isLoading: true);
    try {
      dynamic response = await _api.getMarkers();
      
      if (response is List) {
        final venues = response.map<VenueDetails>((venueData) {
          return VenueDetails(
            name: venueData['placeName'] ?? '',
            latitude: double.tryParse(venueData['latitude'] ?? '0') ?? 0,
            longitude: double.tryParse(venueData['longitude'] ?? '0') ?? 0,
          );
        }).toList();

        state = state.copyWith(venues: venues);
      }
    } catch (e) {
      log("Error fetching venues: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void searchLocation(String query) {
    if (query.isNotEmpty) {
      final result = state.venues
          .where(
            (venue) =>
                (venue.name != null &&
                venue.name!.toLowerCase().contains(query.toLowerCase())),
          )
          .toList();
      state = state.copyWith(suggestions: result, showSuggestions: true);
    } else {
      state = state.copyWith(suggestions: [], showSuggestions: false);
    }
  }
}
