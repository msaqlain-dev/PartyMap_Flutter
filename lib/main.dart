import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:partymap_app/res/navigators/routes.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';

// TODO: Add your Mapbox access token here or use --dart-define
// const String accessToken = 'YOUR_MAPBOX_ACCESS_TOKEN_HERE';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure app for optimal performance
  await _configureApp();

  runApp(const ProviderScope(child: PartyMapApp()));
}

Future<void> _configureApp() async {
  try {
    // Set preferred orientations for consistency
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Configure system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Set Mapbox access token with error handling
    _configureMapbox();
  } catch (e) {
    debugPrint('App configuration error: $e');
  }
}

void _configureMapbox() {
  try {
    // Try to get token from --dart-define first
    const String? envToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

    if (envToken.isNotEmpty) {
      MapboxOptions.setAccessToken(envToken);
      debugPrint('Mapbox token set from environment');
    } else if (accessToken.isNotEmpty &&
        accessToken != 'YOUR_MAPBOX_ACCESS_TOKEN_HERE') {
      MapboxOptions.setAccessToken(accessToken);
      debugPrint('Mapbox token set from constant');
    } else {
      debugPrint(
        'WARNING: No Mapbox access token provided. Map functionality will be limited.',
      );
    }
  } catch (e) {
    debugPrint('Mapbox configuration error: $e');
  }
}

class PartyMapApp extends ConsumerWidget {
  const PartyMapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ResponsiveSizeUtil.init(context);
    
    return MaterialApp.router(
      title: 'PartyMap',
      debugShowCheckedModeBanner: false,

      // Optimized theme configuration
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primaryColor,
          brightness: Brightness.dark,
          background: AppColor.secondaryColor,
          surface: AppColor.secondaryColor,
        ),

        // App-wide styling
        scaffoldBackgroundColor: AppColor.secondaryColor,

        // AppBar theme
        appBarTheme: AppBarTheme(
          backgroundColor: AppColor.secondaryColor,
          foregroundColor: AppColor.whiteColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.whiteColor,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),

        // Bottom navigation theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColor.secondaryColor,
          selectedItemColor: AppColor.primaryColor,
          unselectedItemColor: AppColor.whiteColor,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),

        // Text theme with Nunito font
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Nunito'),
          displayMedium: TextStyle(fontFamily: 'Nunito'),
          displaySmall: TextStyle(fontFamily: 'Nunito'),
          headlineLarge: TextStyle(fontFamily: 'Nunito'),
          headlineMedium: TextStyle(fontFamily: 'Nunito'),
          headlineSmall: TextStyle(fontFamily: 'Nunito'),
          titleLarge: TextStyle(fontFamily: 'Nunito'),
          titleMedium: TextStyle(fontFamily: 'Nunito'),
          titleSmall: TextStyle(fontFamily: 'Nunito'),
          bodyLarge: TextStyle(fontFamily: 'Nunito'),
          bodyMedium: TextStyle(fontFamily: 'Nunito'),
          bodySmall: TextStyle(fontFamily: 'Nunito'),
          labelLarge: TextStyle(fontFamily: 'Nunito'),
          labelMedium: TextStyle(fontFamily: 'Nunito'),
          labelSmall: TextStyle(fontFamily: 'Nunito'),
        ),

        // Input decoration theme for consistent form styling
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF0F0F0),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),

        // Card theme
        cardTheme: CardThemeData(
          color: AppColor.secondaryColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Icon theme
        iconTheme: IconThemeData(color: AppColor.whiteColor),

        // Visual density for better touch targets
        visualDensity: VisualDensity.adaptivePlatformDensity,

        // Material 3 color scheme extensions
        extensions: <ThemeExtension<dynamic>>[
          AppColorsExtension(
            primary: AppColor.primaryColor,
            secondary: AppColor.secondaryColor,
            background: AppColor.blackColor,
            surface: AppColor.lightColor,
            onPrimary: AppColor.whiteColor,
            onSecondary: AppColor.blackColor,
            accent: AppColor.primaryColor.withOpacity(0.8),
          ),
        ],
      ),

      // Router configuration
      routerConfig: appRouter,

      builder: (context, child) {
        // Initialize ResponsiveSizeUtil once for the entire app
        ResponsiveSizeUtil.init(context);
        
        return MediaQuery(
          // Prevent text scaling issues on different devices
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling, // Updated from textScaleFactor
          ),
          child: child!,
        );
      },

      // Locale configuration
      supportedLocales: const [Locale('en', 'US')],

      // Show performance overlay in debug mode
      showPerformanceOverlay: false, // Set to true for debugging
    );
  }
}

// Custom theme extension for app-specific colors
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color onPrimary;
  final Color onSecondary;
  final Color accent;

  const AppColorsExtension({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.onPrimary,
    required this.onSecondary,
    required this.accent,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? onPrimary,
    Color? onSecondary,
    Color? accent,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
      accent: accent ?? this.accent,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;

    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t) ?? onPrimary,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t) ?? onSecondary,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
    );
  }
}

// Extension to easily access app colors from BuildContext
extension AppColorsContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}
