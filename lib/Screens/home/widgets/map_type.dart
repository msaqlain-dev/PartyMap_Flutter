import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:partymap_app/Screens/home/home_controller.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/res/components/custom_text.dart';

class MapTypeDropdown extends ConsumerWidget {
  const MapTypeDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapType = ref.watch(mapControllerProvider.select((s) => s.mapType));
    final mapController = ref.read(mapControllerProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.lightColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        elevation: 0,
        isDense: true,
        underline: Container(),
        items: ["Dark", "Satellite"].map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: CustomText(
              text: '   $value',
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          );
        }).toList(),
        onChanged: (value) => mapController.updateMapType(value!),
        value: mapType,
      ),
    );
  }
}
