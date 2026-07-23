import 'package:flutter/material.dart';

List<Color> getColorPalette() {
  return [
    Color(0xFFFF6E29),
    Color(0xFF25632D),
    Color(0xFFFFACB7),
    Color(0xFF79C8D2),
  ];
}
Color disabledColor() {
  return Colors.grey;
}


ButtonStyle alternativeStyle(ColorScheme scheme) => ButtonStyle(
  backgroundColor: WidgetStateColor.fromMap(<WidgetStatesConstraint, Color>{
    WidgetState.disabled: Color.fromARGB(255, 139, 139, 139),
    WidgetState.any: scheme.primary,
  }),
  foregroundColor: WidgetStateColor.fromMap(<WidgetStatesConstraint, Color>{
    WidgetState.disabled: Color(0xFFFFFFFF),
    WidgetState.any: scheme.secondary,
  }),
   shape: WidgetStateOutlinedBorder.fromMap({
    WidgetState.any: RoundedRectangleBorder(borderRadius: .circular(5))
  }),
  padding: WidgetStateProperty.fromMap({
    WidgetState.any: .zero
  })
);

ButtonStyle alternativeStyleRound(ColorScheme scheme) => ButtonStyle(
  backgroundColor: WidgetStateColor.fromMap(<WidgetStatesConstraint, Color>{
    WidgetState.disabled: Color.fromARGB(255, 139, 139, 139),
    WidgetState.any: scheme.primary,
  }),
  foregroundColor: WidgetStateColor.fromMap(<WidgetStatesConstraint, Color>{
    WidgetState.disabled: Color(0xFFFFFFFF),
    WidgetState.any: scheme.secondary,
  }),
  shape: WidgetStateOutlinedBorder.fromMap({
    WidgetState.any: RoundedRectangleBorder(borderRadius: .circular(5))
  }),
  
  iconSize: WidgetStateProperty.fromMap({
    WidgetState.any: 20
  })
  
  
);

ThemeData getTheme() {
  var c = getColorPalette();
  var scheme = ColorScheme.fromSeed(
    seedColor: c[2],
    primary: c[2],
    secondary: c[1],
    tertiary: c[0],
    // surface: Color(0xFFF4F4DC),
    surface: Color(0XFFffefcb),
    onSecondary: Color(0XFFffefcb)
  );

  var buttonStyle = ButtonStyle(
    backgroundColor: WidgetStateColor.fromMap(<WidgetStatesConstraint, Color>{
      WidgetState.disabled: Color.fromARGB(255, 139, 139, 139),
      WidgetState.any: scheme.secondary,
    }),
    foregroundColor: WidgetStateColor.fromMap(<WidgetStatesConstraint, Color>{
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
      
      shape: RoundedRectangleBorder(borderRadius: .circular(5))

      // shape: RoundedRectangleBorder(side: .none, borderRadius: .all(Radius.elliptical(1, 1)))
    ),
    iconButtonTheme: IconButtonThemeData(style: buttonStyle),
    elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
    fontFamily: 'Neulis',
  );
}

