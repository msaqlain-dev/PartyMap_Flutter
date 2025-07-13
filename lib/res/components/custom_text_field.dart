import 'package:flutter/material.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';

// ignore: must_be_immutable
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

  double? height = ResponsiveSizeUtil.size60;
  double? width = double.infinity;

  CustomTextField({
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
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size10),
        color: const Color(0xFFF0F0F0),
      ),
      child: Padding(
        padding:
            padding ??
            EdgeInsets.symmetric(horizontal: ResponsiveSizeUtil.size16),
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
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: icon,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            labelText: label,
            labelStyle: TextStyle(
              fontSize: ResponsiveSizeUtil.size15,
              color: AppColor.grayColor,
            ),
          ),
        ),
      ),
    );
  }
}
