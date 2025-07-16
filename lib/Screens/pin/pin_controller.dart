import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:partymap_app/res/navigators/routes_name.dart';
import 'package:partymap_app/user_preference/user_preference_controller.dart';

final pinControllerProvider = StateNotifierProvider<PinController, PinState>((
  ref,
) {
  return PinController();
});

class PinState {
  final String? title;
  final bool isLoggedIn;

  PinState({this.title = "", this.isLoggedIn = false});

  PinState copyWith({String? title, bool? isLoggedIn}) {
    return PinState(
      title: title ?? this.title,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class PinController extends StateNotifier<PinState> {
  PinController() : super(PinState()) {
    checkLoginStatus();
  }

  final UserPreference _userPreference = UserPreference.instance;

  void updateTitle(String newTitle) {
    state = state.copyWith(title: newTitle);
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _userPreference.removeUser();
      state = state.copyWith(isLoggedIn: false);
      if (context.mounted) {
        context.go(RouteName.loginScreen);
      }
    } catch (e) {
      log('Logout error: $e');
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      final isLoggedIn = await _userPreference.isLoggedIn();
      state = state.copyWith(isLoggedIn: isLoggedIn);
    } catch (e) {
      log('Error checking login status: $e');
    }
  }
}
