import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle display(double size, {Color color = AppColors.white, double letterSpacing = 2.0}) {
    return GoogleFonts.bebasNeue(
      fontSize: size, color: color, letterSpacing: letterSpacing, height: 1.0,
    );
  }

  static TextStyle body(double size, {
    Color color = AppColors.white,
    FontWeight weight = FontWeight.w400,
    double height = 1.6,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.outfit(
      fontSize: size, color: color, fontWeight: weight,
      height: height, letterSpacing: letterSpacing,
    );
  }

  static TextStyle get sectionTag  => body(11, color: AppColors.yellow, weight: FontWeight.w700, letterSpacing: 3, height: 1);
  static TextStyle get sectionDesc => body(16, color: AppColors.gray, height: 1.7);
  static TextStyle get bodySm      => body(13, color: AppColors.gray, height: 1.65);
  static TextStyle get label       => body(12, color: AppColors.gray, weight: FontWeight.w600, letterSpacing: 1, height: 1);
  static TextStyle get btnText     => body(15, color: AppColors.black, weight: FontWeight.w700, letterSpacing: 0.3);
  static TextStyle get priceAmount => body(42, color: AppColors.yellow, weight: FontWeight.w700, height: 1);
}
