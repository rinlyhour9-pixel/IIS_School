import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/flavor/app_config.dart';

/// Turns a bare API path (`uploads/x.jpg`, `storage/x.jpg`, a relative path,
/// or an absolute URL) into an ordered list of candidate URLs to try.
List<String> resolveImageUrlCandidates(String rawValue) {
  final value = rawValue.trim().replaceAll('\\', '/');
  final lower = value.toLowerCase();
  if (value.isEmpty ||
      lower == 'n/a' ||
      lower == 'null' ||
      lower == 'undefined' ||
      lower == 'false' ||
      value == '{}') {
    return const <String>[];
  }

  final unquoted = value.replaceAll('"', '').replaceAll("'", '');
  if (_isNetworkUrl(unquoted)) {
    return _networkUrlVariants(unquoted);
  }
  if (unquoted.startsWith('//')) {
    return <String>['https:$unquoted'];
  }

  final base = AppConfig.shared.baseUrl.trim();
  if (base.isEmpty) return const <String>[];
  final baseUri = Uri.parse(base.endsWith('/') ? base : '$base/');
  final path = unquoted.startsWith('/') ? unquoted.substring(1) : unquoted;

  final rawCandidates = <String>[
    path,
    if (path.startsWith('storage/')) 'public/$path',
    if (path.startsWith('uploads/')) 'public/$path',
    if (path.startsWith('images/')) 'public/$path',
    if (!path.startsWith('storage/')) 'storage/$path',
    if (!path.startsWith('uploads/')) 'uploads/$path',
    if (!path.startsWith('public/')) 'public/$path',
  ];

  final seen = <String>{};
  final resolved = <String>[];
  for (final candidate in rawCandidates) {
    final url = baseUri.resolve(candidate.replaceAll('//', '/')).toString();
    if (seen.add(url)) resolved.add(url);
  }
  return resolved;
}

bool _isNetworkUrl(String value) =>
    value.startsWith('http://') || value.startsWith('https://');

List<String> _networkUrlVariants(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return <String>[url];

  final normalizedPath = uri.path.replaceAll('\\', '/');
  final variants = <String>[
    uri
        .replace(
          path: normalizedPath.replaceFirst('/uploads/uploads/', '/uploads/'),
        )
        .toString(),
    uri
        .replace(
          path: normalizedPath.replaceFirst('/public/public/', '/public/'),
        )
        .toString(),
    uri
        .replace(
          path: normalizedPath.replaceFirst('/storage/storage/', '/storage/'),
        )
        .toString(),
    uri.toString(),
  ];

  final seen = <String>{};
  return variants.where((v) => seen.add(v)).toList();
}

Map<String, String>? _imageAuthHeaders() {
  final token = AppConfig.shared.authorizationToken.trim();
  if (token.isEmpty) return null;
  return <String, String>{'Authorization': token, 'Accept': 'image/*'};
}

/// Renders [rawPath] (an asset path, a bare API path, or an absolute URL),
/// walking the resolved candidate list and falling back to the next one on
/// error until [fallbackAsset] is shown.
class ResolvedNetworkImage extends StatelessWidget {
  const ResolvedNetworkImage({
    super.key,
    required this.rawPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackAsset = 'assets/images/placeholder.png',
    this.placeholderColor = const Color(0xFFE9EEF2),
    this.filterQuality = FilterQuality.high,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  final String rawPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String fallbackAsset;
  final Color placeholderColor;
  final FilterQuality filterQuality;

  /// Caps the decoded bitmap size — use on grid/thumbnail sites to bound
  /// memory when many network images are alive at once.
  final int? memCacheWidth;
  final int? memCacheHeight;

  @override
  Widget build(BuildContext context) {
    final trimmed = rawPath.trim();
    if (trimmed.startsWith('assets/')) {
      return Image.asset(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        filterQuality: filterQuality,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    final candidates = resolveImageUrlCandidates(trimmed);
    if (candidates.isEmpty) {
      return _fallback();
    }
    return _buildCandidate(candidates, 0);
  }

  Widget _buildCandidate(List<String> urls, int index) {
    if (index >= urls.length) {
      return _fallback();
    }
    return CachedNetworkImage(
      imageUrl: urls[index],
      width: width,
      height: height,
      fit: fit,
      httpHeaders: _imageAuthHeaders(),
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      maxWidthDiskCache: memCacheWidth,
      maxHeightDiskCache: memCacheHeight,
      placeholder:
          (_, __) =>
              Container(width: width, height: height, color: placeholderColor),
      errorWidget: (_, __, ___) => _buildCandidate(urls, index + 1),
    );
  }

  Widget _fallback() {
    return Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: fit,
      filterQuality: filterQuality,
    );
  }
}
