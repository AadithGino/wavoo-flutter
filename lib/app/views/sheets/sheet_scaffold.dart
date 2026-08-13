import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';

Future<T?> openAppSheet<T>(Widget child, {bool scrollControlled = true}) {
  return Get.bottomSheet<T>(
    SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.88),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: child,
      ),
    ),
    isScrollControlled: scrollControlled,
    backgroundColor: Colors.transparent,
  );
}

Widget sheetHeader(String title) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 9),
        Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.line,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 8, 9, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(title, style: AppTypography.serif(size: 22)),
              ),
              IconButton(
                onPressed: Get.back,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                icon: SvgPicture.asset(
                  'assets/svg/close.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
