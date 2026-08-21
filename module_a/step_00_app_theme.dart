import 'package:flutter/material.dart';
abstract final class AppColors {
  static const background = Colors.black, onPrimary = background;
  static const surface = Color(0xFF101113), filter = surface;
  static const surfaceHigh = Color(0xFF17181A);
  static const albumBackground = Colors.white;
  static const albumForeground = Colors.brown;
  static const outline = Color(0xFF35373A), muted = Color(0xFFA0A0A0);
  static const primary = Color(0xFFD4A54B);
  static const productAccent = primary;
  static const danger = Colors.red;
  static const success = Colors.green;
}
abstract final class AppTextStyles {
  static const boldWeight = FontWeight.bold;
  static const bold = TextStyle(fontWeight: boldWeight);
  static const authTitle = TextStyle(fontSize: 28, fontWeight: boldWeight);
  static const section = TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  static const caption = TextStyle(fontSize: 13, color: AppColors.muted);
  static const detailTitle = TextStyle(fontSize: 28, fontWeight: boldWeight);
  static const recommendTitle = TextStyle(fontSize: 23, fontWeight: boldWeight);
  static const seller = TextStyle(fontSize: 18, fontWeight: boldWeight);
  static const cardTitle = TextStyle(fontSize: 16, fontWeight: boldWeight);
  static const recommendAlbum = TextStyle(fontSize: 17, fontWeight: boldWeight);
  static const recommendArtist = TextStyle(
    color: AppColors.primary,
    fontSize: 14,
  );
  static const smallBold = TextStyle(fontSize: 11, fontWeight: boldWeight);
  static const error = TextStyle(color: AppColors.danger, fontSize: 12);
  static const price = TextStyle(
    fontSize: 16,
    color: AppColors.primary,
    fontWeight: boldWeight,
  );
}
abstract final class AppDecor {
  static InputDecoration input(String hint) => InputDecoration(hintText: hint);
  static BoxDecoration rounded({
    Color? color,
    double radius = 12,
    BoxBorder? border,
  }) => BoxDecoration(
    color: color,
    border: border,
    borderRadius: BorderRadius.circular(radius),
  );
}
abstract final class AppTheme {
  static OutlineInputBorder get _border => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.outline),
  );
  static bool _selected(Set<WidgetState> states) =>
      states.contains(WidgetState.selected);
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: const TextStyle(color: AppColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: _border,
      enabledBorder: _border,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: AppTextStyles.recommendAlbum,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 76,
      backgroundColor: AppColors.surface,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: _selected(states) ? AppColors.primary : AppColors.muted,
          size: _selected(states) ? 27 : 25,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          color: _selected(states) ? AppColors.primary : AppColors.muted,
          fontWeight: _selected(states) ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    ),
  );
}
