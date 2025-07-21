import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:partymap_app/Screens/home/home_controller.dart';
import 'package:partymap_app/Screens/home/widgets/venue_details.dart';
import 'package:partymap_app/res/colors/app_color.dart';
import 'package:partymap_app/res/components/custom_text.dart';
import 'package:partymap_app/utils/responsive_size_util.dart';

class VenueDetailBottomSheet extends ConsumerStatefulWidget {
  final VenueDetails venueDetails;

  const VenueDetailBottomSheet({super.key, required this.venueDetails});

  @override
  ConsumerState<VenueDetailBottomSheet> createState() =>
      _VenueDetailBottomSheetState();
}

class _VenueDetailBottomSheetState extends ConsumerState<VenueDetailBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showImageModal(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(ResponsiveSizeUtil.size20),
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSizeUtil.size10,
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: ResponsiveSizeUtil.size40,
                right: ResponsiveSizeUtil.size20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageContainer(String? imageUrl, double size) {
    return GestureDetector(
      onTap: () => _showImageModal(context, imageUrl),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: AppColor.grayColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size6),
          border: Border.all(color: AppColor.grayColor.withOpacity(0.5)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ResponsiveSizeUtil.size6),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 24,
                  ),
                )
              : const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 24,
                ),
        ),
      ),
    );
  }

  Widget _buildTicketChart() {
    final data = widget.venueDetails.data ?? [];
    final times = widget.venueDetails.times ?? [];

    if (data.isEmpty || times.isEmpty) {
      return Container(
        height: 100,
        child: Center(
          child: CustomText(
            text: 'No ticket data available',
            color: AppColor.grayColor,
            fontSize: ResponsiveSizeUtil.size12,
          ),
        ),
      );
    }

    const double maxBarHeight = 50.0;
    final maxValue = data.reduce((a, b) => a > b ? a : b);

    if (maxValue == 0) {
      return Container(
        height: 100,
        child: Center(
          child: CustomText(
            text: 'No tickets available',
            color: AppColor.grayColor,
            fontSize: ResponsiveSizeUtil.size12,
          ),
        ),
      );
    }

    return Container(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            data.length.clamp(0, 24), // Limit to 24 hours max
            (index) {
              final dataValue = data[index];
              final barHeight = (dataValue / maxValue) * maxBarHeight;
              final isAM = times[index].toUpperCase().endsWith('AM');

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveSizeUtil.size3,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomText(
                      text: dataValue.toInt().toString(),
                      color: AppColor.whiteColor,
                      fontSize: ResponsiveSizeUtil.size10,
                    ),
                    SizedBox(height: ResponsiveSizeUtil.size3),
                    Container(
                      width: ResponsiveSizeUtil.size10,
                      height: barHeight.clamp(2.0, maxBarHeight),
                      decoration: BoxDecoration(
                        color: isAM ? Colors.blue : Colors.red,
                        borderRadius: BorderRadius.circular(
                          ResponsiveSizeUtil.size3,
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveSizeUtil.size3),
                    RotatedBox(
                      quarterTurns: 1,
                      child: CustomText(
                        text: times[index],
                        color: AppColor.whiteColor,
                        fontSize: ResponsiveSizeUtil.size8,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final venueDetails = widget.venueDetails;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.94),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ResponsiveSizeUtil.size20),
            bottom: Radius.circular(ResponsiveSizeUtil.size20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveSizeUtil.size16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                // Container(
                //   width: ResponsiveSizeUtil.size40,
                //   height: ResponsiveSizeUtil.size6,
                //   decoration: BoxDecoration(
                //     color: AppColor.grayColor,
                //     borderRadius: BorderRadius.circular(
                //       ResponsiveSizeUtil.size3,
                //     ),
                //   ),
                // ),

                // SizedBox(height: ResponsiveSizeUtil.size10),

                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(ResponsiveSizeUtil.size6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(
                          ResponsiveSizeUtil.size15,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () {
                      _animationController.reverse().then((_) {
                        ref.read(selectedVenueProvider.notifier).state = null;
                      });
                    },
                  ),
                ),

                // Content
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: venueDetails.name ?? 'Unknown Venue',
                            fontSize: ResponsiveSizeUtil.size18,
                            color: AppColor.whiteColor,
                            fontWeight: FontWeight.w800,
                          ),

                          SizedBox(height: ResponsiveSizeUtil.size10),

                          _buildImageContainer(venueDetails.placeImage, 48),

                          SizedBox(height: ResponsiveSizeUtil.size6),

                          if (venueDetails.website != null &&
                              venueDetails.website!.isNotEmpty)
                            CustomText(
                              text: venueDetails.website!,
                              fontSize: ResponsiveSizeUtil.size10,
                              color: Colors.blueAccent,
                            ),
                        ],
                      ),
                    ),

                    SizedBox(width: ResponsiveSizeUtil.size16),

                    // Right column
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: venueDetails.time ?? 'No time specified',
                            fontSize: ResponsiveSizeUtil.size16,
                            color: AppColor.whiteColor,
                            fontWeight: FontWeight.w800,
                          ),

                          SizedBox(height: ResponsiveSizeUtil.size10),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImageContainer(venueDetails.partyImage, 48),

                              SizedBox(width: ResponsiveSizeUtil.size10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: _getDescriptionText(),
                                      fontSize: ResponsiveSizeUtil.size10,
                                      color: AppColor.whiteColor,
                                    ),

                                    if (_needsReadMore())
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isExpanded = !_isExpanded;
                                          });
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: ResponsiveSizeUtil.size6,
                                          ),
                                          child: Text(
                                            _isExpanded
                                                ? "Read less..."
                                                : "Read more...",
                                            style: TextStyle(
                                              fontSize:
                                                  ResponsiveSizeUtil.size10,
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
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveSizeUtil.size20),

                // Ticket chart section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CustomText(
                          text: 'Tickets',
                          color: AppColor.whiteColor,
                          fontSize: ResponsiveSizeUtil.size12,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: ResponsiveSizeUtil.size52),
                        CustomText(
                          text: 'Time',
                          color: AppColor.whiteColor,
                          fontSize: ResponsiveSizeUtil.size12,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),

                    SizedBox(width: ResponsiveSizeUtil.size20),

                    Expanded(child: _buildTicketChart()),
                  ],
                ),

                SizedBox(height: ResponsiveSizeUtil.size20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDescriptionText() {
    final description = widget.venueDetails.description ?? '';
    if (_isExpanded || description.length <= 150) {
      return description;
    } else {
      return "${description.substring(0, 150)}...";
    }
  }

  bool _needsReadMore() {
    final description = widget.venueDetails.description ?? '';
    return description.length > 150;
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:partymap_app/Screens/home/home_controller.dart';
// import 'package:partymap_app/Screens/home/widgets/venue_details.dart';
// import 'package:partymap_app/res/colors/app_color.dart';
// import 'package:partymap_app/res/components/custom_text.dart';

// class VenueDetailBottomSheet extends ConsumerStatefulWidget {
//   final VenueDetails venueDetails;

//   const VenueDetailBottomSheet({super.key, required this.venueDetails});

//   @override
//   ConsumerState<VenueDetailBottomSheet> createState() =>
//       _VenueDetailBottomSheetState();
// }

// class _VenueDetailBottomSheetState
//     extends ConsumerState<VenueDetailBottomSheet> {
//   bool isExpanded = false;

//   void _showImageModal(BuildContext context, String? imageUrl) {
//     if (imageUrl == null) return;

//     showDialog(
//       context: context,
//       barrierColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: EdgeInsets.zero,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               GestureDetector(
//                 onTap: () => context.pop(),
//                 child: Container(
//                   color: Colors.black54,
//                   child: Image.network(
//                     imageUrl,
//                     fit: BoxFit.contain,
//                     errorBuilder: (context, error, stackTrace) => const Icon(
//                       Icons.broken_image,
//                       color: Colors.grey,
//                       size: 50,
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 5,
//                 right: 5,
//                 child: IconButton(
//                   icon: const Icon(Icons.close, color: Colors.white),
//                   onPressed: () => context.pop(),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     const double maxBarHeight = 50.0;
//     final venueDetails = widget.venueDetails;

//     return Container(
//       decoration: BoxDecoration(
//         // ignore: deprecated_member_use
//         color: Colors.black.withOpacity(0.94),
//         borderRadius: const BorderRadius.all(Radius.circular(25)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Align(
//             alignment: Alignment.topRight,
//             child: IconButton(
//               icon: const Icon(Icons.close, color: Colors.white),
//               onPressed: () {
//                 ref.read(selectedVenueProvider.notifier).state = null;
//               },
//             ),
//           ),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   CustomText(
//                     text: venueDetails.name ?? '',
//                     fontSize: 16,
//                     color: AppColor.whiteColor,
//                     fontWeight: FontWeight.w800,
//                   ),
//                   GestureDetector(
//                     onTap: () =>
//                         _showImageModal(context, venueDetails.placeImage),
//                     child: Container(
//                       height: 48,
//                       width: 48,
//                       color: AppColor.grayColor,
//                       child: venueDetails.placeImage != null
//                           ? Image.network(
//                               venueDetails.placeImage!,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   const Icon(
//                                     Icons.broken_image,
//                                     color: Colors.grey,
//                                   ),
//                             )
//                           : const Icon(
//                               Icons.image_not_supported,
//                               color: Colors.grey,
//                             ),
//                     ),
//                   ),
//                   CustomText(
//                     text: venueDetails.website ?? '',
//                     fontSize: 8,
//                     color: AppColor.whiteColor,
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   CustomText(
//                     text: venueDetails.time ?? '',
//                     fontSize: 16,
//                     color: AppColor.whiteColor,
//                     fontWeight: FontWeight.w800,
//                   ),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       GestureDetector(
//                         onTap: () =>
//                             _showImageModal(context, venueDetails.partyImage),
//                         child: Container(
//                           height: 48,
//                           width: 48,
//                           color: AppColor.grayColor,
//                           child: venueDetails.partyImage != null
//                               ? Image.network(
//                                   venueDetails.partyImage!,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) =>
//                                       const Icon(
//                                         Icons.broken_image,
//                                         color: Colors.grey,
//                                       ),
//                                 )
//                               : const Icon(
//                                   Icons.image_not_supported,
//                                   color: Colors.grey,
//                                 ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       SizedBox(
//                         width: 200,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             CustomText(
//                               text: _getDescriptionText(),
//                               fontSize: 8,
//                               color: AppColor.whiteColor,
//                             ),
//                             if (_needsReadMore())
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     isExpanded = !isExpanded;
//                                   });
//                                 },
//                                 child: const Padding(
//                                   padding: EdgeInsets.only(top: 4.0),
//                                   child: Text(
//                                     "Read more...",
//                                     style: TextStyle(
//                                       fontSize: 8,
//                                       color: Colors.blueAccent,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               const Spacer(),
//               Column(
//                 children: [
//                   CustomText(
//                     text: 'Tickets',
//                     color: AppColor.whiteColor,
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   const SizedBox(height: 48),
//                   CustomText(
//                     text: 'Time',
//                     color: AppColor.whiteColor,
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ],
//               ),
//               const SizedBox(width: 20),
//               Flexible(
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: IntrinsicWidth(
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: List.generate(venueDetails.data?.length ?? 0, (
//                         index,
//                       ) {
//                         final dataValue = venueDetails.data![index];
//                         final maxValue = venueDetails.data!.reduce(
//                           (a, b) => a > b ? a : b,
//                         );
//                         final barHeight = (dataValue / maxValue) * maxBarHeight;

//                         return Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 4),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               CustomText(
//                                 text: dataValue.toString(),
//                                 color: AppColor.whiteColor,
//                                 fontSize: 8,
//                               ),
//                               const SizedBox(height: 5),
//                               Container(
//                                 width: 12,
//                                 height: barHeight,
//                                 decoration: BoxDecoration(
//                                   color:
//                                       venueDetails.times![index].endsWith('AM')
//                                       ? Colors.blue
//                                       : Colors.red,
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                               CustomText(
//                                 text: venueDetails.times![index],
//                                 color: AppColor.whiteColor,
//                                 fontSize: 8,
//                               ),
//                             ],
//                           ),
//                         );
//                       }),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 50),
//             ],
//           ),
//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }

//   String _getDescriptionText() {
//     if (isExpanded || widget.venueDetails.description!.length <= 150) {
//       return widget.venueDetails.description ?? '';
//     } else {
//       return "${widget.venueDetails.description?.substring(0, 150)}...";
//     }
//   }

//   bool _needsReadMore() {
//     return widget.venueDetails.description!.length > 150;
//   }
// }
