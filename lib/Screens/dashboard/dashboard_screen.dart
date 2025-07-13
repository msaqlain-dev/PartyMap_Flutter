import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:partymap_app/Screens/dashboard/widgets/bottom_navbar.dart';
import 'package:partymap_app/Screens/home/home_screen.dart';
import 'package:partymap_app/Screens/message/message_screen.dart';
import 'package:partymap_app/Screens/pin/pin_screen.dart';
import 'package:partymap_app/Screens/dashboard/dashboard_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(
      dashboardProvider.select((state) => state.tabIndex),
    );

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: tabIndex,
          children: const [HomeScreen(), MessageScreen(), PinScreen()],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
