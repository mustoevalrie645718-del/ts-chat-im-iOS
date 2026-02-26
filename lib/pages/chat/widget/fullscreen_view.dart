import 'package:flutter/material.dart';

// Utility class: Encapsulates the logic for displaying a full-screen view
class FullScreenView {
  // Displays a full-screen view with fade-in and fade-out effects
  static void show({
    required BuildContext context, // The BuildContext of the current widget
    required String text, // The text to display (supports newlines)
    Color backgroundColor = Colors.white, // Background color (default: white)
    TextStyle textStyle = const TextStyle(
      color: Colors.black, // Text color: black
      fontSize: 20, // Text font size: 16px
      fontWeight: FontWeight.normal, // Text font weight: normal
    ), // Text style
    Duration transitionDuration = const Duration(milliseconds: 300), // Animation duration (default: 500ms)
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _FullScreenView(
          text: text,
          backgroundColor: backgroundColor,
          textStyle: textStyle,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0; // Starting opacity
          const end = 1.0; // Ending opacity
          final tween = Tween(begin: begin, end: end);
          final opacityAnimation = animation.drive(tween);

          return FadeTransition(
            opacity: opacityAnimation,
            child: child,
          );
        },
        transitionDuration: transitionDuration,
      ),
    );
  }
}

// Internal widget: Represents the full-screen view page
class _FullScreenView extends StatelessWidget {
  final String text; // The text to display (supports newlines)
  final Color backgroundColor; // Background color of the view
  final TextStyle textStyle; // Style for the text

  const _FullScreenView({
    required this.text,
    required this.backgroundColor,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close the view when background is tapped
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
        color: backgroundColor,
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Text(
                  text,
                  style: textStyle,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
