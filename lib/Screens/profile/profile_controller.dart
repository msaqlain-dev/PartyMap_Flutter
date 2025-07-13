import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  ProfileState({
    this.name = "Muhammad Saqlain",
    this.email = "muhammadsaqlain@gmail.com",
    this.phone = "+923153438373",
    this.instagram = "Instagram",
    this.snapchat = "Snap",
  });

  ProfileState copyWith({
    String? name,
    String? email,
    String? phone,
    String? instagram,
    String? snapchat,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      instagram: instagram ?? this.instagram,
      snapchat: snapchat ?? this.snapchat,
    );
  }
}

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(ProfileState());

  // Add any future logic like fetching from shared preferences or backend
}
