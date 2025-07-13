import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:partymap_app/Screens/signup_screen/signup_controller.dart';
import 'package:partymap_app/res/assets/image_assets.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/res/components/custom_password_field.dart';
import 'package:partymap_app/res/components/custom_text.dart';
import 'package:partymap_app/res/components/custom_text_field.dart';
import 'package:partymap_app/res/components/round_button.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showOptionalFields = false;

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(signupControllerProvider.notifier);
    final state = ref.watch(signupControllerProvider);

    return Scaffold(
      backgroundColor: AppColor.blackColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: ResponsiveSizeUtil.scaleFactorHeight * 20),
              Image.asset(ImageAssets.partyMapLogo, width: 250),
              SizedBox(height: ResponsiveSizeUtil.scaleFactorHeight * 20),
              CustomText(
                text: 'Signup',
                color: AppColor.primaryColor,
                fontSize: 42,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: ResponsiveSizeUtil.scaleFactorHeight * 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: state.firstNameController,
                      focusNode: state.firstNameFocusNode,
                      label: 'First Name',
                      icon: Icon(Icons.person, color: AppColor.primaryColor),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter First Name' : null,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: state.lastNameController,
                      focusNode: state.lastNameFocusNode,
                      label: 'Last Name',
                      icon: Icon(Icons.person, color: AppColor.primaryColor),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter Last Name' : null,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: state.emailController,
                      focusNode: state.emailFocusNode,
                      label: 'Email',
                      icon: Icon(Icons.email, color: AppColor.primaryColor),
                      validator: (value) =>
                          value!.isEmpty || !value.contains('@')
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    CustomPasswordField(
                      controller: state.passwordController,
                      focusNode: state.passwordFocusNode,
                      label: 'Password',
                      validator: (value) => value!.isEmpty || value.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    CustomPasswordField(
                      controller: state.confirmPasswordController,
                      focusNode: state.confirmPasswordFocusNode,
                      label: 'Confirm Password',
                      validator: (value) =>
                          value!.isEmpty ||
                              value != state.passwordController.text
                          ? 'Passwords do not match'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => setState(
                        () => _showOptionalFields = !_showOptionalFields,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _showOptionalFields ? Icons.remove : Icons.add,
                              color: AppColor.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            CustomText(
                              text: _showOptionalFields
                                  ? 'Hide additional information'
                                  : 'Add additional information',
                              color: AppColor.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Visibility(
                      visible: _showOptionalFields,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: state.phoneController,
                            focusNode: state.phoneFocusNode,
                            label: 'Phone',
                            icon: Icon(
                              Icons.phone,
                              color: AppColor.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: state.addressLine1Controller,
                            focusNode: state.addressLine1FocusNode,
                            label: 'Address Line 1',
                            icon: Icon(
                              Icons.home,
                              color: AppColor.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: state.cityController,
                            focusNode: state.cityFocusNode,
                            label: 'City',
                            icon: Icon(
                              Icons.location_city,
                              color: AppColor.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: state.stateController,
                            focusNode: state.stateFocusNode,
                            label: 'State',
                            icon: Icon(Icons.map, color: AppColor.primaryColor),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: state.zipCodeController,
                            focusNode: state.zipCodeFocusNode,
                            label: 'Zip Code',
                            icon: Icon(
                              Icons.numbers,
                              color: AppColor.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: state.instagramController,
                            focusNode: state.instagramFocusNode,
                            label: 'Instagram',
                            icon: Icon(
                              Icons.camera_alt,
                              color: AppColor.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: state.facebookController,
                            focusNode: state.facebookFocusNode,
                            label: 'Facebook',
                            icon: Icon(
                              Icons.facebook,
                              color: AppColor.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: state.twitterController,
                            focusNode: state.twitterFocusNode,
                            label: 'Twitter',
                            icon: Icon(
                              Icons.telegram,
                              color: AppColor.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: state.snapController,
                            focusNode: state.snapFocusNode,
                            label: 'Snapchat',
                            icon: Icon(
                              Icons.snapchat,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveSizeUtil.scaleFactorHeight * 20),
              RoundButton(
                title: 'Signup',
                width: double.infinity,
                height: ResponsiveSizeUtil.size60,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textColor: AppColor.primaryColor,
                buttonColor: AppColor.whiteColor,
                loading: state.loading,
                onPress: () {
                  if (_formKey.currentState!.validate()) {
                    controller.signupApi(context);
                  }
                },
              ),
              SizedBox(height: ResponsiveSizeUtil.scaleFactorHeight * 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: "Already have an account? ",
                    color: AppColor.whiteColor,
                    fontSize: ResponsiveSizeUtil.size16,
                    fontWeight: FontWeight.w500,
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: CustomText(
                      text: "Login",
                      color: AppColor.primaryColor,
                      fontSize: ResponsiveSizeUtil.size16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
