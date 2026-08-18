import 'package:flutter/material.dart';
import 'package:schoolapp/core/configs/app_style.dart';

class VideoSectionWidget extends StatelessWidget {
  List videoList = [
    'Introduction of Flutter',
    'Installing Flutter On Windows',
    'Setup Emulator on Windows',
    'Creating Our First App',
    'Creating Our First App',
    'Creating Our First App',
    'Creating Our First App',
  ];

  VideoSectionWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: videoList.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Card(
          child: Container(
            margin: const EdgeInsets.only(top: 5.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: index == 0 ? AppColor.primary : AppColor.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,

                  color: Colors.white,
                  size: 30,
                ),
              ),
              title: Text(videoList[index]),
              subtitle: const Text("20 min 50sec"),
            ),
          ),
        );
      },
    );
  }
}
