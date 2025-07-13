import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final UserPreference _userPreference = UserPreference();

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

      final userModel = UserModel(token: response['token'], isLogin: true);

      await _userPreference.saveUser(userModel);

      // ✅ SAFELY show snackbar and navigate using a microtask
      Future.microtask(() {
        if (context.mounted) {
          Utils.showSnackBar(context, 'Login Successfully', title: 'Login');
          Navigator.pushReplacementNamed(context, RouteName.dashboardScreen);
        }
      });
    } catch (error) {
      if (context.mounted) {
        Utils.showSnackBar(context, error.toString(), title: 'Error');
      }
    } finally {
      state = state.copyWith(loading: false);
    }
  }
}
