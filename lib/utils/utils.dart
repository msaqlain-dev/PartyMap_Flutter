import 'dart:async';

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
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
  }) {
    // Use microtask to ensure context is valid
    Future.microtask(() {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).clearSnackBars(); // Clear existing snackbars
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor ?? Colors.white,
                  ),
                ),
              Text(message, style: TextStyle(color: textColor ?? Colors.white)),
            ],
          ),
          duration: duration,
          backgroundColor: backgroundColor ?? Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }

  static void debounce(String key, VoidCallback callback, Duration delay) {
    _timers[key]?.cancel();
    _timers[key] = Timer(delay, callback);
  }

  static final Map<String, Timer> _timers = {};
}
