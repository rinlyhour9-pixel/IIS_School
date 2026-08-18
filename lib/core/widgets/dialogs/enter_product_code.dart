import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/views.dart';

class EnterProductCodeDialog extends StatelessWidget {
  EnterProductCodeDialog({super.key});

  final ScanController scanCtl = Get.find<ScanController>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.white,
      elevation: 0,
      insetPadding: UIConstants.spacing.padHorizontal,
      shape: RoundedRectangleBorder(borderRadius: UIConstants.radius.radiusAll),
      child: Padding(
        padding: UIConstants.spacing.padAll,
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: scanCtl.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Get product
                    Text(
                      LocaleKeys.getProduct.tr,
                      style: AppTextStyle.midPrimarySemiBold,
                    ),
                    6.height,

                    CustomTextField(
                      controller: scanCtl.getProdCtl,
                      hintText: LocaleKeys.enterProductCode.tr,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (text) => FormValidator.empty(text),
                      textInputAction: TextInputAction.next,
                    ),
                    30.height,

                    // Apply
                    PrimaryButton(
                      text: 'APPLY',
                      onPressed: () async {
                        final String getProduct = scanCtl.getProdCtl.text;
                        if (getProduct.isEmpty) {
                          return;
                        }
                        Get.back();
                        if (getProduct.isNotEmpty) {
                          await scanCtl.scanCard(getProduct);
                          scanCtl.getProdCtl.text = '';
                          return;
                        }
                      },
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
}
