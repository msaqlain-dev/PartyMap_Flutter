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
    this.height,
    this.width,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? ResponsiveSizeUtil.size60,
      width: widget.width ?? double.infinity,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size10),
        color: const Color(0xFFF0F0F0),
      ),
      child: Padding(
        padding:
            widget.padding ??
            EdgeInsets.symmetric(
              horizontal: ResponsiveSizeUtil.size16,
              vertical: ResponsiveSizeUtil.size7, // Added vertical padding
            ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Icon(Icons.lock, color: AppColor.primaryColor),
            ),
            SizedBox(width: ResponsiveSizeUtil.size10),
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                obscureText: _isObscure,
                validator: widget.validator,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                style: TextStyle(
                  fontSize: ResponsiveSizeUtil.size15,
                  color: AppColor.blackColor,
                  height: 1.2, // Consistent line height
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: widget.label,
                  labelStyle: TextStyle(
                    fontSize: ResponsiveSizeUtil.size15,
                    color: AppColor.grayColor,
                    height: 1.2,
                  ),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                      color: AppColor.primaryColor,
                      size: 20, // Fixed icon size
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
