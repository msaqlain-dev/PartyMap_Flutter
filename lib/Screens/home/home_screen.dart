import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:partymap_app/Screens/home/home_controller.dart';
import 'package:partymap_app/Screens/home/widgets/location_search_widget.dart';
import 'package:partymap_app/Screens/home/widgets/venue_detail_bottomsheet.dart';
import 'package:partymap_app/res/assets/image_assets.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/res/navigators/routes_name.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true; // Keep state alive when switching tabs

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize responsive sizing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ResponsiveSizeUtil.init(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Optimize map rendering based on app lifecycle
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // Pause heavy operations when app is not visible
        break;
      case AppLifecycleState.resumed:
        // Resume operations when app becomes visible
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final selectedVenue = ref.watch(selectedVenueProvider);
    final mapController = ref.read(mapControllerProvider.notifier);
    final isLoading = ref.watch(
      mapControllerProvider.select((s) => s.isLoading),
    );

    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              color: AppColor.secondaryColor,
              border: const Border(
                bottom: BorderSide(color: AppColor.whiteColor),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(ResponsiveSizeUtil.size40),
                bottomRight: Radius.circular(ResponsiveSizeUtil.size40),
              ),
            ),
            child: Stack(
              children: [
                // Optimized Map Widget
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(ResponsiveSizeUtil.size40),
                    bottomRight: Radius.circular(ResponsiveSizeUtil.size40),
                  ),
                  child: RepaintBoundary(
                    child: MapWidget(
                      key: const ValueKey("partyMap"),
                      onMapCreated: mapController.onMapCreated,
                      cameraOptions: CameraOptions(
                        center: Point(
                          coordinates: Position(-115.1398, 36.1699),
                        ),
                        zoom: 10,
                        pitch: 75.0,
                      ),
                      styleUri:
                          "mapbox://styles/partymap/cm83sl12w001601qzgf55fhqt",
                    ),
                  ),
                ),

                // Loading indicator
                if (isLoading)
                  Positioned(
                    top: ResponsiveSizeUtil.height(100),
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(ResponsiveSizeUtil.size16),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(
                            ResponsiveSizeUtil.size10,
                          ),
                        ),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Back button - Positioned absolutely for better performance
                Positioned(
                  top: MediaQuery.of(context).padding.top + 5,
                  left: 0,
                  child: SafeArea(
                    child: IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(ResponsiveSizeUtil.size6),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(
                            ResponsiveSizeUtil.size6,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColor.whiteColor,
                          size: 20,
                        ),
                      ),
                      onPressed: () => context.push(RouteName.loginScreen),
                    ),
                  ),
                ),

                // App Logo (bottom left) - Optimized positioning
                Positioned(
                  bottom: ResponsiveSizeUtil.size20,
                  left: ResponsiveSizeUtil.size20,
                  child: RepaintBoundary(
                    child: Container(
                      width: ResponsiveSizeUtil.size40,
                      height: ResponsiveSizeUtil.size40,
                      decoration: BoxDecoration(
                        color: AppColor.lightColor,
                        borderRadius: BorderRadius.circular(
                          ResponsiveSizeUtil.size6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(ResponsiveSizeUtil.size6),
                        child: Image.asset(
                          ImageAssets.partyMapLogoPink,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                // Search box and suggestions (bottom center) - Constrained properly
                Positioned(
                  bottom: ResponsiveSizeUtil.size20,
                  left: ResponsiveSizeUtil.size72,
                  right: ResponsiveSizeUtil.size20,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: ResponsiveSizeUtil.height(200),
                      minHeight: ResponsiveSizeUtil.size40,
                    ),
                    child: const LocationSearchWidget(),
                  ),
                ),

                // Venue Detail Bottom Sheet - Optimized with proper constraints
                if (selectedVenue != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                            constraints.maxHeight * 0.6, // Max 60% of screen
                      ),
                      child: VenueDetailBottomSheet(
                        venueDetails: selectedVenue,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// import 'package:partymap_app/Screens/home/home_controller.dart';
// import 'package:partymap_app/Screens/home/widgets/location_search_widget.dart';
// import 'package:partymap_app/Screens/home/widgets/venue_detail_bottomsheet.dart';
// import 'package:partymap_app/res/assets/image_assets.dart';
// import 'package:partymap_app/res/colors/app_color.dart';
// import 'package:partymap_app/res/navigators/routes_name.dart';
// import 'package:partymap_app/utils/responsive_size_util.dart';

// class HomeScreen extends ConsumerWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final selectedVenue = ref.watch(selectedVenueProvider);
//     final mapController = ref.read(mapControllerProvider.notifier);

//     return Scaffold(
//       backgroundColor: AppColor.secondaryColor,
//       body: Container(
//         decoration: BoxDecoration(
//           color: AppColor.secondaryColor,
//           border: const Border(bottom: BorderSide(color: AppColor.whiteColor)),
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(ResponsiveSizeUtil.size40),
//             bottomRight: Radius.circular(ResponsiveSizeUtil.size40),
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Map
//             ClipRRect(
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(ResponsiveSizeUtil.size40),
//                 bottomRight: Radius.circular(ResponsiveSizeUtil.size40),
//               ),
//               child: MapWidget(
//                 key: const ValueKey("partyMap"),
//                 onMapCreated: mapController.onMapCreated,
//                 cameraOptions: CameraOptions(
//                   center: Point(coordinates: Position(-115.1398, 36.1699)),
//                   zoom: 10,
//                   pitch: 75.0,
//                 ),
//                 styleUri: "mapbox://styles/partymap/cm83sl12w001601qzgf55fhqt",
//                 // styleUri: MapboxStyles.STANDARD,
//               ),
//             ),

//             // Back button
//             Positioned(
//               top: 25,
//               left: 0,
//               child: IconButton(
//                 icon: const Icon(
//                   Icons.arrow_back_ios_new_rounded,
//                   color: AppColor.whiteColor,
//                   weight: 10,
//                 ),
//                 onPressed: () => context.push(RouteName.loginScreen),
//               ),
//             ),

//             // App Logo (bottom left)
//             Positioned(
//               bottom: ResponsiveSizeUtil.size20,
//               left: ResponsiveSizeUtil.size20,
//               child: Container(
//                 width: ResponsiveSizeUtil.size40,
//                 height: ResponsiveSizeUtil.size40,
//                 decoration: BoxDecoration(
//                   color: AppColor.lightColor,
//                   borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size6),
//                 ),
//                 child: Image.asset(
//                   ImageAssets.partyMapLogoPink,
//                   width: ResponsiveSizeUtil.size15,
//                 ),
//               ),
//             ),

//             // Search box and suggestions (bottom center)
//             Positioned(
//               bottom: ResponsiveSizeUtil.size20,
//               left: ResponsiveSizeUtil.size72,
//               right: ResponsiveSizeUtil.size20,
//               child: SizedBox(
//                 height: ResponsiveSizeUtil
//                     .size200, // Increased to accommodate scrolling
//                 child: LocationSearchWidget(),
//               ),
//             ),

//             // Venue Detail Bottom Sheet
//             if (selectedVenue != null)
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: VenueDetailBottomSheet(venueDetails: selectedVenue),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
