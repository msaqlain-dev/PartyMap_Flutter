import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MarkerType { parties, bars, restaurants }

class DashboardState {
  final int tabIndex;
  final Set<MarkerType> selectedMarkers;

  DashboardState({this.tabIndex = 0, this.selectedMarkers = const {}});

  DashboardState copyWith({int? tabIndex, Set<MarkerType>? selectedMarkers}) {
    return DashboardState(
      tabIndex: tabIndex ?? this.tabIndex,
      selectedMarkers: selectedMarkers ?? this.selectedMarkers,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState());

  void selectMarker(MarkerType type) {
    final markers = Set<MarkerType>.from(state.selectedMarkers);
    if (markers.contains(type)) {
      markers.remove(type);
    } else {
      markers.add(type);
    }
    state = state.copyWith(selectedMarkers: markers);
  }

  void navigateTo(int index) {
    Set<MarkerType> updated = state.selectedMarkers;
    if (index != 0) updated = {};
    state = state.copyWith(tabIndex: index, selectedMarkers: updated);
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
      (ref) => DashboardNotifier(),
    );
