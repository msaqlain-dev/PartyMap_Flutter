import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/res/components/custom_text.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';
import 'profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        title: CustomText(
          text: "Profile",
          color: AppColor.whiteColor,
          fontSize: ResponsiveSizeUtil.size16,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColor.secondaryColor,
        foregroundColor: AppColor.whiteColor,
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveSizeUtil.scaleFactorWidth * 20,
            vertical: ResponsiveSizeUtil.scaleFactorHeight * 20,
          ),
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  backgroundColor: AppColor.whiteColor,
                  radius: ResponsiveSizeUtil.size80,
                  child: const Icon(
                    Icons.person,
                    color: AppColor.blackColor,
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _buildInfoRow(Icons.person_outline_rounded, profile.name),
              const Divider(color: AppColor.whiteColor),
              const SizedBox(height: 30),

              _buildInfoRow(Icons.email_outlined, profile.email),
              const Divider(color: AppColor.whiteColor),
              const SizedBox(height: 30),

              _buildInfoRow(Icons.phone_in_talk_rounded, profile.phone),
              const Divider(color: AppColor.whiteColor),
              const SizedBox(height: 30),

              _buildInfoRow(FontAwesomeIcons.instagram, profile.instagram),
              const Divider(color: AppColor.whiteColor),
              const SizedBox(height: 30),

              _buildInfoRow(FontAwesomeIcons.snapchat, profile.snapchat),
              const Divider(color: AppColor.whiteColor),
              const SizedBox(height: 30),

              _buildInfoRow(Icons.settings_outlined, "Settings"),
              const Divider(color: AppColor.whiteColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColor.whiteColor, size: 24),
        SizedBox(width: ResponsiveSizeUtil.scaleFactorWidth * 20),
        Expanded(
          child: CustomText(
            text: text,
            color: AppColor.whiteColor,
            fontSize: ResponsiveSizeUtil.size16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
