import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/online_courses/widgets/videosection.dart';

class OnlineCoursesCardWidget extends StatelessWidget {
  const OnlineCoursesCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            width: MediaQuery.of(context).size.width,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              image: const DecorationImage(
                image: AssetImage('assets/images/banner1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColor.primary,
                  size: 40,
                ),
              ),
            ),
          ),
          5.height,
          const Text('Lesson 1', style: AppTextStyle.midSecondaryBold),
          2.height,
          const Text(
            'Teacher: Demo',
            style: AppTextStyle.normalPrimarySemiBold,
          ),
          2.height,
          const Text('55 video', style: AppTextStyle.normalPrimarySemiBold),
          2.height,
          VideoSectionWidget(),
        ],
      ),
    );
  }
}
