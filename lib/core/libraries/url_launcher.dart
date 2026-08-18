import 'package:flutter/foundation.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/main.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherManager {
  static Future<void> launch(String? url) async {
    customPrint('===== URL ===== $url');

    try {
      if (url == null) {
        throw Exception();
      }

      final uri = Uri.tryParse(url);
      if (uri == null) {
        throw Exception();
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ExceptionHandler.handleException('Could not launch url: $url');
    }
  }

  static Future<void> call(String value) async {
    launch('tel://$value');
  }

  static Future<void> telegram(String value) async {
    launch('https://t.me/$value');
  }

  static Future<void> map({required String lat, required String lng}) async {
    await openMap(lat: lat, lng: lng);
  }

  static Future<void> openMap({
    String? address,
    String? mapUrl,
    String? lat,
    String? lng,
  }) async {
    final coordinates = _coordinatesFrom(lat: lat, lng: lng, mapUrl: mapUrl);
    final query = _mapQuery(address: address, coordinates: coordinates);

    final platformUrl =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
            ? _appleMapsUrl(query: query, coordinates: coordinates)
            : _googleMapsUrl(query: query, coordinates: coordinates);

    await launch(platformUrl);
  }

  static ({String lat, String lng})? _coordinatesFrom({
    String? lat,
    String? lng,
    String? mapUrl,
  }) {
    final directLat = lat?.trim() ?? '';
    final directLng = lng?.trim() ?? '';
    if (directLat.isNotEmpty && directLng.isNotEmpty) {
      return (lat: directLat, lng: directLng);
    }

    final text = Uri.decodeFull(mapUrl ?? '');
    final patterns = <RegExp>[
      RegExp(r'[?&](?:q|query)=(-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?)'),
      RegExp(r'@(-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?)'),
      RegExp(r'!3d(-?\d+(?:\.\d+)?)!4d(-?\d+(?:\.\d+)?)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return (lat: match.group(1)!, lng: match.group(2)!);
      }
    }

    return null;
  }

  static String _mapQuery({
    String? address,
    ({String lat, String lng})? coordinates,
  }) {
    if (coordinates != null) {
      return '${coordinates.lat},${coordinates.lng}';
    }

    final trimmedAddress = (address ?? '').trim();
    return trimmedAddress.isEmpty ? 'Phnom Penh, Cambodia' : trimmedAddress;
  }

  static String _appleMapsUrl({
    required String query,
    ({String lat, String lng})? coordinates,
  }) {
    final params = <String, String>{'q': query};
    if (coordinates != null) {
      params['ll'] = '${coordinates.lat},${coordinates.lng}';
    }
    return Uri(
      scheme: 'http',
      host: 'maps.apple.com',
      queryParameters: params,
    ).toString();
  }

  static String _googleMapsUrl({
    required String query,
    ({String lat, String lng})? coordinates,
  }) {
    final params = <String, String>{
      'api': '1',
      'query':
          coordinates == null ? query : '${coordinates.lat},${coordinates.lng}',
    };
    return Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      queryParameters: params,
    ).toString();
  }
}
