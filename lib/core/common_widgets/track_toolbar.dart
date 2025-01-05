import 'dart:developer';

import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class TrackToolbar extends StatefulWidget {
  const TrackToolbar({super.key});

  @override
  State<TrackToolbar> createState() => _TrackToolbarState();
}

class _TrackToolbarState extends State<TrackToolbar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {
              context.go('/');
            },
            icon: Image.asset(
              icBack,
              height: 22,
              color: AppColors.colorWhite,
            )),
        const SizedBox(width: 4),
        Expanded(
            child: Image.asset(
          appLogoTextSmall,
          fit: BoxFit.contain,
          height: MediaQuery.of(context).size.height / 15,
        )),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () async {
            AppUtils.onShare(context, "https://femtopedia.de/shareplustest");
          },
          color: AppColors.colorWhite,
          icon: Image.asset(
            icShare,
            height: 24,
            color: AppColors.colorWhite,
          ),
        ),
      ],
    );
  }
}
