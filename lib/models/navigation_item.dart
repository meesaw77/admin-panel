import 'package:flutter/material.dart';

class NavigationItem {
  final String title;
  final String svgSrc;
  final Widget screen;
  final String path;

  const NavigationItem({
    required this.title,
    required this.svgSrc,
    required this.screen,
    required this.path,
  });
}
