import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:partymap_app/res/navigators/routes.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set Mapbox access token
  MapboxOptions.setAccessToken(
    'sk.eyJ1IjoicGFydHltYXAiLCJhIjoiY20wa3hhZnRsMTZ2MzJqc2x4ZmlnYTZrZCJ9.xfMKMVT6UkBcVm32KYH53w',
  );

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
          ),
          routerConfig: appRouter,
        );
      },
    );
  }
}

