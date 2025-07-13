import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:partymap_app/res/assets/image_assets.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/res/components/custom_password_field.dart';
import 'package:partymap_app/res/components/custom_text.dart';
import 'package:partymap_app/res/components/round_button.dart';
import 'package:partymap_app/res/components/custom_text_field.dart';
import 'package:partymap_app/res/navigators/routes_name.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';
import 'package:partymap_app/Screens/login_screen/login_controller.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginControllerProvider);
    final loginController = ref.read(loginControllerProvider.notifier);
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColor.blackColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: 50),
              Image.asset(ImageAssets.partyMapLogo, width: 250),
              SizedBox(height: ResponsiveSizeUtil.scaleFactorHeight * 50),
              CustomText(
                text: 'Login',
                color: AppColor.primaryColor,
                fontSize: 42,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: ResponsiveSizeUtil.scaleFactorHeight * 50),
              CustomTextField(
                controller: loginState.emailController,
                focusNode: loginState.emailFocusNode,
                label: 'Email',
                icon: Icon(Icons.email, color: AppColor.primaryColor),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomPasswordField(
                controller: loginState.passwordController,
                focusNode: loginState.passwordFocusNode,
                label: 'Password',
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: ResponsiveSizeUtil.scaleFactorHeight * 40),
              RoundButton(
                title: 'Login',
                width: double.infinity,
                height: ResponsiveSizeUtil.size60,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textColor: AppColor.primaryColor,
                buttonColor: AppColor.whiteColor,
                loading: loginState.loading,
                onPress: () {
                  if (_formKey.currentState!.validate()) {
                    loginController.loginApi(context);
                  }
                },
              ),
              SizedBox(height: ResponsiveSizeUtil.scaleFactorHeight * 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: "Don't have an account? ",
                    color: AppColor.whiteColor,
                    fontSize: ResponsiveSizeUtil.size16,
                    fontWeight: FontWeight.w500,
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push(RouteName.signupScreen);
                    },
                    child: CustomText(
                      text: "Signup",
                      color: AppColor.primaryColor,
                      fontSize: ResponsiveSizeUtil.size16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
