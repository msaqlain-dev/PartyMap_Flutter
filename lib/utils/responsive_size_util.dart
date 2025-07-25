import 'package:flutter/material.dart';

class ResponsiveSizeUtil {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double safeWidth;
  static late double safeHeight;
  static late double scaleFactorWidth;
  static late double scaleFactorHeight;

  // Base design dimensions - adjust based on your design
  static const double baseWidth = 392.0;
  static const double baseHeight = 820.0;

  // Common sizes - optimized for performance
  static late double size0;
  static late double size2;
  static late double size3;
  static late double size4;
  static late double size5;
  static late double size6;
  static late double size7;
  static late double size8;
  static late double size10;
  static late double size12;
  static late double size14;
  static late double size15;
  static late double size16;
  static late double size17;
  static late double size18;
  static late double size19;
  static late double size20;
  static late double size22;
  static late double size23;
  static late double size24;
  static late double size25;
  static late double size26;
  static late double size28;
  static late double size30;
  static late double size32;
  static late double size34;
  static late double size35;
  static late double size36;
  static late double size38;
  static late double size40;
  static late double size42;
  static late double size44;
  static late double size48;
  static late double size50;
  static late double size52;
  static late double size54;
  static late double size56;
  static late double size60;
  static late double size64;
  static late double size68;
  static late double size72;
  static late double size76;
  static late double size80;
  static late double size90;
  static late double size96;
  static late double size100;
  static late double size110;
  static late double size120;
  static late double size140;
  static late double size160;
  static late double size180;
  static late double size200;
  static late double size220;
  static late double size225;
  static late double size230;
  static late double size240;
  static late double size245;
  static late double size250;
  static late double size260;
  static late double size270;
  static late double size280;
  static late double size285;
  static late double size290;
  static late double size300;
  static late double size310;
  static late double size320;
  static late double size363;
  static late double size380;

  static bool _isInitialized = false;

  static void init(BuildContext context) {
    if (_isInitialized) return; // Prevent multiple initializations

    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    double safeAreaWidth =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    double safeAreaHeight =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeWidth = (screenWidth - safeAreaWidth);
    safeHeight = (screenHeight - safeAreaHeight);

    // Improved scale factor calculation for better consistency
    scaleFactorHeight = (safeHeight / baseHeight).clamp(0.5, 2.0);
    scaleFactorWidth = (safeWidth / baseWidth).clamp(0.5, 2.0);

    // Apply smoothing for very small screens
    if (scaleFactorHeight < 1) {
      double diff = (1 - scaleFactorHeight) * 0.5; // Reduced multiplier
      scaleFactorHeight += diff;
    }
    if (scaleFactorWidth < 1) {
      double diff = (1 - scaleFactorWidth) * 0.5; // Reduced multiplier
      scaleFactorWidth += diff;
    }

    _initializeSizes();
    _isInitialized = true;
  }

  static void _initializeSizes() {
    // Use height factor for consistent sizing
    size0 = 0;
    size2 = scaleFactorHeight * 2;
    size3 = scaleFactorHeight * 3;
    size4 = scaleFactorHeight * 4;
    size5 = scaleFactorHeight * 5;
    size6 = scaleFactorHeight * 6;
    size7 = scaleFactorHeight * 7;
    size8 = scaleFactorHeight * 8;
    size10 = scaleFactorHeight * 10;
    size12 = scaleFactorHeight * 12;
    size14 = scaleFactorHeight * 14;
    size15 = scaleFactorHeight * 15;
    size16 = scaleFactorHeight * 16;
    size17 = scaleFactorHeight * 17;
    size18 = scaleFactorHeight * 18;
    size19 = scaleFactorHeight * 19;
    size20 = scaleFactorHeight * 20;
    size22 = scaleFactorHeight * 22;
    size23 = scaleFactorHeight * 23;
    size24 = scaleFactorHeight * 24;
    size25 = scaleFactorHeight * 25;
    size26 = scaleFactorHeight * 26;
    size28 = scaleFactorHeight * 28;
    size30 = scaleFactorHeight * 30;
    size32 = scaleFactorHeight * 32;
    size34 = scaleFactorHeight * 34;
    size35 = scaleFactorHeight * 35;
    size36 = scaleFactorHeight * 36;
    size38 = scaleFactorHeight * 38;
    size40 = scaleFactorHeight * 40;
    size42 = scaleFactorHeight * 42;
    size44 = scaleFactorHeight * 44;
    size48 = scaleFactorHeight * 48;
    size50 = scaleFactorHeight * 50;
    size52 = scaleFactorHeight * 52;
    size54 = scaleFactorHeight * 54;
    size56 = scaleFactorHeight * 56;
    size60 = scaleFactorHeight * 60;
    size64 = scaleFactorHeight * 64;
    size68 = scaleFactorHeight * 68;
    size72 = scaleFactorHeight * 72;
    size76 = scaleFactorHeight * 76;
    size80 = scaleFactorHeight * 80;
    size90 = scaleFactorHeight * 90;
    size96 = scaleFactorHeight * 96;
    size100 = scaleFactorHeight * 100;
    size110 = scaleFactorHeight * 110;
    size120 = scaleFactorHeight * 120;
    size140 = scaleFactorHeight * 140;
    size160 = scaleFactorHeight * 160;
    size180 = scaleFactorHeight * 180;
    size200 = scaleFactorHeight * 200;
    size220 = scaleFactorHeight * 220;
    size225 = scaleFactorHeight * 225;
    size230 = scaleFactorHeight * 230;
    size240 = scaleFactorHeight * 240;
    size245 = scaleFactorHeight * 245;
    size250 = scaleFactorHeight * 250;
    size260 = scaleFactorHeight * 260;
    size270 = scaleFactorHeight * 270;
    size280 = scaleFactorHeight * 280;
    size285 = scaleFactorHeight * 285;
    size290 = scaleFactorHeight * 290;
    size300 = scaleFactorHeight * 300;
    size310 = scaleFactorHeight * 310;
    size320 = scaleFactorHeight * 320;
    size363 = scaleFactorHeight * 363;
    size380 = scaleFactorHeight * 380;
  }

