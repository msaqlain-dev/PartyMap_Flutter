import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:partymap_app/models/user_model.dart';
import 'package:partymap_app/res/navigators/routes_name.dart';
import 'package:partymap_app/user_preference/user_preference_controller.dart';

final splashServiceProvider = Provider((ref) => SplashServices());

class SplashServices {
  final UserPreference _userPreference = UserPreference.instance;
  
  // Add connectivity check
  bool _isProcessing = false;

  Future<void> checkLoginStatus(BuildContext context) async {
    if (_isProcessing) return; // Prevent multiple calls
    _isProcessing = true;

    try {
      // Get user data with timeout
      final user = await _userPreference.getUser().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          log('UserPreference timeout, proceeding with default');
          return Future.value(UserModel(isLogin: false));
        },
      );

      final bool isLoggedIn = user.isLogin == true && 
                              user.token != null && 
                              user.token!.isNotEmpty;

      log('User login status: $isLoggedIn');
      log("User details: ${user.toJson()}");

      // Navigate safely
      if (context.mounted) {
        _navigateBasedOnLoginStatus(context, isLoggedIn);
      }
    } catch (e) {
      log('Error checking login status: $e');
      if (context.mounted) {
        navigateToLogin(context);
      }
    } finally {
      _isProcessing = false;
    }
  }

  void _navigateBasedOnLoginStatus(BuildContext context, bool isLoggedIn) {
    // Use microtask to ensure context is valid
    Future.microtask(() {
      if (context.mounted) {
        try {
          context.go(
            isLoggedIn ? RouteName.dashboardScreen : RouteName.loginScreen,
          );
        } catch (e) {
          log('Navigation error: $e');
          // Fallback navigation
          navigateToLogin(context);
        }
      }
    });
  }

  void navigateToLogin(BuildContext context) {
    Future.microtask(() {
      if (context.mounted) {
        try {
          context.go(RouteName.loginScreen);
        } catch (e) {
          log('Fallback navigation error: $e');
        }
      }
    });
  }

  // Method to clear user data and navigate to login
  Future<void> logout(BuildContext context) async {
    try {
      await _userPreference.removeUser();
      if (context.mounted) {
        context.go(RouteName.loginScreen);
      }
    } catch (e) {
      log('Logout error: $e');
    }
  }

  // Method to check if user session is still valid
  Future<bool> isSessionValid() async {
    try {
      final user = await _userPreference.getUser();
      return user.isLogin == true && 
             user.token != null && 
             user.token!.isNotEmpty;
    } catch (e) {
      log('Session validation error: $e');
      return false;
    }
  }
}