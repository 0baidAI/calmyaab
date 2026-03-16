import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.black,
    primaryColor: AppColors.yellow,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.yellow,
      secondary: AppColors.yellow,
      surface: AppColors.black2,
      background: AppColors.black,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    dividerColor: Colors.transparent,
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all(AppColors.yellow),
      thickness: MaterialStateProperty.all(4),
      radius: const Radius.circular(2),
    ),
  );
}
