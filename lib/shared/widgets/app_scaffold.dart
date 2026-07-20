import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({required this.title, required this.body, super.key});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: body,
        ),
      ),
    );
  }
}
