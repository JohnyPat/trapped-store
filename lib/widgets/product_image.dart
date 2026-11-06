import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imageUrl,
    this.fallbackAsset,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.backgroundColor = AppColors.canvas,
    this.padding = const EdgeInsets.all(8),
  });

  final String imageUrl;
  final String? fallbackAsset;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final fallback = fallbackAsset ?? AppAssets.fallbackForProduct('');
    final child = _resolve(fallback);
    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      padding: padding,
      child: child,
    );
  }

  Widget _resolve(String fallback) {
    if (imageUrl.isEmpty) {
      return Image.asset(fallback, fit: fit, width: width, height: height);
    }
    // Bundled product images are served from the same Hosting filenames.
    // Use them directly when offline/slow instead of downloading the network
    // copy and repeatedly hitting the image decoder.
    final localMatch = _bundledAssetFor(imageUrl);
    if (localMatch != null) {
      return Image.asset(
        localMatch,
        fit: fit,
        width: width,
        height: height,
      );
    }
    if (imageUrl.startsWith('asset:')) {
      return Image.asset(
        imageUrl.substring('asset:'.length),
        fit: fit,
        width: width,
        height: height,
      );
    }
    if (!imageUrl.startsWith('http')) {
      return Image.asset(imageUrl, fit: fit, width: width, height: height);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: const Duration(milliseconds: 220),
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 1.2),
        ),
      ),
      errorWidget: (context, url, error) => Image.asset(
        fallback,
        fit: fit,
        width: width,
        height: height,
      ),
    );
  }
  /// Resolve a Hosting catalog URL (…/catalog/pistol-tee.png) to the
  /// identical bundled asset (assets/images/products/pistol-tee.png).
  String? _bundledAssetFor(String url) {
    if (!url.startsWith('http')) return null;
    try {
      final segments = Uri.parse(url).pathSegments;
      if (segments.isEmpty) return null;
      final fileName = segments.last;
      for (final asset in AppAssets.productImages.values) {
        if (asset.endsWith('/$fileName')) return asset;
      }
    } on FormatException {
      return null;
    }
    return null;
  }
}

class EditorialImage extends StatelessWidget {
  const EditorialImage({
    super.key,
    required this.imageUrl,
    this.fallbackAsset = AppAssets.hero,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.grayscale = false,
    this.overlayOpacity = 0,
  });

  final String imageUrl;
  final String fallbackAsset;
  final BoxFit fit;
  final double? width;
  final double? height;
  final bool grayscale;
  final double overlayOpacity;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (imageUrl.isEmpty) {
      image = Image.asset(
        fallbackAsset,
        fit: fit,
        width: width,
        height: height,
      );
    } else if (imageUrl.startsWith('asset:')) {
      image = Image.asset(
        imageUrl.substring('asset:'.length),
        fit: fit,
        width: width,
        height: height,
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => Container(color: AppColors.soft),
        errorWidget: (context, url, error) => Image.asset(
          fallbackAsset,
          fit: fit,
          width: width,
          height: height,
        ),
      );
    }
    if (grayscale) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: image,
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        if (overlayOpacity > 0)
          Container(color: Colors.black.withValues(alpha: overlayOpacity)),
      ],
    );
  }
}
