import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PremiumSlider extends StatefulWidget {
  const PremiumSlider({super.key, required this.imagesList});
  final List<String> imagesList;
  @override
  State<PremiumSlider> createState() => _PremiumSliderState();
}

class _PremiumSliderState extends State<PremiumSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> imageSliders =
        widget.imagesList.asMap().entries.map((entry) {
          String item = entry.value;
          int index = entry.key + 1;

          return GestureDetector(
            onTap: () {
              //Get.toNamed('/promos/$index');
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child:
                        item.startsWith('http') || item.startsWith('https')
                            ? CachedNetworkImage(
                              imageUrl: item,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder:
                                  (context, url) => const ShimmerPreloader(),
                              errorWidget: (context, url, error) {
                                debugPrint(
                                  'PremiumSlider image load error for $url: $error',
                                );
                                return const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                );
                              },
                              fadeInDuration: const Duration(milliseconds: 300),
                              fadeOutDuration: const Duration(
                                milliseconds: 100,
                              ),
                              cacheKey: item,
                              useOldImageOnUrlChange: true,
                            )
                            : Image.asset(
                              item,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                  ),
                ],
              ),
            ),
          );
        }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 180.0;
        final sliderHeight = maxHeight.clamp(90.0, 2000.0);
        final showIndicator = widget.imagesList.length > 1;
        const indicatorHeight =10.0;
        const indicatorSpacing = 8.0;
        final imageHeight =
            showIndicator
                ? (sliderHeight - indicatorHeight - indicatorSpacing).clamp(
                  90.0,
                  2000.0,
                )
                : sliderHeight;

        return SizedBox(
          height: sliderHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: imageHeight,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  child: CarouselSlider(
                    items: imageSliders,
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 10),
                      initialPage: 0,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      pauseAutoPlayOnTouch: true,
                      height: imageHeight,
                      onPageChanged: (index, reason) {
                        if (!mounted) return;
                        setState(() => _currentIndex = index);
                      },
                    ),
                  ),
                ),
              ),
              if (showIndicator) ...[
                const SizedBox(height: indicatorSpacing),
                SizedBox(
                  height: indicatorHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(widget.imagesList.length, (
                      index,
                    ) {
                      final isActive = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: EdgeInsets.only(
                          right: index == widget.imagesList.length - 1 ? 0 : 6,
                        ),
                        width: isActive ? 18 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color:
                              isActive
                                  ? Colors.red
                                  : Colors.red.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class ShimmerPreloader extends StatelessWidget {
  const ShimmerPreloader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(color: Colors.white),
    );
  }
}
