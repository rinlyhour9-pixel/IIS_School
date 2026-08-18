import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/views/dashboard/controller.dart';
import 'package:schoolapp/views/dashboard/widgets/slide_image.dart';

class DashboardSliderSection extends StatefulWidget {
  const DashboardSliderSection({super.key, required this.height});

  final double height;

  @override
  State<DashboardSliderSection> createState() => _DashboardSliderSectionState();
}

class _DashboardSliderSectionState extends State<DashboardSliderSection> {
  late final DashboardController _dashboardController;

  @override
  void initState() {
    super.initState();
    _dashboardController = Get.find<DashboardController>();

    if (_dashboardController.sliderImages.isEmpty &&
        !_dashboardController.isSliderLoading.value) {
      _dashboardController.fetchSliders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = _dashboardController.isSliderLoading.value;
      final images = _dashboardController.sliderImages;

      if (isLoading && images.isEmpty) {
        return SizedBox(
          height: widget.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const ShimmerPreloader(),
          ),
        );
      }

      if (images.isEmpty) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFFE9EEF2),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: IconButton(
            tooltip: 'Reload banners',
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: _dashboardController.fetchSliders,
          ),
        );
      }

      return SizedBox(
        height: widget.height,
        child: PremiumSlider(imagesList: images.toList(growable: false)),
      );
    });
  }
}
