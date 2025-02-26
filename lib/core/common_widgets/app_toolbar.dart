import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppToolbar extends StatefulWidget {
  final Function burgerMenuFnc;

  const AppToolbar({super.key, required this.burgerMenuFnc});

  @override
  State<AppToolbar> createState() => _AppToolbarState();
}

class _AppToolbarState extends State<AppToolbar> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, left: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () {
                context.go('/profile');
              },
              icon: Image.asset(
                icBack,
                height: 22,
              )),
          const SizedBox(width: 12),
          Expanded(
              child: Image.asset(
            appLogoTextSmall,
            fit: BoxFit.contain,
            height: MediaQuery.of(context).size.height / 15,
          )),
          const SizedBox(width: 4),
          AppUtils.burgerMenu(onPressed: () {
            widget.burgerMenuFnc();
          }),
        ],
      ),
    );
  }
}
