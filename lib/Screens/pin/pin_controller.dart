import 'package:flutter_riverpod/flutter_riverpod.dart';

final pinControllerProvider = StateNotifierProvider<PinController, PinState>((
  ref,
) {
  return PinController();
});

class PinState {
  final String? title;

  PinState({this.title = ""});

  PinState copyWith({String? title}) {
    return PinState(title: title ?? this.title);
  }
}

class PinController extends StateNotifier<PinState> {
  PinController() : super(PinState());

  void updateTitle(String newTitle) {
    state = state.copyWith(title: newTitle);
  }
}