  // Dynamic sizing methods for values not in the predefined list
  static double getScaledSizeWidth(double size) {
    return (size * scaleFactorWidth).clamp(size * 0.5, size * 2.0);
  }

  static double getScaledSizeHeight(double size) {
    return (size * scaleFactorHeight).clamp(size * 0.5, size * 2.0);
  }

  // Helper methods for responsive design
  static double width(double size) => getScaledSizeWidth(size);
  static double height(double size) => getScaledSizeHeight(size);
  static double font(double size) => getScaledSizeHeight(size);

  // Device type helpers
  static bool get isTablet => screenWidth > 768;
  static bool get isSmallScreen => screenWidth < 360;
  static bool get isLargeScreen => screenWidth > 414;

  // Reset method for testing or dynamic theme changes
  static void reset() {
    _isInitialized = false;
  }
}

class Spacing {
  static EdgeInsetsGeometry zero = EdgeInsets.zero;

  static EdgeInsetsGeometry only({
    double top = 0,
    double right = 0,
    double bottom = 0,
    double left = 0,
    bool withResponsive = true,
  }) {
    if (withResponsive) {
      return EdgeInsets.only(
        left: ResponsiveSizeUtil.getScaledSizeWidth(left),
        right: ResponsiveSizeUtil.getScaledSizeWidth(right),
        top: ResponsiveSizeUtil.getScaledSizeHeight(top),
        bottom: ResponsiveSizeUtil.getScaledSizeHeight(bottom),
      );
    } else {
      return EdgeInsets.only(
        left: left,
        right: right,
        top: top,
        bottom: bottom,
      );
    }
  }

  static EdgeInsetsGeometry fromLTRB(
    double left,
    double top,
    double right,
    double bottom, {
    bool withResponsive = true,
  }) {
    return Spacing.only(
      bottom: bottom,
      top: top,
      right: right,
      left: left,
      withResponsive: withResponsive,
    );
  }

  static EdgeInsetsGeometry all(double spacing, {bool withResponsive = true}) {
    return Spacing.only(
      bottom: spacing,
      top: spacing,
      right: spacing,
      left: spacing,
      withResponsive: withResponsive,
    );
  }

  static EdgeInsetsGeometry left(double spacing, {bool withResponsive = true}) {
    return Spacing.only(left: spacing, withResponsive: withResponsive);
  }

  static EdgeInsetsGeometry top(double spacing, {bool withResponsive = true}) {
    return Spacing.only(top: spacing, withResponsive: withResponsive);
  }

  static EdgeInsetsGeometry right(
    double spacing, {
    bool withResponsive = true,
  }) {
    return Spacing.only(right: spacing, withResponsive: withResponsive);
  }

  static EdgeInsetsGeometry bottom(
    double spacing, {
    bool withResponsive = true,
  }) {
    return Spacing.only(bottom: spacing, withResponsive: withResponsive);
  }

  static EdgeInsetsGeometry horizontal(
    double spacing, {
    bool withResponsive = true,
  }) {
    return Spacing.only(
      left: spacing,
      right: spacing,
      withResponsive: withResponsive,
    );
  }

  static EdgeInsetsGeometry vertical(
    double spacing, {
    bool withResponsive = true,
  }) {
    return Spacing.only(
      top: spacing,
      bottom: spacing,
      withResponsive: withResponsive,
    );
  }

  static EdgeInsetsGeometry symmetric({
    double vertical = 0,
    double horizontal = 0,
    bool withResponsive = true,
  }) {
    return Spacing.only(
      top: vertical,
      right: horizontal,
      left: horizontal,
      bottom: vertical,
      withResponsive: withResponsive,
    );
  }
}
