import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

class AppCard extends StatelessWidget {
  const AppCard({required this.child, this.padding = AppSizes.lg, super.key});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    );
  }
}
