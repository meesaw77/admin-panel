import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:admin/theme/colors.dart';
import 'package:admin/theme/app_icons.dart';

class CustomHorizontalScrollbar extends StatefulWidget {
  final Widget Function(BuildContext context, ScrollController controller)
  builder;

  const CustomHorizontalScrollbar({super.key, required this.builder});

  @override
  State<CustomHorizontalScrollbar> createState() =>
      _CustomHorizontalScrollbarState();
}

class _CustomHorizontalScrollbarState extends State<CustomHorizontalScrollbar> {
  final ScrollController _controller = ScrollController();
  bool _showLeftIndicator = false;
  bool _showRightIndicator = false;
  double _scrollProgress = 0.0;
  bool _canScroll = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollListener();
    });
  }

  @override
  void didUpdateWidget(covariant CustomHorizontalScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollListener();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!mounted || !_controller.hasClients) return;

    final double maxScroll = _controller.position.maxScrollExtent;
    final double currentScroll = _controller.position.pixels;

    final bool canScroll = maxScroll > 0;
    final bool showLeft = canScroll && currentScroll > 5;
    final bool showRight = canScroll && currentScroll < maxScroll - 5;
    final double progress = canScroll
        ? (currentScroll / maxScroll).clamp(0.0, 1.0)
        : 0.0;

    if (showLeft != _showLeftIndicator ||
        showRight != _showRightIndicator ||
        progress != _scrollProgress ||
        canScroll != _canScroll) {
      setState(() {
        _showLeftIndicator = showLeft;
        _showRightIndicator = showRight;
        _scrollProgress = progress;
        _canScroll = canScroll;
      });
    }
  }

  void _scrollLeft() {
    if (!_controller.hasClients) return;
    final double target = (_controller.offset - 250).clamp(
      0.0,
      _controller.position.maxScrollExtent,
    );
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    if (!_controller.hasClients) return;
    final double target = (_controller.offset + 250).clamp(
      0.0,
      _controller.position.maxScrollExtent,
    );
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollUpdateNotification) {
          _scrollListener();
        }
        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollListener();
          });
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Main content (Child + Scrollbar)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: RawScrollbar(
                  controller: _controller,
                  scrollbarOrientation: ScrollbarOrientation.bottom,
                  thumbVisibility: _canScroll,
                  trackVisibility: _canScroll,
                  thickness: 8,
                  interactive: true,
                  thumbColor: AppColors.primaryRed.withValues(alpha: 0.8),
                  trackColor: AppColors.grey.withValues(alpha: 0.1),
                  radius: const Radius.circular(4),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      physics: _canScroll
                          ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
                          : const NeverScrollableScrollPhysics(),
                    ),
                    child: widget.builder(context, _controller),
                  ),
                ),
              ),



              // Left gradient fade and clickable chevron
              if (_showLeftIndicator)
                Positioned(
                  left: 0,
                  top: 8,
                  bottom: 12,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _scrollLeft,
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.white.withValues(alpha: 0.95),
                              AppColors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.grey.withValues(alpha: 0.2),
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                AppIcons.chevronLeft,
                                width: 14,
                                height: 14,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.primaryRed,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Right gradient fade and clickable chevron
              if (_showRightIndicator)
                Positioned(
                  right: 0,
                  top: 8,
                  bottom: 12,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _scrollRight,
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              AppColors.white.withValues(alpha: 0.95),
                              AppColors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(-1, 1),
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.grey.withValues(alpha: 0.2),
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                AppIcons.chevronRight,
                                width: 14,
                                height: 14,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.primaryRed,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
