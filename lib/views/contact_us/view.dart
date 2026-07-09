import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/start/widgets/custom_indicator.dart';
import 'package:schoolapp/views/views.dart';

class ContactUsView extends GetView<ContactUsController> {
  const ContactUsView({super.key});

  static const Color _accentGreen = AppColor.green;
  static const Color _softGreen = Color(0xFFF4FFF3);

  @override
  Widget build(BuildContext context) {
    final ctl =
        Get.isRegistered<ContactUsController>()
            ? Get.find<ContactUsController>()
            : Get.put(ContactUsController());

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.contactUs.tr),
        // backgroundColor: const Color.fromARGB(255, 90, 11, 17),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: Obx(() {
        final data = ctl.contactUs.value;
        final address = _clean(data?.address, fallback: 'Phnom Penh, Cambodia');
        final phone = _clean(data?.phone, fallback: '');
        final email = _clean(data?.email, fallback: '');
        final mapUrl = _ensureHttp(
          _clean(
            data?.mapUrl,
            fallback: 'https://maps.google.com/?q=11.5335286,104.881178',
          ),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  LocaleKeys.contactUs.tr,
                  style: AppTextStyle.midPrimaryBold,
                ),
              ),
              12.height,
              const CustomIndicator(progress: 1 / 4),
              18.height,
              _locationCard(address: address, mapUrl: mapUrl),
              16.height,
              if (phone.isNotEmpty) ...[
                _infoCard(
                  icon: Icons.phone_in_talk_outlined,
                  title: LocaleKeys.phoneNumber.tr,
                  value: phone,
                  onTap: () => UrlLauncherManager.call(phone),
                ),
                const SizedBox(height: 12),
              ],
              if (email.isNotEmpty) ...[
                _infoCard(
                  icon: Icons.mail_outline_rounded,
                  title: LocaleKeys.email.tr,
                  value: email,
                  onTap: () => UrlLauncherManager.launch('mailto:$email'),
                ),
                const SizedBox(height: 18),
              ],
              Row(
                children: [
                  Expanded(
                    child: _actionBtn(
                      icon: Icons.map_outlined,
                      label: LocaleKeys.openMap.tr,
                      onTap:
                          () => UrlLauncherManager.openMap(
                            address: address,
                            mapUrl: mapUrl,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionBtn(
                      icon: Icons.phone,
                      label: LocaleKeys.callNow.tr,
                      onTap:
                          phone.isEmpty
                              ? null
                              : () => UrlLauncherManager.call(phone),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _locationCard({required String address, required String mapUrl}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radius.toDouble()),
        border: Border.all(color: AppColor.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: _accentGreen,
                size: 30,
              ),
              const SizedBox(width: 8),
              Text(
                LocaleKeys.address.tr,
                style: AppTextStyle.regularPrimarytextPrimary,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            address,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: _softGreen,
            borderRadius: BorderRadius.circular(UIConstants.radius.toDouble()),
            child: InkWell(
              borderRadius: BorderRadius.circular(
                UIConstants.radius.toDouble(),
              ),
              onTap:
                  () => UrlLauncherManager.openMap(
                    address: address,
                    mapUrl: mapUrl,
                  ),
              child: SizedBox(
                height: UIConstants.btnHeight,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      color: _accentGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LocaleKeys.openMap.tr,
                      style: AppTextStyle.normalPrimarySemiBold,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(UIConstants.radius.toDouble()),
      child: InkWell(
        borderRadius: BorderRadius.circular(UIConstants.radius.toDouble()),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIConstants.radius.toDouble()),
            border: Border.all(color: AppColor.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _softGreen,
                  borderRadius: BorderRadius.circular(
                    UIConstants.radius.toDouble(),
                  ),
                ),
                child: Icon(icon, color: _accentGreen, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.regularPrimarytextPrimary.copyWith(
                        color: _accentGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: _accentGreen, size: 18),
      label: Text(
        label,
        style: AppTextStyle.regularPrimarytextPrimary.copyWith(
          color: _accentGreen,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: _softGreen,
        foregroundColor: _accentGreen,
        disabledForegroundColor: AppColor.greyTextColor,
        side: BorderSide(color: _accentGreen.withOpacity(0.45)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radius.toDouble()),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        minimumSize: const Size.fromHeight(UIConstants.btnHeight),
      ),
    );
  }

  String _clean(String? value, {String fallback = ''}) {
    final text = (value ?? '').trim();
    if (text.isEmpty ||
        text.toLowerCase() == 'n/a' ||
        text.toLowerCase() == 'null') {
      return fallback;
    }
    return text;
  }

  String _ensureHttp(String value) {
    final v = value.trim();
    if (v.startsWith('http://') || v.startsWith('https://')) {
      return v;
    }
    return 'https://$v';
  }
}
