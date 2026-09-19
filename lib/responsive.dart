import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) {
    final constraints = ResponsiveConstraints.maybeOf(context);
    if (constraints != null) {
      return constraints.maxWidth < 850;
    }
    return MediaQuery.of(context).size.width < 850;
  }

  static bool isTablet(BuildContext context) {
    final constraints = ResponsiveConstraints.maybeOf(context);
    if (constraints != null) {
      return constraints.maxWidth < 1100 && constraints.maxWidth >= 850;
    }
    return MediaQuery.of(context).size.width < 1100 &&
        MediaQuery.of(context).size.width >= 850;
  }

  static bool isDesktop(BuildContext context) {
    final constraints = ResponsiveConstraints.maybeOf(context);
    if (constraints != null) {
      return constraints.maxWidth >= 1100;
    }
    return MediaQuery.of(context).size.width >= 1100;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ResponsiveConstraints(
          constraints: constraints,
          child: Builder(
            builder: (context) {
              if (constraints.maxWidth >= 1100) {
                return desktop;
              } else if (constraints.maxWidth >= 850 && tablet != null) {
                return tablet!;
              } else {
                return mobile;
              }
            },
          ),
        );
      },
    );
  }
}

class ResponsiveConstraints extends InheritedWidget {
  final BoxConstraints constraints;

  const ResponsiveConstraints({
    super.key,
    required this.constraints,
    required super.child,
  });

  static BoxConstraints? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ResponsiveConstraints>()?.constraints;
  }

  @override
  bool updateShouldNotify(ResponsiveConstraints oldWidget) {
    return constraints != oldWidget.constraints;
  }
}
