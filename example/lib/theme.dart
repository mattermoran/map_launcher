import 'package:flutter/material.dart';

abstract final class AppTheme {
  static final dark = ThemeData(
    brightness: .dark,
    useMaterial3: true,
    colorScheme: .fromSeed(
      seedColor: const Color(0xFF4A90D9),
      brightness: .dark,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: .circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: .w600),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: .circular(16)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(20)),
      ),
    ),
  );
}
