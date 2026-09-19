import 'package:flutter/material.dart';

/// A drop-in replacement for CachedNetworkImage that uses Flutter's
/// built-in Image.network. Used after removing the cached_network_image package.
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final dynamic placeholder;
  final dynamic errorWidget;
  final Alignment alignment;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildError(context, 'Empty image URL');
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      alignment: alignment,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder(context);
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildError(context, error);
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder is Widget) return placeholder as Widget;
    if (placeholder is Function) {
      try {
        return Function.apply(placeholder as Function, [context, imageUrl]) as Widget;
      } catch (_) {
        try {
          return Function.apply(placeholder as Function, [context]) as Widget;
        } catch (_) {}
      }
    }
    return _defaultPlaceholder();
  }

  Widget _buildError(BuildContext context, Object? error) {
    if (errorWidget is Widget) return errorWidget as Widget;
    if (errorWidget is Function) {
      try {
        return Function.apply(errorWidget as Function, [context, imageUrl, error]) as Widget;
      } catch (_) {
        try {
          return Function.apply(errorWidget as Function, [context, imageUrl]) as Widget;
        } catch (_) {
          try {
            return Function.apply(errorWidget as Function, [context]) as Widget;
          } catch (_) {}
        }
      }
    }
    return _defaultError();
  }

  Widget _defaultPlaceholder() {
    return SizedBox(
      width: width,
      height: height,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _defaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade800,
      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
    );
  }
}
