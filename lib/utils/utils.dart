import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:partymap_app/res/colors/app_color.dart';

class Utils {
  static void fieldFocusChange(
    BuildContext context,
    FocusNode current,
    FocusNode nextFocus,
  ) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static void toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColor.blackColor,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.white,
    );
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    String? title,
  }) {
    final snackBar = SnackBar(
      content: Text(
        title != null ? "$title\n$message" : message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: AppColor.blackColor,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
