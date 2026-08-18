import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/language/language.dart';

class LanguageView extends GetView<LanguageController> {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.language.tr)),
      body: Padding(
        padding: 16.padAll,
        child: Column(
          children: [
            const ItemView(),
            18.height,
            const ItemView(isCambodia: false),
          ],
        ),
      ),
    );
  }
}
