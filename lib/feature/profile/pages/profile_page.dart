import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: Center(
      child: TextButton(
          onPressed: () {
            context.go("/edit_profile");
          },
          child: Text("Edit Profile")),
    ));
  }
}
