

import 'package:flutter/material.dart';

List<Color> getColorPalette() {
  return [
    Color(0xFFFF6E29),
    Color(0xFF25632D),
    Color(0xFFFFACB7),
    Color(0xFF79C8D2),
  ];
}


ThemeData getTheme() {

  var c = getColorPalette();
  var scheme = ColorScheme.fromSeed(
      seedColor: c[2],
      primary: c[2],
      secondary: c[1],
      tertiary: c[0],
      // surface: Color(0xFFF4F4DC),
      surface: Color(0XFFffefcb)
  );


  var buttonStyle = ButtonStyle(
    backgroundColor: WidgetStateColor.fromMap(
      <WidgetStatesConstraint, Color>{
        WidgetState.disabled: Color.fromARGB(255, 139, 139, 139),
        WidgetState.any: scheme.tertiary,
      },
    
    ),
    foregroundColor: WidgetStateColor.fromMap(
      <WidgetStatesConstraint, Color>{
        WidgetState.disabled: Color(0xFFFFFFFF),
        WidgetState.any: scheme.surface,
    }),
  );

  return ThemeData(
    colorScheme: scheme,
    iconTheme: IconThemeData(color: scheme.secondary),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.secondary,
      // shape: RoundedRectangleBorder(side: .none, borderRadius: .all(Radius.elliptical(1, 1)))
      
    ),
    iconButtonTheme: IconButtonThemeData(
      style: buttonStyle,
      
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: buttonStyle,
    ),
    fontFamily: 'Neulis'
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
                fontSize: 16,
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


