import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:partymap_app/Screens/home/home_controller.dart';
import 'package:partymap_app/Screens/home/widgets/location_search_controller.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';

class LocationSearchWidget extends ConsumerStatefulWidget {
  const LocationSearchWidget({super.key});

  @override
  ConsumerState<LocationSearchWidget> createState() =>
      _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends ConsumerState<LocationSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _searchController.text.isEmpty) {
      // Hide suggestions when focus is lost and text is empty
      ref.read(locationSearchProvider.notifier).searchLocation('');
    }
  }

  void _onSearchChanged(String query) {
    // Debounce search to avoid excessive API calls
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(locationSearchProvider.notifier).searchLocation(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationSearchProvider);
    final mapController = ref.read(mapControllerProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Suggestions list - only show when there are suggestions
        if (state.showSuggestions && state.suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 160),
            margin: EdgeInsets.only(bottom: ResponsiveSizeUtil.size10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size10),
              color: AppColor.lightColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size10),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: state.suggestions.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Colors.grey),
                itemBuilder: (context, index) {
                  final suggestion = state.suggestions[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _searchController.text = suggestion.name ?? '';
                        _focusNode.unfocus();

                        // Update camera position
                        mapController.updateCamera(
                          suggestion.latitude,
                          suggestion.longitude,
                          18,
                        );

                        // Hide suggestions
                        ref
                            .read(locationSearchProvider.notifier)
                            .searchLocation('');
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveSizeUtil.size16,
                          vertical: ResponsiveSizeUtil.size10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColor.primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: ResponsiveSizeUtil.size10),
                            Expanded(
                              child: Text(
                                suggestion.name ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: ResponsiveSizeUtil.size15,
                                  color: AppColor.blackColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // Search input field
        Container(
          height: ResponsiveSizeUtil.size40,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size10),
            color: const Color(0xFFF0F0F0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSizeUtil.size3,
              vertical: ResponsiveSizeUtil.size7,
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveSizeUtil.size10,
                  ),
                  child: Icon(
                    Icons.search,
                    color: AppColor.primaryColor,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: _onSearchChanged,
                    style: TextStyle(
                      fontSize: ResponsiveSizeUtil.size15,
                      color: AppColor.blackColor,
                      height: 1.2,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search locations...',
                      hintStyle: TextStyle(
                        fontSize: ResponsiveSizeUtil.size15,
                        color: AppColor.grayColor,
                        height: 1.2,
                      ),
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),

                // Clear button
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColor.grayColor,
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      ref
                          .read(locationSearchProvider.notifier)
                          .searchLocation('');
                      _focusNode.unfocus();
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:partymap_app/Screens/home/home_controller.dart';
// import 'package:partymap_app/Screens/home/widgets/location_search_controller.dart';
// import 'package:partymap_app/res/colors/app_color.dart';
// import 'package:partymap_app/utils/responsive_size_util.dart';

// class LocationSearchWidget extends ConsumerWidget {
//   const LocationSearchWidget({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(locationSearchProvider);
//     final controller = ref.read(locationSearchProvider.notifier);
//     final mapController = ref.read(mapControllerProvider.notifier);

//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           if (state.showSuggestions)
//             Container(
//               constraints: BoxConstraints(
//                 maxHeight: 160,
//               ), // Cap suggestion list height
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 color: AppColor.lightColor,
//               ),
//               child: ListView.builder(
//                 shrinkWrap:
//                     true, // Prevent ListView from taking infinite height
//                 itemCount: state.suggestions.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(state.suggestions[index].name ?? 'Unknown'),
//                     onTap: () {
//                       mapController.updateCamera(
//                         state.suggestions[index].latitude,
//                         state.suggestions[index].longitude,
//                         18,
//                       );
//                     },
//                   );
//                 },
//               ),
//             )
//           else
//             const SizedBox(height: 160),
//           Container(
//             height: ResponsiveSizeUtil.size40,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size10),
//               color: const Color(0xFFF0F0F0),
//             ),
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: ResponsiveSizeUtil.size3,
//                 vertical: ResponsiveSizeUtil.size7,
//               ),
//               child: TextFormField(
//                 onChanged: controller.searchLocation,
//                 style: TextStyle(
//                   fontSize: ResponsiveSizeUtil.size15,
//                   color: AppColor.blackColor,
//                 ),
//                 decoration: InputDecoration(
//                   border: InputBorder.none,
//                   prefixIcon: Icon(
//                     Icons.search,
//                     color: AppColor.primaryColor,
//                     size: 24,
//                   ),
//                   hintText: 'Search',
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
