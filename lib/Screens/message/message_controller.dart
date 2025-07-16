import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:partymap_app/res/navigators/routes_name.dart';
import 'package:partymap_app/user_preference/user_preference_controller.dart';

final messageControllerProvider =
    StateNotifierProvider<MessageController, MessageState>((ref) {
      return MessageController();
    });

class MessageState {
  // You can expand this state with message list, filters, etc.
  final String? title;
  final bool isLoggedIn;

  MessageState({this.title = "", this.isLoggedIn = false});

  MessageState copyWith({String? title, bool? isLoggedIn}) {
    return MessageState(
      title: title ?? this.title,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class MessageController extends StateNotifier<MessageState> {
  MessageController() : super(MessageState()) {
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
