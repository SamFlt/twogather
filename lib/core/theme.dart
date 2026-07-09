

import 'dart:math';

import 'package:flutter/material.dart';

List<Color> getColorPalette() {
  return [
    Color(0xFFDFFF00),
    Color(0xFFFF6F20),
    Color(0xFFFF007F),
    Color(0xFF00BFFF),
    Color(0xFFFF1493)
  ];
}


ThemeData getTheme() {

  var c = getColorPalette();
  var scheme = ColorScheme.fromSeed(
      seedColor: c[2],
      primary: c[2],
      secondary: c[1],
      tertiary: c[4],
      surface: Color(0x00000000),
  );

  return ThemeData(
    colorScheme: scheme,
    iconTheme: IconThemeData(color: scheme.secondary),
    fontFamily: 'Moliga'
  );
}


class PopArtButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color dotColor;

  const PopArtButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = const Color(0xFFFFD400), // pop-art yellow
    this.dotColor = Colors.black,
  });

  @override
  State<PopArtButton> createState() => _PopArtButtonState();
}

class _PopArtButtonState extends State<PopArtButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _pressed ? 4 : 0,
          _pressed ? 4 : 0,
          0,
        ),
        child: CustomPaint(
          foregroundPainter: _HalftoneBorderPainter(
              dotColor: widget.dotColor,
              bandWidth: 18,     // how deep the halftone fade extends inward
              gridSpacing: 7,    // density of dots — smaller = denser
              maxDotRadius: 3.2), // size of dots right at the edge),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: widget.color,
              border: Border.all(color: Colors.black, width: 4),
              borderRadius: BorderRadius.circular(8),
              boxShadow: _pressed
                  ? []
                  : [
                      const BoxShadow(
                        color: Colors.black,
                        offset: Offset(6, 6),
                        blurRadius: 0,
                      ),
                    ],
            ),
            child: Center(child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            )),
          ),
        ),
      ),
    );
  }
}



class _HalftoneBorderPainter extends CustomPainter {
  final Color dotColor;
  final double bandWidth; // thickness of the halftone band
  final double gridSpacing; // spacing between dot centers
  final double maxDotRadius;
  final int seed;

  _HalftoneBorderPainter({
    required this.dotColor,
    this.bandWidth = 18,
    this.gridSpacing = 7,
    this.maxDotRadius = 3.2,
    this.seed = 7,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    final rng = Random(seed);
    final rect = Offset.zero & size;

    // Walk a full grid across the button, only draw dots that fall
    // inside the border band (distance to nearest edge <= bandWidth)
    for (double x = 0; x <= rect.width; x += gridSpacing) {
      for (double y = 0; y <= rect.height; y += gridSpacing) {
        final distToEdge = [
          x, // distance from left
          rect.width - x, // distance from right
          y, // distance from top
          rect.height - y, // distance from bottom
        ].reduce(min);

        if (distToEdge > bandWidth) continue; // inside the button, skip

        // halftone effect: dots shrink as they get farther from the edge
        final t = (1 - (distToEdge / bandWidth)).clamp(0.0, 1.0);
        final radius = maxDotRadius * t;
        if (radius < 0.4) continue; // too small to bother drawing

        // slight jitter so the grid doesn't look mechanical
        final jitterX = (rng.nextDouble() - 0.5) * gridSpacing * 0.1;
        final jitterY = (rng.nextDouble() - 0.5) * gridSpacing * 0.1;

        canvas.drawCircle(
          Offset(x + jitterX, y + jitterY),
          radius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HalftoneBorderPainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.dotColor != dotColor;
}