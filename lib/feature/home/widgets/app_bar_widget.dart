// lib/feature/home/widgets/custom_header.dart
import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/riverpod/cart_notifier.dart';
import 'package:ecommece_site_1688/feature/home/cart_screen.dart';
import 'package:ecommece_site_1688/feature/home/widgets/currency_dropdown.dart';
import 'package:ecommece_site_1688/feature/home/widgets/search_bar_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppBarWidget extends ConsumerWidget {
  final TextEditingController searchController;
  final VoidCallback onSearch;

  const AppBarWidget({
    super.key,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Container(
      color: Colors.white,
      height: (isMobile) ? 150 : 150, // Same as toolbarHeight
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Logo
                  SizedBox(
                    height: 200,
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                  ),

                  // Search Bar - Expanded to take available space
                  Expanded(
                    child: SearchBarSection(
                      controller: searchController,
                      onSearch: onSearch,
                    ),
                  ),

                  if(!isMobile) const SizedBox(width: 8),

                  InkWell(
                    onTap: () {
                      Fluttertoast.showToast(
                        msg: "Our Mobile App is coming soon! Stay tuned.",
                        webBgColor: "#ffecda",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity
                            .TOP,
                        timeInSecForIosWeb: 1,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: 16.0,
                      );
                    },
                    child: Icon(
                      Icons.widgets_outlined,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),

                  // Text("App\nis\nupcoming", style: TextStyle(color: AppColors.textPrimaryColor)),
                  const SizedBox(width: 8),
                  if(!isMobile) const SizedBox(width: 8),

                  // Currency Dropdown
                  const CurrencyDropdown(),

                  if(!isMobile) const SizedBox(width: 8),

                  // Cart Icon with Badge
                  Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CartScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.shopping_cart_outlined,
                              color: AppColors.textPrimaryColor,
                              size: 28,
                            ),
                          ),
                        ),
                        if (cartNotifier.hasItems) ...[
                          Positioned(
                            top: 4, // Adjusted for better positioning
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Center(
                                child: Text(
                                  cartNotifier.totalItems.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom border line
          Container(color: AppColors.semiPrimaryColor, height: 1),
        ],
      ),
    );
  }
}
