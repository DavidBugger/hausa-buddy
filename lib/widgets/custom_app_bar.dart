// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onLeadingPressed;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color iconColor;
  final double elevation;
  final bool automaticallyImplyLeading;
  final Widget? leadingIcon; // Allow custom leading icon

  const CustomAppBar({
    Key? key,
    this.title,
    this.onLeadingPressed,
    this.actions,
    this.backgroundColor = Colors.transparent,
    this.iconColor = const Color(0xFF1A202C), // Default icon color
    this.elevation = 0,
    this.automaticallyImplyLeading = true, // Default Flutter AppBar behavior
    this.leadingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the leading widget
    Widget? currentLeading = leadingIcon;
    if (currentLeading == null && automaticallyImplyLeading) {
      if (Navigator.canPop(context)) {
        currentLeading = IconButton(
          icon: Icon(Icons.arrow_back_ios, color: iconColor),
          onPressed: onLeadingPressed ?? () => Navigator.pop(context),
        );
      }
      // If onLeadingPressed is provided but cannot pop, you might want a custom icon
      // or to ensure the button is only shown when onLeadingPressed makes sense
      else if (onLeadingPressed != null) {
        // This case assumes if onLeadingPressed is given, we show a back-like button
        // or you might want to require `leadingIcon` to be non-null if automaticallyImplyLeading is false and you want a leading icon.
        currentLeading = IconButton(
          icon: Icon(Icons.arrow_back_ios, color: iconColor), // Default back icon if onLeadingPressed is provided
          onPressed: onLeadingPressed,
        );
      }
    }


    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      automaticallyImplyLeading: false, // We are handling it manually
      leading: currentLeading,
      title: title != null
          ? Text(
        title!,
        style: TextStyle(
          color: iconColor, // Or a specific title color
          fontWeight: FontWeight.bold,
          // Add other title text styles as needed
        ),
      )
          : null,
      centerTitle: true, // Optional: to center the title
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Standard AppBar height
}
