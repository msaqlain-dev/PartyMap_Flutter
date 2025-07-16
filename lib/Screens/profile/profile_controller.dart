import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:partymap_app/user_preference/user_preference_controller.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      return ProfileController();
    });

class ProfileState {
  final String name;
  final String email;
  final String phone;
  final String instagram;
  final String snapchat;
  final String facebook;
  final String twitter;

  ProfileState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.instagram = '',
    this.snapchat = '',
    this.facebook = '',
    this.twitter = '',
  });

  ProfileState copyWith({
    String? name,
    String? email,
    String? phone,
    String? instagram,
    String? snapchat,
    String? facebook,
    String? twitter,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      instagram: instagram ?? this.instagram,
      snapchat: snapchat ?? this.snapchat,
      facebook: facebook ?? this.facebook,
      twitter: twitter ?? this.twitter,
    );
  }
}

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(ProfileState()) {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await UserPreference.instance.getUser();

    log('User data loaded: ${user.toJson()}');

    state = ProfileState(
      name: '${user.firstName ?? ''} ${user.lastName ?? ''}',
      email: user.email ?? '',
      phone: user.phone ?? '',
      instagram: user.instagram ?? '',
      snapchat: user.snap ?? '',
      facebook: user.facebook ?? '',
      twitter: user.twitter ?? '',
    );
  }
}
