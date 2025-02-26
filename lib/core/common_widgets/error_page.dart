import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({super.key});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: Column(
      children: [
        Text("Error"),
      ],
    ));
  }
}
