import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:partymap_app/repository/auth_repository/signup_repository.dart';
import 'package:partymap_app/res/navigators/routes_name.dart';
import 'package:partymap_app/utils/utils.dart';

final signupControllerProvider =
    StateNotifierProvider<SignupController, SignupState>((ref) {
      return SignupController();
    });

class SignupState {
  final bool loading;

  // Controllers
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController phoneController;
  final TextEditingController addressLine1Controller;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController zipCodeController;
  final TextEditingController instagramController;
  final TextEditingController facebookController;
  final TextEditingController twitterController;
  final TextEditingController snapController;

  // Focus Nodes
  final FocusNode firstNameFocusNode;
  final FocusNode lastNameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final FocusNode phoneFocusNode;
  final FocusNode addressLine1FocusNode;
  final FocusNode cityFocusNode;
  final FocusNode stateFocusNode;
  final FocusNode zipCodeFocusNode;
  final FocusNode instagramFocusNode;
  final FocusNode facebookFocusNode;
  final FocusNode twitterFocusNode;
  final FocusNode snapFocusNode;

  SignupState({
    this.loading = false,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.phoneController,
    required this.addressLine1Controller,
    required this.cityController,
    required this.stateController,
    required this.zipCodeController,
    required this.instagramController,
    required this.facebookController,
    required this.twitterController,
    required this.snapController,
    required this.firstNameFocusNode,
    required this.lastNameFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.phoneFocusNode,
    required this.addressLine1FocusNode,
    required this.cityFocusNode,
    required this.stateFocusNode,
    required this.zipCodeFocusNode,
    required this.instagramFocusNode,
    required this.facebookFocusNode,
    required this.twitterFocusNode,
    required this.snapFocusNode,
  });

  factory SignupState.initial() {
    return SignupState(
      firstNameController: TextEditingController(),
      lastNameController: TextEditingController(),
      emailController: TextEditingController(),
      passwordController: TextEditingController(),
      confirmPasswordController: TextEditingController(),
      phoneController: TextEditingController(),
      addressLine1Controller: TextEditingController(),
      cityController: TextEditingController(),
      stateController: TextEditingController(),
      zipCodeController: TextEditingController(),
      instagramController: TextEditingController(),
      facebookController: TextEditingController(),
      twitterController: TextEditingController(),
      snapController: TextEditingController(),
      firstNameFocusNode: FocusNode(),
      lastNameFocusNode: FocusNode(),
      emailFocusNode: FocusNode(),
      passwordFocusNode: FocusNode(),
      confirmPasswordFocusNode: FocusNode(),
      phoneFocusNode: FocusNode(),
      addressLine1FocusNode: FocusNode(),
      cityFocusNode: FocusNode(),
      stateFocusNode: FocusNode(),
      zipCodeFocusNode: FocusNode(),
      instagramFocusNode: FocusNode(),
      facebookFocusNode: FocusNode(),
      twitterFocusNode: FocusNode(),
      snapFocusNode: FocusNode(),
    );
  }

  SignupState copyWith({bool? loading}) {
    return SignupState(
      loading: loading ?? this.loading,
      firstNameController: firstNameController,
      lastNameController: lastNameController,
      emailController: emailController,
      passwordController: passwordController,
      confirmPasswordController: confirmPasswordController,
      phoneController: phoneController,
      addressLine1Controller: addressLine1Controller,
      cityController: cityController,
      stateController: stateController,
      zipCodeController: zipCodeController,
      instagramController: instagramController,
      facebookController: facebookController,
      twitterController: twitterController,
      snapController: snapController,
      firstNameFocusNode: firstNameFocusNode,
      lastNameFocusNode: lastNameFocusNode,
      emailFocusNode: emailFocusNode,
      passwordFocusNode: passwordFocusNode,
      confirmPasswordFocusNode: confirmPasswordFocusNode,
      phoneFocusNode: phoneFocusNode,
      addressLine1FocusNode: addressLine1FocusNode,
      cityFocusNode: cityFocusNode,
      stateFocusNode: stateFocusNode,
      zipCodeFocusNode: zipCodeFocusNode,
      instagramFocusNode: instagramFocusNode,
      facebookFocusNode: facebookFocusNode,
      twitterFocusNode: twitterFocusNode,
      snapFocusNode: snapFocusNode,
    );
  }
}

class SignupController extends StateNotifier<SignupState> {
  SignupController() : super(SignupState.initial());

  final SignupRepository _api = SignupRepository();

  Future<void> signupApi(BuildContext context) async {
    state = state.copyWith(loading: true);

    final data = {
      'firstName': state.firstNameController.text,
      'lastName': state.lastNameController.text,
      'email': state.emailController.text,
      'password': state.passwordController.text,
      'addressLine1': state.addressLine1Controller.text,
      'city': state.cityController.text,
      'state': state.stateController.text,
      'zipCode': state.zipCodeController.text,
      'phone': state.phoneController.text,
      'instagram': state.instagramController.text,
      'facebook': state.facebookController.text,
      'twitter': state.twitterController.text,
      'snap': state.snapController.text,
    };

    try {
      final response = await _api.register(data);
      log("Signup response: $response");
      if (response != null) {
        if (context.mounted) {
          Utils.showSnackBar(context, 'Signup Successful', title: 'Success');
          context.go(RouteName.loginScreen);
        }
      } else {
        if (context.mounted) {
          Utils.showSnackBar(
            context,
            'User already exists, please try different email!',
            title: 'Error',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Utils.showSnackBar(
          context,
          'User already exists, please try different email!',
          title: 'Error',
        );
      }
    } finally {
      state = state.copyWith(loading: false);
    }
  }
}
