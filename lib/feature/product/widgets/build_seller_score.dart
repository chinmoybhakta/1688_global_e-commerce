import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildSellerScore(String label, String score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          score,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }