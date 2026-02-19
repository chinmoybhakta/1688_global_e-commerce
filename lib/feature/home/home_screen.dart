import 'dart:developer';
import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/riverpod/cart_notifier.dart';
import 'package:ecommece_site_1688/core/data/riverpod/product_notifier.dart';
import 'package:ecommece_site_1688/core/data/riverpod/search_notifier.dart';
import 'package:ecommece_site_1688/core/service/currency_service.dart';
import 'package:ecommece_site_1688/feature/home/cart_screen.dart';
import 'package:ecommece_site_1688/feature/home/widgets/product_card.dart';
import 'package:ecommece_site_1688/feature/home/widgets/search_bar_section.dart';
import 'package:ecommece_site_1688/feature/product/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? getFormattedPrice(String? originalPrice) {
    if (originalPrice == null || originalPrice.isEmpty) {
      return 'Price unavailable';
    }

    try {
      final numericString = originalPrice.replaceAll(RegExp(r'[^\d.]'), '');
      final double priceInCNY = double.tryParse(numericString) ?? 0.0;

      final priceInBDT = CurrencyService.convertCnyToBdt(priceInCNY);
      return '৳ ${priceInBDT.toStringAsFixed(2)}';
    } catch (e) {
      debugPrint('Error converting price: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    final productState = ref.watch(productProvider);
    final isProductLoading = productState?.isLoading ?? false;
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 200,
        leadingWidth: 200,
        leading: Image.asset('assets/logo.png', fit: BoxFit.contain),
        title: SearchBarSection(
          controller: _searchController,
          onSearch: () async {
            final query = _searchController.text.trim();
            await ref.read(searchProvider.notifier).fetchSearchItems(query, 1);
          },
        ),
        centerTitle: true,
        actions: [
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
                      color: AppColors.primaryColor,
                      size: 28,
                    ),
                  ),
                ),
                if (ref.read(cartProvider.notifier).hasItems) ...[
                  Positioned(
                    top: 0,
                    bottom: 24,
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
                          ref.read(cartProvider.notifier).totalItems.toString(),
                          style: TextStyle(
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.semiPrimaryColor, height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Opacity(
              opacity: isProductLoading ? 0.5 : 1.0,
              child: AbsorbPointer(
                absorbing: isProductLoading,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ✅ Product Section
                    Expanded(
                      child: searchState.isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryColor,
                                ),
                              ),
                            )
                          : searchState.error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: AppColors.textSecondaryColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No products found",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              itemCount:
                                  searchState.data?.items?.item?.length ?? 0,
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 400,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: 0.85,
                                  ),
                              itemBuilder: (context, index) {
                                final item =
                                    searchState.data?.items?.item?[index];

                                return ProductCard(
                                  title: item?.title ?? "No Title",
                                  imageUrl: item!.picUrl!,
                                  price:
                                      getFormattedPrice(item.price) ??
                                      "Price unavailable",
                                  onTap: () async {
                                    try {
                                      final numIid = searchState
                                          .data!
                                          .items!
                                          .item![index]
                                          .numIid;

                                      log("🟡 Fetching product: $numIid");

                                      await ref
                                          .read(productProvider.notifier)
                                          .fetchProduct(numIid.toString());

                                      final productState = ref.read(
                                        productProvider,
                                      );

                                      if (productState?.data?.item != null) {
                                        log(
                                          "🟢 Product fetched successfully, navigating...",
                                        );

                                        if (mounted) {
                                          Navigator.push(
                                            // ignore: use_build_context_synchronously
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ProductScreen(
                                                item: productState!.data!.item,
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        log(
                                          "🔴 Product data is null after fetch",
                                        );
                                        Fluttertoast.showToast(
                                          msg: "Failed to load product data",
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                        );
                                      }
                                    } catch (e) {
                                      log("🔴 Exception: $e");
                                      Fluttertoast.showToast(
                                        msg: "Error: $e",
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                    ),

                    // Load More Button
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        onPressed: searchState.isLoading
                            ? null
                            : () async {
                                await ref
                                    .read(searchProvider.notifier)
                                    .loadMore();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(150, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: searchState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Load More Products",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isProductLoading) ...[
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.semiPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Loading product details...",
                            style: TextStyle(
                              color: AppColors.textPrimaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
