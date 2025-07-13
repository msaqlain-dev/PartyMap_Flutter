import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:partymap_app/Screens/home/home_controller.dart';
import 'package:partymap_app/Screens/home/widgets/venue_details.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/res/components/custom_text.dart';

class VenueDetailBottomSheet extends ConsumerStatefulWidget {
  final VenueDetails venueDetails;

  const VenueDetailBottomSheet({super.key, required this.venueDetails});

  @override
  ConsumerState<VenueDetailBottomSheet> createState() =>
      _VenueDetailBottomSheetState();
}

class _VenueDetailBottomSheetState
    extends ConsumerState<VenueDetailBottomSheet> {
  bool isExpanded = false;

  void _showImageModal(BuildContext context, String? imageUrl) {
    if (imageUrl == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.black54,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 50,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double maxBarHeight = 50.0;
    final venueDetails = widget.venueDetails;

    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.black.withOpacity(0.94),
        borderRadius: const BorderRadius.all(Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                ref.read(selectedVenueProvider.notifier).state = null;
              },
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: venueDetails.name ?? '',
                    fontSize: 16,
                    color: AppColor.whiteColor,
                    fontWeight: FontWeight.w800,
                  ),
                  GestureDetector(
                    onTap: () =>
                        _showImageModal(context, venueDetails.placeImage),
                    child: Container(
                      height: 48,
                      width: 48,
                      color: AppColor.grayColor,
                      child: venueDetails.placeImage != null
                          ? Image.network(
                              venueDetails.placeImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                            )
                          : const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  CustomText(
                    text: venueDetails.website ?? '',
                    fontSize: 8,
                    color: AppColor.whiteColor,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: venueDetails.time ?? '',
                    fontSize: 16,
                    color: AppColor.whiteColor,
                    fontWeight: FontWeight.w800,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            _showImageModal(context, venueDetails.partyImage),
                        child: Container(
                          height: 48,
                          width: 48,
                          color: AppColor.grayColor,
                          child: venueDetails.partyImage != null
                              ? Image.network(
                                  venueDetails.partyImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                )
                              : const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: _getDescriptionText(),
                              fontSize: 8,
                              color: AppColor.whiteColor,
                            ),
                            if (_needsReadMore())
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isExpanded = !isExpanded;
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "Read more...",
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Spacer(),
              Column(
                children: [
                  CustomText(
                    text: 'Tickets',
                    color: AppColor.whiteColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 48),
                  CustomText(
                    text: 'Time',
                    color: AppColor.whiteColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicWidth(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(venueDetails.data?.length ?? 0, (
                        index,
                      ) {
                        final dataValue = venueDetails.data![index];
                        final maxValue = venueDetails.data!.reduce(
                          (a, b) => a > b ? a : b,
                        );
                        final barHeight = (dataValue / maxValue) * maxBarHeight;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomText(
                                text: dataValue.toString(),
                                color: AppColor.whiteColor,
                                fontSize: 8,
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: 12,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color:
                                      venueDetails.times![index].endsWith('AM')
                                      ? Colors.blue
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 5),
                              CustomText(
                                text: venueDetails.times![index],
                                color: AppColor.whiteColor,
                                fontSize: 8,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 50),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  String _getDescriptionText() {
    if (isExpanded || widget.venueDetails.description!.length <= 150) {
      return widget.venueDetails.description ?? '';
    } else {
      return "${widget.venueDetails.description?.substring(0, 150)}...";
    }
  }

  bool _needsReadMore() {
    return widget.venueDetails.description!.length > 150;
  }
}
