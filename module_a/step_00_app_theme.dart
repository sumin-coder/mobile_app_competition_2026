// 앱 전체 화면에서 공통으로 사용하는 색상, 글꼴, 컴포넌트 테마를 정의합니다.

import 'package:flutter/material.dart';

// 화면 전반의 의미별 색상을 한곳에서 관리합니다.
abstract final class AppColors {
  static const background = Colors.black, onPrimary = background;
  static const surface = Colors.black87, filter = surface;
  static const surfaceHigh = Colors.black54;
  static const albumBackground = Colors.white;
  static const albumForeground = Colors.brown;
  static const outline = Colors.grey, muted = outline;
  static const primary = Colors.yellow;
  static const productAccent = Colors.orange;
  static const danger = Colors.red;
  static const success = Colors.green;
}

// 제목, 가격, 설명 등 반복되는 텍스트 스타일을 제공합니다.
abstract final class AppTextStyles {
  static const bold = TextStyle(fontWeight: FontWeight.bold);
  static const authTitle = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
  static const section = TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  static const caption = TextStyle(fontSize: 13, color: AppColors.muted);
  static const detailTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );
  static const recommendTitle = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.bold,
  );
  static const seller = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const cardTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  static const recommendAlbum = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
  );
  static const recommendArtist = TextStyle(
    color: AppColors.primary,
    fontSize: 14,
  );
  static const smallBold = TextStyle(fontSize: 11, fontWeight: FontWeight.bold);
  static const error = TextStyle(color: AppColors.danger, fontSize: 12);
  static const price = TextStyle(
    fontSize: 16,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );
}

// 입력창과 둥근 박스에서 사용하는 공통 장식 생성기입니다.
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

// MaterialApp에 적용되는 Vinyl Groove 다크 테마입니다.
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
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
