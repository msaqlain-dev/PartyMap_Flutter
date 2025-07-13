import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:partymap_app/Screens/dashboard/dashboard_screen.dart';
import 'package:partymap_app/Screens/home/home_screen.dart';
import 'package:partymap_app/Screens/login_screen/login_screen.dart';
import 'package:partymap_app/Screens/profile/profile_screen.dart';
import 'package:partymap_app/Screens/signup_screen/signup_screen.dart';
import 'package:partymap_app/Screens/splash_screen/splash_screen.dart';
import 'package:partymap_app/res/navigators/routes_name.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteName.splashScreen,
  routes: [
    GoRoute(
      path: RouteName.splashScreen,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SplashScreen()),
    ),
    GoRoute(
      path: RouteName.loginScreen,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: LoginScreen()),
    ),
    GoRoute(
      path: RouteName.signupScreen,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SignupScreen()),
    ),
    GoRoute(
      path: RouteName.dashboardScreen,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: DashboardScreen()),
    ),
    GoRoute(
      path: RouteName.homeScreen,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: HomeScreen()),
    ),
    GoRoute(
      path: RouteName.profileScreen,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ProfileScreen()),
    ),
  ],
);
