import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:partymap_app/Screens/home/home_controller.dart';
import 'package:partymap_app/Screens/home/widgets/location_search_controller.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';

class LocationSearchWidget extends ConsumerWidget {
  const LocationSearchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationSearchProvider);
    final controller = ref.read(locationSearchProvider.notifier);
    final mapController = ref.read(mapControllerProvider.notifier);

    return Column(
      children: [
        if (state.showSuggestions)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColor.lightColor,
              ),
              child: ListView.builder(
                itemCount: state.suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(state.suggestions[index].name ?? 'Unknown'),
                    onTap: () {
                      mapController.updateCamera(
                        state.suggestions[index].latitude,
                        state.suggestions[index].longitude,
                        18,
                      );
                    },
                  );
                },
              ),
            ),
          )
        else
          const SizedBox(height: 160),
        Container(
          height: ResponsiveSizeUtil.size40,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size10),
            color: const Color(0xFFF0F0F0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSizeUtil.size3,
              vertical: ResponsiveSizeUtil.size7,
            ),
            child: TextFormField(
              onChanged: controller.searchLocation,
              style: TextStyle(
                fontSize: ResponsiveSizeUtil.size15,
                color: AppColor.blackColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColor.primaryColor,
                  size: 24,
                ),
                hintText: 'Search',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
