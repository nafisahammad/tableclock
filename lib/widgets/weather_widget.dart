import 'package:flutter/material.dart';

/// A miniature weather bubble used by the clock layout.
class WeatherWidget extends StatelessWidget {
  const WeatherWidget({
    super.key,
    required this.visible,
    required this.onTap,
    required this.text,
    required this.textStyle,
  });

  final bool visible;
  final VoidCallback onTap;
  final String text;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            text,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}
