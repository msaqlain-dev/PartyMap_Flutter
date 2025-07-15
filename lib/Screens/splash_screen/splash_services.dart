import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:partymap_app/res/navigators/routes_name.dart';
import 'package:partymap_app/user_preference/user_preference_controller.dart';

final splashServiceProvider = Provider((ref) => SplashServices());

class SplashServices {
  final UserPreference _userPreference = UserPreference();

  Future<void> checkLoginStatus(BuildContext context) async {
    final user = await _userPreference.getUser();
    final bool isLoggedIn = user.isLogin == true;
    // final bool isLoggedIn = true;

    log('User login status: $isLoggedIn');
    log("User details: ${user.toJson()}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(
        isLoggedIn ? RouteName.dashboardScreen : RouteName.loginScreen,
      );
    });
  }
}
