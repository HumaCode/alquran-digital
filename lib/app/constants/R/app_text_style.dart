import 'package:flutter/material.dart';

class AppTextStyle {
  const AppTextStyle();

  // Font Sizes
  static const double sizeSmall = 12.0;
  static const double sizeMedium = 14.0;
  static const double sizeLarge = 18.0;
  static const double sizeExtraLarge = 24.0;

  // Base TextStyle generators to allow easy customization/copying
  TextStyle small({
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    TextDecoration decoration = TextDecoration.none,
    Color? color,
  }) =>
      TextStyle(
        fontSize: sizeSmall,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        decoration: decoration,
        color: color,
      );

  TextStyle medium({
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    TextDecoration decoration = TextDecoration.none,
    Color? color,
  }) =>
      TextStyle(
        fontSize: sizeMedium,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        decoration: decoration,
        color: color,
      );

  TextStyle large({
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    TextDecoration decoration = TextDecoration.none,
    Color? color,
  }) =>
      TextStyle(
        fontSize: sizeLarge,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        decoration: decoration,
        color: color,
      );

  TextStyle extraLarge({
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    TextDecoration decoration = TextDecoration.none,
    Color? color,
  }) =>
      TextStyle(
        fontSize: sizeExtraLarge,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        decoration: decoration,
        color: color,
      );

  // Pre-configured Small Styles
  TextStyle get smallLight => small(fontWeight: FontWeight.w300);
  TextStyle get smallNormal => small(fontWeight: FontWeight.w400);
  TextStyle get smallBold => small(fontWeight: FontWeight.w700);
  TextStyle get smallItalic => small(fontStyle: FontStyle.italic);
  TextStyle get smallUnderline => small(decoration: TextDecoration.underline);

  // Pre-configured Medium Styles
  TextStyle get mediumLight => medium(fontWeight: FontWeight.w300);
  TextStyle get mediumNormal => medium(fontWeight: FontWeight.w400);
  TextStyle get mediumBold => medium(fontWeight: FontWeight.w700);
  TextStyle get mediumItalic => medium(fontStyle: FontStyle.italic);
  TextStyle get mediumUnderline => medium(decoration: TextDecoration.underline);

  // Pre-configured Large Styles
  TextStyle get largeLight => large(fontWeight: FontWeight.w300);
  TextStyle get largeNormal => large(fontWeight: FontWeight.w400);
  TextStyle get largeBold => large(fontWeight: FontWeight.w700);
  TextStyle get largeItalic => large(fontStyle: FontStyle.italic);
  TextStyle get largeUnderline => large(decoration: TextDecoration.underline);

  // Pre-configured Extra Large Styles
  TextStyle get extraLargeLight => extraLarge(fontWeight: FontWeight.w300);
  TextStyle get extraLargeNormal => extraLarge(fontWeight: FontWeight.w400);
  TextStyle get extraLargeBold => extraLarge(fontWeight: FontWeight.w700);
  TextStyle get extraLargeItalic => extraLarge(fontStyle: FontStyle.italic);
  TextStyle get extraLargeUnderline => extraLarge(decoration: TextDecoration.underline);
}
