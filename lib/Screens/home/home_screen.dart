import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:partymap_app/Screens/home/home_controller.dart';
import 'package:partymap_app/Screens/home/widgets/location_search_widget.dart';
import 'package:partymap_app/Screens/home/widgets/venue_detail_bottomsheet.dart';
import 'package:partymap_app/res/assets/image_assets.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/res/navigators/routes_name.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVenue = ref.watch(selectedVenueProvider);
    final mapController = ref.read(mapControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      body: Container(
        decoration: BoxDecoration(
          color: AppColor.secondaryColor,
          border: const Border(bottom: BorderSide(color: AppColor.whiteColor)),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(ResponsiveSizeUtil.size40),
            bottomRight: Radius.circular(ResponsiveSizeUtil.size40),
          ),
        ),
        child: Stack(
          children: [
            // Map
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(ResponsiveSizeUtil.size40),
                bottomRight: Radius.circular(ResponsiveSizeUtil.size40),
              ),
              child: MapWidget(
                key: const ValueKey("partyMap"),
                onMapCreated: mapController.onMapCreated,
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(-115.1398, 36.1699)),
                  zoom: 10,
                  pitch: 75.0,
                ),
                styleUri: "mapbox://styles/partymap/cm83sl12w001601qzgf55fhqt",
              ),
            ),

            // Back button
            Positioned(
              top: 25,
              left: 0,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColor.whiteColor,
                  weight: 10,
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, RouteName.loginScreen),
              ),
            ),

            // App Logo (bottom left)
            Positioned(
              bottom: ResponsiveSizeUtil.size20,
              left: ResponsiveSizeUtil.size20,
              child: Container(
                width: ResponsiveSizeUtil.size40,
                height: ResponsiveSizeUtil.size40,
                decoration: BoxDecoration(
                  color: AppColor.lightColor,
                  borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size6),
                ),
                child: Image.asset(
                  ImageAssets.partyMapLogoPink,
                  width: ResponsiveSizeUtil.size15,
                ),
              ),
            ),

            // Search box and suggestions (bottom center)
            Positioned(
              bottom: ResponsiveSizeUtil.size20,
              left: ResponsiveSizeUtil.size72,
              right: ResponsiveSizeUtil.size20,
              child: SizedBox(height: 200, child: LocationSearchWidget()),
            ),

            // Venue Detail Bottom Sheet
            if (selectedVenue != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VenueDetailBottomSheet(venueDetails: selectedVenue),
              ),
          ],
        ),
      ),
    );
  }
}
