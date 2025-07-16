import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:partymap_app/res/navigators/routes.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set Mapbox access token
  const accessToken =
      '';
  MapboxOptions.setAccessToken(accessToken);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set Mapbox access token from --dart-define
    // const mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
    // MapboxOptions.setAccessToken(mapboxAccessToken);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Initialize responsive utility
        ResponsiveSizeUtil.init(context);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Party Map',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            extensions: const <ThemeExtension<dynamic>>[
              AppCompatTheme(
                primaryColor: Colors.deepPurple,
                accentColor: Colors.deepPurpleAccent,
              ),
            ],
          ),
          routerConfig: appRouter,
        );
      },
    );
  }
}

class AppCompatTheme extends ThemeExtension<AppCompatTheme> {
  final Color primaryColor;
  final Color accentColor;

  const AppCompatTheme({required this.primaryColor, required this.accentColor});

  @override
  ThemeExtension<AppCompatTheme> copyWith({
    Color? primaryColor,
    Color? accentColor,
  }) {
    return AppCompatTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  @override
  ThemeExtension<AppCompatTheme> lerp(
    ThemeExtension<AppCompatTheme>? other,
    double t,
  ) {
    if (other is! AppCompatTheme) return this;
    return AppCompatTheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
    );
  }
}
