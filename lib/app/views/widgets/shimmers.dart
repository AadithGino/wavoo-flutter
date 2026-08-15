import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';

class WavooShimmer extends StatelessWidget {
  const WavooShimmer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE9DCCB),
      highlightColor: const Color(0xFFFBF6EE),
      child: child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class CategoryRowShimmer extends StatelessWidget {
  const CategoryRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return WavooShimmer(
      child: SizedBox(
        height: 70,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.only(right: 14),
            child: SizedBox(
              width: 58,
              child: Column(
                children: [
                  ShimmerBox(width: 50, height: 50, radius: 25),
                  SizedBox(height: 8),
                  ShimmerBox(width: 42, height: 8, radius: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CatalogChipShimmer extends StatelessWidget {
  const CatalogChipShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return WavooShimmer(
      child: SizedBox(
        height: 35,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, __) => const ShimmerBox(width: 78, height: 35, radius: 20),
        ),
      ),
    );
  }
}

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({this.width, super.key});

  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 1, child: ColoredBox(color: Colors.white)),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 54, height: 8, radius: 4),
                  SizedBox(height: 8),
                  ShimmerBox(width: double.infinity, height: 12, radius: 4),
                  SizedBox(height: 8),
                  ShimmerBox(width: 72, height: 10, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductRowShimmer extends StatelessWidget {
  const ProductRowShimmer({this.height = 220, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return WavooShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 18, bottom: 10),
            child: Row(
              children: [
                ShimmerBox(width: 120, height: 16, radius: 6),
                Spacer(),
                ShimmerBox(width: 68, height: 12, radius: 6),
              ],
            ),
          ),
          SizedBox(
            height: height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, __) => const ProductCardShimmer(width: 156),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({this.count = 6, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return WavooShimmer(
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: count,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.67,
        ),
        itemBuilder: (_, __) => const ProductCardShimmer(),
      ),
    );
  }
}

class SchemeCardShimmer extends StatelessWidget {
  const SchemeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return WavooShimmer(
      child: Container(
        margin: const EdgeInsets.only(top: 14, bottom: 4),
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.pageCard,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.goldBorder),
        ),
        child: const Row(
          children: [
            ShimmerBox(width: 80, height: 80, radius: 40),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 110, height: 10, radius: 4),
                  SizedBox(height: 10),
                  ShimmerBox(width: 160, height: 18, radius: 6),
                  SizedBox(height: 10),
                  ShimmerBox(width: double.infinity, height: 6, radius: 4),
                  SizedBox(height: 10),
                  ShimmerBox(width: 140, height: 10, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SchemePageShimmer extends StatelessWidget {
  const SchemePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const WavooShimmer(
      child: Column(
        children: [
          ShimmerBox(width: double.infinity, height: 46, radius: 11),
          SizedBox(height: 16),
          ShimmerBox(width: double.infinity, height: 220, radius: 14),
          SizedBox(height: 18),
          ShimmerBox(width: double.infinity, height: 140, radius: 12),
        ],
      ),
    );
  }
}

class OrdersListShimmer extends StatelessWidget {
  const OrdersListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return WavooShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(17, 16, 17, 30),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => const ShimmerBox(
          width: double.infinity,
          height: 78,
          radius: 12,
        ),
      ),
    );
  }
}

class AddressCardShimmer extends StatelessWidget {
  const AddressCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return WavooShimmer(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 90, height: 12, radius: 4),
            SizedBox(height: 10),
            ShimmerBox(width: double.infinity, height: 10, radius: 4),
            SizedBox(height: 6),
            ShimmerBox(width: 180, height: 10, radius: 4),
          ],
        ),
      ),
    );
  }
}

class AddressListShimmer extends StatelessWidget {
  const AddressListShimmer({this.count = 2, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          const AddressCardShimmer(),
        ],
      ],
    );
  }
}

class SheetListShimmer extends StatelessWidget {
  const SheetListShimmer({this.count = 5, this.height = 78, super.key});

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return WavooShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => ShimmerBox(
          width: double.infinity,
          height: height,
          radius: 12,
        ),
      ),
    );
  }
}

class ProfilePageShimmer extends StatelessWidget {
  const ProfilePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const WavooShimmer(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          children: [
            ShimmerBox(width: double.infinity, height: 118, radius: 14),
            SizedBox(height: 14),
            ShimmerBox(width: double.infinity, height: 268, radius: 13),
            SizedBox(height: 14),
            ShimmerBox(width: 140, height: 18, radius: 6),
            SizedBox(height: 10),
            ShimmerBox(width: double.infinity, height: 86, radius: 12),
          ],
        ),
      ),
    );
  }
}

class HomeSectionsShimmer extends StatelessWidget {
  const HomeSectionsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const WavooShimmer(
      child: Column(
        children: [
          SizedBox(height: 8),
          ShimmerBox(width: double.infinity, height: 88, radius: 13),
          SizedBox(height: 8),
          ShimmerBox(width: double.infinity, height: 88, radius: 13),
        ],
      ),
    );
  }
}

class ProductSpecsShimmer extends StatelessWidget {
  const ProductSpecsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const WavooShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 160, height: 16, radius: 6),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 58, radius: 8)),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 58, radius: 8)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 58, radius: 8)),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 58, radius: 8)),
            ],
          ),
          SizedBox(height: 17),
          ShimmerBox(width: 120, height: 16, radius: 6),
          SizedBox(height: 10),
          ShimmerBox(width: double.infinity, height: 62, radius: 10),
          SizedBox(height: 17),
          ShimmerBox(width: 110, height: 16, radius: 6),
          SizedBox(height: 10),
          ShimmerBox(width: double.infinity, height: 148, radius: 11),
        ],
      ),
    );
  }
}
