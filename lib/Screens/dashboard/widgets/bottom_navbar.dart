import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:partymap_app/Screens/dashboard/dashboard_notifier.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/res/components/custom_text.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final notifier = ref.read(dashboardProvider.notifier);

    return BottomAppBar(
      color: AppColor.secondaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            icon: FontAwesomeIcons.champagneGlasses,
            label: 'party',
            isActive: state.selectedMarkers.contains(MarkerType.parties),
            onTap: () {
              notifier.selectMarker(MarkerType.parties);
              notifier.navigateTo(0);
            },
          ),
          _navItem(
            icon: Icons.local_bar_rounded,
            label: 'bar',
            isActive: state.selectedMarkers.contains(MarkerType.bars),
            onTap: () {
              notifier.selectMarker(MarkerType.bars);
              notifier.navigateTo(0);
            },
          ),
          _navItem(
            icon: Icons.local_dining_rounded,
            label: 'restaurant',
            isActive: state.selectedMarkers.contains(MarkerType.restaurants),
            onTap: () {
              notifier.selectMarker(MarkerType.restaurants);
              notifier.navigateTo(0);
            },
          ),
          _navItem(
            icon: Icons.location_pin,
            label: 'pin',
            isActive: state.tabIndex == 2,
            onTap: () => notifier.navigateTo(2),
          ),
          _navItem(
            icon: Icons.message,
            label: 'message',
            isActive: state.tabIndex == 1,
            onTap: () => notifier.navigateTo(1),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColor.primaryColor : AppColor.whiteColor,
          ),
          CustomText(
            text: label,
            color: isActive ? AppColor.primaryColor : AppColor.whiteColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}
