import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/constants/user_type.dart';
import 'package:schoolapp/core/libraries/shared_preferences.dart';
import '../../../core/configs/app_style.dart';

class CustomizeAppBar extends StatefulWidget {
  const CustomizeAppBar({
    super.key,
    required this.title,
    this.subTitle,
    this.studentSubTitle,
    this.teacherSubTitle,
    this.trailing, // Added optional
  });

  final String title;
  final String? subTitle;
  final String? studentSubTitle;
  final String? teacherSubTitle;
  final Widget? trailing;

  @override
  State<CustomizeAppBar> createState() => _CustomizeAppBarState();
}

class _CustomizeAppBarState extends State<CustomizeAppBar> {
  late final Future<String?> _roleFuture = _readRole();

  Future<String?> _readRole() async {
    return (await SharedPreferencesManager.get('user_role') ?? '')
        .toString()
        .trim()
        .toLowerCase();
  }

  String? _subtitleForRole(String? role) {
    if (role == UserType.teacher.key && widget.teacherSubTitle != null) {
      return widget.teacherSubTitle;
    }

    if (role == UserType.parent.key && widget.studentSubTitle != null) {
      return widget.studentSubTitle;
    }

    return widget.subTitle;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return FutureBuilder<String?>(
      future: _roleFuture,
      builder: (context, snapshot) {
        final subTitle = _subtitleForRole(snapshot.data);
        return SizedBox(
          width: size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTextStyle.mediumPrimaryGreenBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 8),
                      widget.trailing!,
                    ],
                  ],
                ),
                if ((subTitle ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: Text(
                      subTitle!,
                      style: AppTextStyle.smallPrimaryGreenBold,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
