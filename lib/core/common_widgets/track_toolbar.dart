import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/storage/preference_helper.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TrackToolbar extends StatefulWidget {
  bool? isLoggedIn;
  TrackToolbar({super.key,this.isLoggedIn});

  @override
  State<TrackToolbar> createState() => _TrackToolbarState();
}

class _TrackToolbarState extends State<TrackToolbar> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        widget.isLoggedIn ?? false
            ? Padding(
              padding: const EdgeInsets.only(left: 6),
              child: GestureDetector(
                onTap: (){
                  context.go('/profile');
                },
                child: CircleAvatar(
                    radius: 24.0,
                    backgroundImage:
                        NetworkImage(AppUtils.profileModel.profilePath ?? ''),
                    backgroundColor: Colors.transparent,
                  ),
              ),
            )
            : IconButton(
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
