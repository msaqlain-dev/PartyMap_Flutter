import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';

class Utils {
  // Debounce timers for performance optimization
  static final Map<String, Timer> _timers = {};

  static void fieldFocusChange(
    BuildContext context,
    FocusNode current,
    FocusNode nextFocus,
  ) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  // Enhanced toast message with better styling and responsiveness
  static void toastMessage(
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast length = Toast.LENGTH_SHORT,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
  }) {
    try {
      Fluttertoast.showToast(
        msg: message,
        toastLength: length,
        gravity: gravity,
        timeInSecForIosWeb: length == Toast.LENGTH_LONG ? 5 : 3,
        backgroundColor:
            backgroundColor ?? AppColor.blackColor.withOpacity(0.9),
        textColor: textColor ?? AppColor.whiteColor,
        fontSize: fontSize ?? ResponsiveSizeUtil.size15,
        webBgColor:
            backgroundColor?.toString() ??
            AppColor.blackColor.withOpacity(0.9).toString(),
        webPosition: gravity == ToastGravity.TOP
            ? "top"
            : gravity == ToastGravity.CENTER
            ? "center"
            : "bottom",
        webShowClose: true,
      );
    } catch (e) {
      debugPrint('Toast error: $e');
      // Fallback to debug print if toast fails
      debugPrint('Toast message: $message');
    }
  }

  // Success toast with green background
  static void toastSuccess(String message) {
    toastMessage(
      message,
      backgroundColor: Colors.green.withOpacity(0.9),
      textColor: Colors.white,
    );
  }

  // Error toast with red background
  static void toastError(String message) {
    toastMessage(
      message,
      backgroundColor: Colors.red.withOpacity(0.9),
      textColor: Colors.white,
      length: Toast.LENGTH_LONG,
    );
  }

  // Warning toast with orange background
  static void toastWarning(String message) {
    toastMessage(
      message,
      backgroundColor: Colors.orange.withOpacity(0.9),
      textColor: Colors.white,
    );
  }

  // Info toast with blue background
  static void toastInfo(String message) {
    toastMessage(
      message,
      backgroundColor: Colors.blue.withOpacity(0.9),
      textColor: Colors.white,
    );
  }

  // Enhanced snackbar with better performance and styling
  static void showSnackBar(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    SnackBarAction? action,
    bool dismissible = true,
  }) {
    // Use microtask to ensure context is valid
    Future.microtask(() {
      if (!context.mounted) return;

      try {
        // Clear existing snackbars to prevent overlap
        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveSizeUtil.size16,
                      color: textColor ?? AppColor.whiteColor,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  SizedBox(height: ResponsiveSizeUtil.size4),
                ],
                Text(
                  message,
                  style: TextStyle(
                    fontSize: ResponsiveSizeUtil.size14,
                    color: textColor ?? AppColor.whiteColor,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
            duration: duration,
            backgroundColor:
                backgroundColor ?? AppColor.blackColor.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size10),
            ),
            margin: EdgeInsets.all(ResponsiveSizeUtil.size16),
            elevation: 6,
            action: action,
            dismissDirection: dismissible
                ? DismissDirection.horizontal
                : DismissDirection.none,
            showCloseIcon: dismissible,
            closeIconColor: textColor ?? AppColor.whiteColor,
          ),
        );
      } catch (e) {
        debugPrint('SnackBar error: $e');
        // Fallback to toast if snackbar fails
        toastMessage(title != null ? '$title: $message' : message);
      }
    });
  }

  // Success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) {
    showSnackBar(
      context,
      message,
      title: title ?? 'Success',
      backgroundColor: Colors.green.withOpacity(0.9),
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  // Error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) {
    showSnackBar(
      context,
      message,
      title: title ?? 'Error',
      backgroundColor: Colors.red.withOpacity(0.9),
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  // Warning snackbar
  static void showWarningSnackBar(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) {
    showSnackBar(
      context,
      message,
      title: title ?? 'Warning',
      backgroundColor: Colors.orange.withOpacity(0.9),
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  // Info snackbar
  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) {
    showSnackBar(
      context,
      message,
      title: title ?? 'Info',
      backgroundColor: Colors.blue.withOpacity(0.9),
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  // Debounce utility for performance optimization
  static void debounce(String key, VoidCallback callback, Duration delay) {
    _timers[key]?.cancel();
    _timers[key] = Timer(delay, callback);
  }

  // Throttle utility for limiting function calls
  static void throttle(String key, VoidCallback callback, Duration duration) {
    if (_timers[key]?.isActive == true) return;

    callback();
    _timers[key] = Timer(duration, () {
      _timers.remove(key);
    });
  }

  // Clean up timers (call this when disposing controllers)
  static void cancelAllTimers() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  // Cancel specific timer
  static void cancelTimer(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  // Show loading dialog
  static void showLoadingDialog(
    BuildContext context, {
    String message = 'Loading...',
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => PopScope(
        canPop: barrierDismissible,
        child: AlertDialog(
          backgroundColor: AppColor.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColor.primaryColor,
                ),
              ),
              SizedBox(height: ResponsiveSizeUtil.size20),
              Text(
                message,
                style: TextStyle(
                  color: AppColor.whiteColor,
                  fontSize: ResponsiveSizeUtil.size16,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  // Show confirmation dialog
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    Color? cancelColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.secondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size15),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppColor.whiteColor,
            fontSize: ResponsiveSizeUtil.size18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Nunito',
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: AppColor.whiteColor,
            fontSize: ResponsiveSizeUtil.size14,
            fontFamily: 'Nunito',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(
                color: cancelColor ?? AppColor.grayColor,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size8),
              ),
            ),
            child: Text(
              confirmText,
              style: TextStyle(
                color: AppColor.whiteColor,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone number
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(phone);
  }

  // Format currency
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
