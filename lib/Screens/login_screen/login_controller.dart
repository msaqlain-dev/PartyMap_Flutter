import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:partymap_app/models/user_model.dart';
import 'package:partymap_app/repository/auth_repository/login_repository.dart';
import 'package:partymap_app/res/navigators/routes_name.dart';
import 'package:partymap_app/user_preference/user_preference_controller.dart';
import 'package:partymap_app/utils/utils.dart';

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
      return LoginController(ref);
    });

class LoginState {
  final bool loading;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;

  LoginState({
    this.loading = false,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    FocusNode? emailFocusNode,
    FocusNode? passwordFocusNode,
  }) : emailController = emailController ?? TextEditingController(),
       passwordController = passwordController ?? TextEditingController(),
       emailFocusNode = emailFocusNode ?? FocusNode(),
       passwordFocusNode = passwordFocusNode ?? FocusNode();

  LoginState copyWith({
    bool? loading,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    FocusNode? emailFocusNode,
    FocusNode? passwordFocusNode,
  }) {
    return LoginState(
      loading: loading ?? this.loading,
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      emailFocusNode: emailFocusNode ?? this.emailFocusNode,
      passwordFocusNode: passwordFocusNode ?? this.passwordFocusNode,
    );
  }
}

class LoginController extends StateNotifier<LoginState> {
  final Ref ref;
  final _api = LoginRepository();
  final UserPreference _userPreference = UserPreference.instance;

  LoginController(this.ref) : super(LoginState());

  Future<void> loginApi(BuildContext context) async {
    state = state.copyWith(loading: true);

    final data = {
      'email': state.emailController.text,
      'password': state.passwordController.text,
    };

    try {
      final response = await _api.login(data);
      log("Login response: $response");

      final user = response['user'];

      final userModel = UserModel(
        id: user['_id'],
        firstName: user['firstName'] ?? '',
        lastName: user['lastName'] ?? '',
        email: user['email'] ?? '',
        phone: user['phone'] ?? '',
        instagram: user['instagram'] ?? '',
        facebook: user['facebook'] ?? '',
        twitter: user['twitter'] ?? '',
        snap: user['snap'] ?? '',
        role: user['role'] ?? '',
        address: Address(
          addressLine1: user['address']?['addressLine1'] ?? '',
          city: user['address']?['city'] ?? '',
          state: user['address']?['state'] ?? '',
          zipCode: user['address']?['zipCode'] ?? '',
          country: user['address']?['country'] ?? '',
        ),
        token: response['token'],
        isLogin: true,
      );

      await _userPreference.saveUser(userModel);

      // ✅ SAFELY show snackbar and navigate using a microtask
      Future.microtask(() {
        if (context.mounted) {
          Utils.showSuccessSnackBar(context, 'Login Successfully', title: 'Login');
          context.push(RouteName.dashboardScreen);
        }
      });
    } catch (error) {
      if (context.mounted) {
        Utils.showErrorSnackBar(
          context,
          'Invalid email or password, please try again!',
          title: 'Failed to Login',
        );
      }
    } finally {
      state = state.copyWith(loading: false);
    }
  }
}
