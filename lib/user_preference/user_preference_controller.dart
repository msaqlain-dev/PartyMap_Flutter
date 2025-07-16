import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:partymap_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreference {
  // Singleton pattern for better performance
  static UserPreference? _instance;
  static UserPreference get instance =>
      _instance ??= UserPreference._internal();
  UserPreference._internal();

  // Cache SharedPreferences instance
  SharedPreferences? _prefs;

  // Keys for consistent storage
  static const String _keyToken = 'user_token';
  static const String _keyIsLogin = 'is_login';
  static const String _keyUserData = 'user_data';
  static const String _keyLastUpdate = 'last_update';

  // Initialize SharedPreferences
  Future<SharedPreferences> get _sharedPreferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Save complete user model with error handling
  Future<bool> saveUser(UserModel userModel) async {
    try {
      final sp = await _sharedPreferences;

      // Save individual fields for backward compatibility
      await sp.setString(_keyToken, userModel.token ?? '');
      await sp.setBool(_keyIsLogin, userModel.isLogin ?? false);

      // Save complete user data as JSON for future use
      final userData = jsonEncode(userModel.toJson());
      await sp.setString(_keyUserData, userData);

      // Save timestamp for session management
      await sp.setInt(_keyLastUpdate, DateTime.now().millisecondsSinceEpoch);

      log('User data saved successfully');
      return true;
    } catch (e) {
      log('Error saving user data: $e');
      return false;
    }
  }

  // Get user with enhanced error handling and validation
  Future<UserModel> getUser() async {
    try {
      final sp = await _sharedPreferences;

      // Try to get complete user data first
      final userDataJson = sp.getString(_keyUserData);
      if (userDataJson != null && userDataJson.isNotEmpty) {
        try {
          final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
          final user = UserModel.fromJson(userData);

          // Validate session (optional: add expiry logic)
          if (_isSessionValid(sp)) {
            return user;
          }
        } catch (e) {
          log('Error parsing stored user data: $e');
        }
      }

      // Fallback to individual fields for backward compatibility
      final token = sp.getString(_keyToken);
      final isLogin = sp.getBool(_keyIsLogin);

      return UserModel(token: token, isLogin: isLogin ?? false);
    } catch (e) {
      log('Error getting user data: $e');
      // Return default user on error
      return UserModel(isLogin: false);
    }
  }

  // Check if session is still valid (you can add expiry logic here)
  bool _isSessionValid(SharedPreferences sp) {
    try {
      final lastUpdate = sp.getInt(_keyLastUpdate);
      if (lastUpdate == null) return true; // No timestamp means old version

      final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      final now = DateTime.now();
      final difference = now.difference(lastUpdateTime);

      // Session expires after 30 days (adjust as needed)
      return difference.inDays < 30;
    } catch (e) {
      log('Error checking session validity: $e');
      return true; // Assume valid on error
    }
  }

  // Remove user data with proper cleanup
  Future<bool> removeUser() async {
    try {
      final sp = await _sharedPreferences;

      // Remove all user-related keys
      await Future.wait([
        sp.remove(_keyToken),
        sp.remove(_keyIsLogin),
        sp.remove(_keyUserData),
        sp.remove(_keyLastUpdate),
      ]);

      log('User data removed successfully');
      return true;
    } catch (e) {
      log('Error removing user data: $e');
      return false;
    }
  }

  // Get specific user field (useful for quick checks)
  Future<String?> getToken() async {
    try {
      final sp = await _sharedPreferences;
      return sp.getString(_keyToken);
    } catch (e) {
      log('Error getting token: $e');
      return null;
    }
  }

  // Check if user is logged in (quick check)
  Future<bool> isLoggedIn() async {
    try {
      final sp = await _sharedPreferences;
      final isLogin = sp.getBool(_keyIsLogin) ?? false;
      final token = sp.getString(_keyToken);

      return isLogin &&
          token != null &&
          token.isNotEmpty &&
          _isSessionValid(sp);
    } catch (e) {
      log('Error checking login status: $e');
      return false;
    }
  }

  // Update specific fields without full user replacement
  Future<bool> updateLoginStatus(bool isLogin) async {
    try {
      final sp = await _sharedPreferences;
      await sp.setBool(_keyIsLogin, isLogin);
      await sp.setInt(_keyLastUpdate, DateTime.now().millisecondsSinceEpoch);
      return true;
    } catch (e) {
      log('Error updating login status: $e');
      return false;
    }
  }

  // Clear cache (useful for testing or force refresh)
  void clearCache() {
    _prefs = null;
  }

  // Get session info for debugging
  Future<Map<String, dynamic>> getSessionInfo() async {
    try {
      final sp = await _sharedPreferences;
      final lastUpdate = sp.getInt(_keyLastUpdate);

      return {
        'hasToken': sp.getString(_keyToken) != null,
        'isLogin': sp.getBool(_keyIsLogin) ?? false,
        'lastUpdate': lastUpdate != null
            ? DateTime.fromMillisecondsSinceEpoch(lastUpdate).toIso8601String()
            : null,
        'sessionValid': _isSessionValid(sp),
      };
    } catch (e) {
      log('Error getting session info: $e');
      return {'error': e.toString()};
    }
  }
}
