import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/media.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;

  static bool isNetworkUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.startsWith('http://') || value.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final raw = url?.trim() ?? '';
    if (raw.startsWith('assets/')) {
      return Image.asset(
        raw,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _Placeholder(width: width, height: height),
      );
    }
    final resolved = Media.resolve(raw.isEmpty ? null : raw) ?? raw;
    if (!isNetworkUrl(resolved)) {
      return _Placeholder(width: width, height: height);
    }
    return Image.network(
      resolved,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => _Placeholder(width: width, height: height),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: const ColoredBox(
        color: AppColors.cream2,
        child: Center(
          child: Icon(Icons.diamond_outlined, color: AppColors.goldDark, size: 28),
        ),
      ),
    );
  }
}
