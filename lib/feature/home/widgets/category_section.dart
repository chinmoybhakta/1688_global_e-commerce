// lib/feature/home/widgets/category_grid_section.dart
import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:flutter/material.dart';

class CategoryGridSection extends StatefulWidget {
  final Function(String categoryValue, String categoryName)? onCategoryTap;

  const CategoryGridSection({super.key, this.onCategoryTap});

  @override
  State<CategoryGridSection> createState() => _CategoryGridSectionState();
}

class _CategoryGridSectionState extends State<CategoryGridSection> {
  bool _showAllCategories = false;

  final List<Map<String, String>> categories = const [
    {'name': 'Office Supplies & Education', 'icon': '📚', 'value': 'book'},
    {'name': 'Beauty & Cosmetics', 'icon': '💄', 'value': 'cosmetic'},
    {'name': 'Personal & Home Care', 'icon': '🧴', 'value': 'home_care'},
    {'name': 'General Merchandise', 'icon': '🛒', 'value': 'general'},
    {'name': "Women's Apparel Market", 'icon': '👗', 'value': 'womens_fashion'},
    {'name': "Men's Apparel Market", 'icon': '👔', 'value': 'mens_fashion'},
    {'name': 'Underwear', 'icon': '🩲', 'value': 'underwear'},
    {'name': 'Shoes', 'icon': '👟', 'value': 'shoes'},
    {'name': 'Luggage & Leather Goods', 'icon': '🧳', 'value': 'luggage'},
    {'name': 'Automotive Supplies', 'icon': '🚗', 'value': 'automotive'},
    {'name': 'Sports & Outdoors', 'icon': '⚽', 'value': 'sports'},
    {'name': 'Crafts & Gifts', 'icon': '🎁', 'value': 'crafts'},
    {'name': 'Pet Supplies', 'icon': '🐾', 'value': 'pets'},
    {'name': 'Gardening Market', 'icon': '🌱', 'value': 'gardening'},
    {'name': "Children's Apparel Market", 'icon': '👕', 'value': 'kids_fashion'},
    {'name': 'Toy Market', 'icon': '🧸', 'value': 'toys'},
    {'name': 'Maternity & Baby Products', 'icon': '🍼', 'value': 'baby'},
    {'name': 'Food, Beverage & Fresh Produce', 'icon': '🍎', 'value': 'food'},
    {'name': 'Digital Market', 'icon': '📱', 'value': 'digital'},
    {'name': 'Mobile Phone Market', 'icon': '📱', 'value': 'mobile'},
    {'name': 'Home Appliances Market', 'icon': '🏠', 'value': 'appliances'},
    {'name': 'Home Textiles & Decor', 'icon': '🛋️', 'value': 'home_decor'},
    {'name': 'Textiles & Leather', 'icon': '🧵', 'value': 'textiles'},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    final displayCategories = _showAllCategories 
        ? categories 
        : categories.take((isMobile) ? 8 : 12).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shop by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              if (!_showAllCategories)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllCategories = true;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                  child: const Text('View All'),
                ),
              if (_showAllCategories)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllCategories = false;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                  child: const Text('Show Less'),
                ),
            ],
          ),
        ),

        // Category Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Important for nested grids
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 100,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: displayCategories.length,
            itemBuilder: (context, index) {
              final category = displayCategories[index];
              return _buildCategoryItem(
                category['name']!, 
                category['icon']!,
                category['value']!,
              );
            },
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoryItem(String categoryName, String icon, String value) {
    return GestureDetector(
      onTap: () {
        if (widget.onCategoryTap != null) {
          widget.onCategoryTap!(value, categoryName);
        } else {
          _showComingSoon(context, categoryName);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Circle
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Category Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String categoryName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$categoryName category coming soon!'),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}