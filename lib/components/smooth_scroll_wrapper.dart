import 'package:flutter/material.dart';

class SmoothScrollWrapper extends StatefulWidget {
  final Widget child;

  const SmoothScrollWrapper({super.key, required this.child});

  @override
  State<SmoothScrollWrapper> createState() => _SmoothScrollWrapperState();
}

class _SmoothScrollWrapperState extends State<SmoothScrollWrapper> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: _scrollController,
      child: widget.child,
    );
  }
}
