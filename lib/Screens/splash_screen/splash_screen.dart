import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:partymap_app/Screens/splash_screen/splash_services.dart';
import 'package:partymap_app/res/assets/image_assets.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations for better UX
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    // Initialize responsive sizing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ResponsiveSizeUtil.init(context);
      _animationController.forward();
      
      // Check login status after animation starts
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    try {
      // Add minimum splash duration for better UX
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 2000)), // Minimum 2 seconds
        ref.read(splashServiceProvider).checkLoginStatus(context),
      ]);
    } catch (e) {
      // Handle any errors gracefully
      debugPrint('Splash screen error: $e');
      if (mounted) {
        ref.read(splashServiceProvider).navigateToLogin(context);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.blackColor, // Consistent with app theme
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with responsive sizing
                    Image.asset(
                      ImageAssets.partyMapLogo,
                      width: ResponsiveSizeUtil.size250,
                      height: ResponsiveSizeUtil.size250,
                      fit: BoxFit.contain,
                    ),
                    
                    SizedBox(height: ResponsiveSizeUtil.size40),
                    
                    // Loading indicator
                    SizedBox(
                      width: ResponsiveSizeUtil.size30,
                      height: ResponsiveSizeUtil.size30,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColor.primaryColor,
                        ),
                        strokeWidth: 2.0,
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveSizeUtil.size20),
                    
                    // App name or tagline
                    Text(
                      'PartyMap',
                      style: TextStyle(
                        color: AppColor.whiteColor,
                        fontSize: ResponsiveSizeUtil.size24,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Nunito',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:partymap_app/Screens/splash_screen/splash_services.dart';
// import 'package:partymap_app/res/assets/image_assets.dart';

// class SplashScreen extends ConsumerStatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   ConsumerState<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends ConsumerState<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       // ignore: use_build_context_synchronously
//       ref.read(splashServiceProvider).checkLoginStatus(context);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black, // match native splash background
//       body: Center(child: Image.asset(ImageAssets.partyMapLogo, width: 250)),
//     );
//   }
// }
