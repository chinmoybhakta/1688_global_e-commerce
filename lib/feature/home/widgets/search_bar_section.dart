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
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: (value) => onSearch(),
            decoration: const InputDecoration(
              hintText: "Search products...",
              border: InputBorder.none,
            ),
          ),
        ),
    
        IconButton(
          onPressed: onSearch,
          icon: const Icon(
            Icons.search,
            size: 18,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}
