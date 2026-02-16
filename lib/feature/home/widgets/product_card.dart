import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/repository/repository_impl.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondaryColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Product Image (60% of card height)
            Expanded(
              flex: 7,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Image.network(
                  RepositoryImpl().getProxiedImageUrl(imageUrl),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  // ✅ Loading UI
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Container(
                      color: AppColors.secondaryColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },

                  // ❌ Error UI
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.secondaryColor,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: AppColors.textSecondaryColor,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Title & Price Section (40% of card height)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    // Price
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
