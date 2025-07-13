import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:partymap_app/Screens/splash_screen/splash_services.dart';
import 'package:partymap_app/res/assets/image_assets.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      ref.read(splashServiceProvider).checkLoginStatus(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // match native splash background
      body: Center(child: Image.asset(ImageAssets.partyMapLogo, width: 250)),
    );
  }
}
