import 'dart:developer';
import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/riverpod/product_notifier.dart';
import 'package:ecommece_site_1688/core/data/riverpod/search_notifier.dart';
import 'package:ecommece_site_1688/core/service/currency_service.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "1688 Global",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        centerTitle: true,
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
                    // ✅ Search Bar
                    SearchBarSection(
                      controller: _searchController,
                      onSearch: () async {
                        final query = _searchController.text.trim();
                        await ref
                            .read(searchProvider.notifier)
                            .fetchSearchItems(query, 1);
                      },
                    ),

                    const SizedBox(height: 20),

                    // ✅ Product Section
                    Expanded(
                      child: searchState.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : searchState.error != null
                          ? const Center(
                              child: Text(
                                "No products found",
                                style: TextStyle(fontSize: 16),
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

                                      // Fetch the product and wait for it
                                      await ref
                                          .read(productProvider.notifier)
                                          .fetchProduct(numIid.toString());

                                      // Get the product state after fetch
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
                                                item: productState!
                                                    .data!
                                                    .item, // Pass the item
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
                                        );
                                      }
                                    } catch (e) {
                                      log("🔴 Exception: $e");
                                      Fluttertoast.showToast(msg: "Error: $e");
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                    // SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        await ref.read(searchProvider.notifier).loadMore();
                      },
                      child: Text("Load More"),
                    ),
                  ],
                ),
              ),
            ),
            if (isProductLoading) ...[
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
