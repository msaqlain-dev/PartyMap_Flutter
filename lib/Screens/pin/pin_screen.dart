import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/res/components/custom_text.dart';
import 'package:partymap_app/res/components/round_button.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';
import 'pin_controller.dart';

class PinScreen extends ConsumerWidget {
  const PinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final controller = ref.read(pinControllerProvider.notifier);
    final title = ref.watch(pinControllerProvider).title ?? "";
    final isLoggedIn = ref.watch(pinControllerProvider).isLoggedIn;
    final controller = ref.read(pinControllerProvider.notifier);
    controller.checkLoginStatus();

    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.secondaryColor,
        foregroundColor: AppColor.whiteColor,
        title: CustomText(
          text: title,
          color: AppColor.whiteColor,
          fontSize: ResponsiveSizeUtil.size16,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push("/profile_screen");
            },
            icon: const Icon(Icons.person_outline_rounded),
            iconSize: 24,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColor.secondaryColor,
          border: const Border(bottom: BorderSide(color: AppColor.whiteColor)),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(ResponsiveSizeUtil.size40),
            bottomRight: Radius.circular(ResponsiveSizeUtil.size40),
          ),
        ),
        child: Center(
          child: RoundButton(
            title: isLoggedIn ? 'Logout' : 'Login',
            buttonColor: AppColor.primaryColor,
            height: ResponsiveSizeUtil.scaleFactorHeight * 50,
            width: ResponsiveSizeUtil.scaleFactorWidth * 100,
            buttonRadius: 100,
            textColor: AppColor.whiteColor,
            fontSize: ResponsiveSizeUtil.size16,
            fontWeight: FontWeight.w700,
            onPress: () {
              if (ref.watch(pinControllerProvider).isLoggedIn) {
                ref.read(pinControllerProvider.notifier).logout(context);
              } else {
                context.go("/profile_screen");
              }
            },
          ),
        ),
      ),
    );
  }
}
