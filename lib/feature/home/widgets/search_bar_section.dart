import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:flutter/material.dart';

class SearchBarSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  const SearchBarSection({
    super.key,
    required this.controller,
    required this.onSearch,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.primaryColor),
          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Search products...",
                border: InputBorder.none,
              ),
            ),
          ),

          IconButton(
            onPressed: onSearch,
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
