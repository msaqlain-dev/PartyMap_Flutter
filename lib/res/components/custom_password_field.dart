import 'package:flutter/material.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';

class CustomPasswordField extends StatefulWidget {
  final String? label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;

  const CustomPasswordField({
    super.key,
    this.label,
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.padding,
    this.margin,
    this.height = ResponsiveSizeUtil.size60,
    this.width = double.infinity,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size10),
        color: const Color(0xFFF0F0F0),
      ),
      child: Padding(
        padding:
            widget.padding ??
            EdgeInsets.symmetric(horizontal: ResponsiveSizeUtil.size16),
        child: TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: isObscure,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          style: TextStyle(
            fontSize: ResponsiveSizeUtil.size15,
            color: AppColor.blackColor,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: Icon(Icons.lock, color: AppColor.primaryColor),
            labelText: widget.label,
            labelStyle: TextStyle(
              fontSize: ResponsiveSizeUtil.size15,
              color: AppColor.grayColor,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility : Icons.visibility_off,
                color: AppColor.primaryColor,
              ),
              onPressed: () {
                setState(() {
                  isObscure = !isObscure;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
