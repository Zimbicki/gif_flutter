// lib/core/widgets/gradient_app_bar.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: actions,
        leading: leading,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
