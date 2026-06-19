import 'package:flutter/material.dart';

import 'app_chrome.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(useMaterial3: true);
  final compactTextTheme = base.textTheme.copyWith(
    titleLarge: base.textTheme.bodyLarge?.copyWith(
      fontSize: 15.5,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    titleMedium: base.textTheme.bodyLarge?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    titleSmall: base.textTheme.bodyMedium?.copyWith(
      fontSize: 14.5,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
  );
  return ThemeData(
    useMaterial3: true,
    textTheme: compactTextTheme,
    scaffoldBackgroundColor: const Color(0xfff7f7fa),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff007aff),
      primary: const Color(0xff007aff),
      secondary: const Color(0xff5856d6),
      surface: Colors.white,
      surfaceContainerHighest: const Color(0xfff7f7fa),
      outline: const Color(0xffc7c7cc),
      outlineVariant: const Color(0xffd1d1d6),
    ),
    visualDensity: VisualDensity.compact,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hoverColor: Colors.white,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      border: controlBorder,
      enabledBorder: controlBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(controlRadius)),
        borderSide: BorderSide(color: Color(0xff007aff), width: 1.4),
      ),
      prefixIconConstraints: BoxConstraints(minWidth: 36, minHeight: 36),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xfff7f7fa),
      surfaceTintColor: Color(0xffe5e5ea),
      elevation: 0,
      scrolledUnderElevation: 1,
      titleTextStyle: TextStyle(
        color: Color(0xff1c1c1e),
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      toolbarTextStyle: TextStyle(
        color: Color(0xff1c1c1e),
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xffd1d1d6),
      thickness: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff007aff),
        disabledBackgroundColor: const Color(0xfff7f7fa),
        disabledForegroundColor: const Color(0xff8e8e93),
        minimumSize: const Size(0, 42),
        side: const BorderSide(color: Color(0xffd1d1d6)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(controlRadius),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return const Color(0xffffffff);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xff007aff);
        }
        return const Color(0xffd1d1d6);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xff007aff);
        }
        return Colors.white;
      }),
      checkColor: const WidgetStatePropertyAll(Colors.white),
      side: const BorderSide(color: Color(0xffc7c7cc)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff007aff),
        selectedBackgroundColor: const Color(0xffe5f1ff),
        selectedForegroundColor: const Color(0xff007aff),
        side: const BorderSide(color: Color(0xffd1d1d6)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(controlRadius),
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xff007aff),
      linearTrackColor: Color(0xffe5e5ea),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Color(0xfff7f7fa),
      indicatorColor: Color(0xffe5f1ff),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Color(0xffe5f1ff),
      elevation: 4,
    ),
    chipTheme: const ChipThemeData(
      shape: StadiumBorder(side: BorderSide(color: Color(0xffd1d1d6))),
      backgroundColor: Colors.white,
    ),
    listTileTheme: const ListTileThemeData(
      dense: true,
      horizontalTitleGap: 8,
      minLeadingWidth: 28,
    ),
  );
}
