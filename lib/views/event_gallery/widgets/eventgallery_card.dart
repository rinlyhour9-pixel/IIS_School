import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/views/event_gallery/controller.dart';
import 'package:schoolapp/core/core.dart';

class ActivityCardWidget extends StatelessWidget {
  const ActivityCardWidget({super.key, required this.items, this.onTap});

  final List<ClassActivityItem> items;
  final void Function(ClassActivityItem item)? onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 206,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final description = _descriptionPreview(item.description);
        return InkWell(
          onTap: onTap == null ? null : () => onTap!(item),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: _cardImage(item.image),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            description.isEmpty
                                ? LocaleKeys.tapToViewTheFullActivityDetails.tr
                                : description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color:
                                  description.isEmpty
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.open_in_new_rounded,
                              size: 14,
                              color: Color(0xFFD80F23),
                            ),
                            SizedBox(width: 4),
                            Text(
                              LocaleKeys.viewDetails.tr,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD80F23),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cardImage(String imagePath) {
    final normalizedPath = imagePath.trim();
    if (normalizedPath.isEmpty) {
      return Image.asset(
        'assets/images/placeholder.png',
        width: double.infinity,
        height: 108,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
    }

    if (normalizedPath.startsWith('http://') ||
        normalizedPath.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: normalizedPath,
        width: double.infinity,
        height: 95,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: const Color(0xFFE9EEF2)),
        errorWidget:
            (_, __, ___) => Image.asset(
              'assets/images/placeholder.png',
              width: double.infinity,
              height: 108,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
      );
    }

    return Image.asset(
      normalizedPath,
      width: double.infinity,
      height: 108,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder:
          (_, __, ___) => Image.asset(
            'assets/images/placeholder.png',
            width: double.infinity,
            height: 108,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
    );
  }

  String _descriptionPreview(String rawDescription) {
    final plainText = rawDescription.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();

    if (plainText.isEmpty) {
      return '';
    }

    final words =
        plainText
            .split(RegExp(r'\s+'))
            .where((word) => word.isNotEmpty)
            .toList();

    const maxWords = 18;

    if (words.length <= maxWords) {
      return plainText;
    }

    return '${words.take(maxWords).join(' ')}...';
  }
}
