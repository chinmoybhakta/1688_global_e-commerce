import 'dart:developer';
import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/riverpod/cart_notifier.dart';
import 'package:ecommece_site_1688/core/data/riverpod/product_notifier.dart';
import 'package:ecommece_site_1688/core/data/riverpod/search_notifier.dart';
import 'package:ecommece_site_1688/feature/home/widgets/app_bar_widget.dart';
import 'package:ecommece_site_1688/feature/home/widgets/category_section.dart';
import 'package:ecommece_site_1688/feature/home/widgets/minimal_carousel.dart';
import 'package:ecommece_site_1688/feature/home/widgets/minimal_loading_overlay.dart';
import 'package:ecommece_site_1688/feature/home/widgets/product_card.dart';
import 'package:ecommece_site_1688/feature/home/widgets/shimmer_product_card.dart';
import 'package:ecommece_site_1688/feature/product/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fluttertoast/fluttertoast.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

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

  @override
  Widget build(BuildContext context) {
    final productLoadingState = ref.watch(loadingProvider);
    final searchState = ref.watch(searchProvider);
    final productState = ref.watch(productProvider);
    final isProductLoading = productState?.isLoading ?? false;
    final isProductLoadingMore = searchState.isLoadingMore;
    // ignore: unused_local_variable
    final cartState = ref.watch(cartProvider);

    return MinimalLoadingOverlay(
      isLoading: productLoadingState,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: AppBarWidget(
                  searchController: _searchController,
                  onSearch: () async {
                    final query = _searchController.text.trim();
                    await ref
                        .read(searchProvider.notifier)
                        .fetchSearchItems(query, 1);
                  },
                ),
              ),

              // Category Section
              SliverToBoxAdapter(
                child: CategoryGridSection(
                  onCategoryTap: (categoryValue, categoryName) {
                    log('Selected: $categoryName ($categoryValue)');
                    // Search products by category
                    _searchController.text = categoryName;
                    ref
                        .read(searchProvider.notifier)
                        .fetchSearchItems(categoryValue, 1);
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Minimal Carousel - WRAP IT IN SliverToBoxAdapter
              SliverToBoxAdapter(
                child: MinimalCarousel(
                  onPageChanged: (index) {
                    log('Carousel page changed: $index');
                  },
                  onTap: (index) {
                    log('Banner tapped: $index');
                    // Navigate to banner-specific page
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Product Grid as Sliver
              if (isProductLoading && searchState.dataList.isEmpty)
                _buildShimmerGrid()
              else if (searchState.error != null &&
                  searchState.dataList.isEmpty)
                SliverToBoxAdapter(
                  child: _buildErrorState(ref, _searchController),
                )
              else
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = searchState.dataList[index];
                    return ProductCard(
                      title: item.title ?? "No Title",
                      imageUrl: item.picUrl!,
                      price: item.price,
                      onTap: () async {
                        ref.read(loadingProvider.notifier).state = true;
                        try {
                          final numIid = searchState.dataList[index].numIid;

                          log("🟡 Fetching product: $numIid");

                          await ref
                              .read(productProvider.notifier)
                              .fetchProduct(numIid.toString());

                          final productState = ref.read(productProvider);

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
                            log("🔴 Product data is null after fetch");
                            Fluttertoast.showToast(
                              msg: "Failed to load product data",
                              webBgColor: "#ff4000",
                              textColor: AppColors.backgroundColor,
                            );
                          }
                        } catch (e) {
                          log("🔴 Exception: $e");
                          Fluttertoast.showToast(
                            msg: "Error: $e",
                            webBgColor: "#ff4000",
                            textColor: AppColors.backgroundColor,
                          );
                        }
                        ref.read(loadingProvider.notifier).state = false;
                      },
                    );
                  }, childCount: searchState.dataList.length),
                ),

              if (isProductLoadingMore) ...[_buildShimmerGrid()],

              if (searchState.error != null &&
                  searchState.dataList.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        "You have reached the end of the results",
                        style: TextStyle(
                          color: AppColors.textSecondaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Load More Button as Sliver
                if ((!isProductLoading &&
                    searchState.dataList.isNotEmpty == true &&
                    !searchState.isLoadingMore))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: searchState.isLoadingMore
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
                          ),
                          child: searchState.isLoadingMore
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Load More Products"),
                        ),
                      ),
                    ),
                  ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  // Shimmer loading grid
  Widget _buildShimmerGrid() {
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: 10, // Show 6 shimmer cards while loading
      itemBuilder: (context, index) {
        return const ShimmerProductCard();
      },
    );
  }
}

Widget _buildErrorState(WidgetRef ref, TextEditingController controller) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 64, color: AppColors.textSecondaryColor),
        const SizedBox(height: 16),
        Text(
          "No products found",
          style: TextStyle(fontSize: 16, color: AppColors.textSecondaryColor),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            ref
                .read(searchProvider.notifier)
                .fetchSearchItems(controller.text.trim(), 1);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Try Again'),
        ),
      ],
    ),
  );
}
