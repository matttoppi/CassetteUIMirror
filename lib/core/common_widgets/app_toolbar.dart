import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppToolbar extends StatefulWidget {
  final Function burgerMenuFnc;

  const AppToolbar({super.key, required this.burgerMenuFnc});

  @override
  State<AppToolbar> createState() => _AppToolbarState();
}

class _AppToolbarState extends State<AppToolbar> with TickerProviderStateMixin {
  late AnimationController _menuController;

  @override
  void initState() {
    super.initState();
    _menuController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8,left: 8),
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
          IconButton(
            iconSize: 42,
            color: AppColors.textPrimary,
            onPressed: () {
              if (_menuController.status == AnimationStatus.dismissed) {
                _menuController.reset();
                _menuController.animateTo(1);
              } else {
                _menuController.reverse();
              }
              widget.burgerMenuFnc();
            },
            icon: const Icon(Icons.menu,size: 34,color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
