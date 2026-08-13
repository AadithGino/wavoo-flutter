import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final BoxFit fit;

  static bool isNetworkUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.startsWith('http://') || value.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (!isNetworkUrl(url)) {
      return const _Placeholder();
    }
    return Image.network(
      url!,
      fit: fit,
      errorBuilder: (_, __, ___) => const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.cream2,
      child: const Center(
        child: Icon(Icons.diamond_outlined, color: AppColors.goldDark, size: 28),
      ),
    );
  }
}
