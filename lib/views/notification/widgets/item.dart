import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';

class NotificationItemWidget extends StatelessWidget {
  const NotificationItemWidget({
    super.key,
    required this.title,
    required this.dateText,
    required this.timeText,
    this.imagePath = '',
    this.imageUrl = '',
    this.fallbackImagePath = '',
    this.onTap,
  });

  final String title;
  final String dateText;
  final String timeText;
  final String imagePath;
  final String imageUrl;
  final String fallbackImagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final metaText = [
      dateText.trim(),
      timeText.trim(),
    ].where((part) => part.isNotEmpty).join('   ');
    final resolvedFallbackImage =
        fallbackImagePath.isEmpty ? AssetPath.placeholder.path : fallbackImagePath;
    final resolvedAssetImage =
        imagePath.isEmpty ? resolvedFallbackImage : imagePath;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD0D0D0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.red, width: 2),
              ),
              child: ClipOval(
                child:
                    imageUrl.trim().isNotEmpty
                        ? CustomNetworkImage(
                          imageUrl: imageUrl,
                          width: 78,
                          height: 78,
                          fit: BoxFit.cover,
                          fallbackImagePath: resolvedAssetImage,
                        )
                        : Image.asset(
                          resolvedAssetImage,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Image.asset(
                                resolvedFallbackImage,
                                fit: BoxFit.cover,
                              ),
                        ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.2,
                      color: Color(0xFF1B1F24),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (metaText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      metaText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF676B73),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
