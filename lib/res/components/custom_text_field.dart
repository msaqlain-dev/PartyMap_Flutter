import 'package:flutter/material.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? obscuringCharacter;
  final Widget? icon;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;

  const CustomTextField({
    super.key,
    this.label,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.icon,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.height,
    this.width,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? ResponsiveSizeUtil.size60,
      width: width ?? double.infinity,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size10),
        color: const Color(0xFFF0F0F0),
      ),
      child: Padding(
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: ResponsiveSizeUtil.size16,
              vertical: ResponsiveSizeUtil.size7, // Added vertical padding
            ),
        child: Row(
          children: [
            if (icon != null) ...[
              SizedBox(width: 24, height: 24, child: icon),
              SizedBox(width: ResponsiveSizeUtil.size10),
            ],
            Expanded(
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: keyboardType,
                obscureText: obscureText,
                obscuringCharacter: obscuringCharacter ?? '•',
                readOnly: readOnly,
                onChanged: onChanged,
                onFieldSubmitted: onSubmitted,
                validator: validator,
                style: TextStyle(
                  fontSize: ResponsiveSizeUtil.size15,
                  color: AppColor.blackColor,
                  height: 1.2, // Consistent line height
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: prefixIcon,
                  suffixIcon: suffixIcon,
                  labelText: label,
                  labelStyle: TextStyle(
                    fontSize: ResponsiveSizeUtil.size15,
                    color: AppColor.grayColor,
                    height: 1.2,
                  ),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
