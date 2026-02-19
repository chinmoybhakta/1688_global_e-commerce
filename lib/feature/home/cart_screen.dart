import 'dart:developer';

import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/model/product_required_details/multi_order_details.dart';
import 'package:ecommece_site_1688/core/data/model/product_required_details/order_details.dart';
import 'package:ecommece_site_1688/core/data/repository/repository_impl.dart';
import 'package:ecommece_site_1688/core/data/riverpod/cart_notifier.dart';
import 'package:ecommece_site_1688/core/data/riverpod/currency_notifier.dart';
import 'package:ecommece_site_1688/feature/contact/contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final cartItems = cartState?.orders ?? [];
    final isEmpty = cartItems.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Shopping Cart',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              child: Text(
                _isEditing ? 'Done' : 'Edit',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.primaryColor, height: 1),
        ),
      ),
      body: isEmpty
          ? _buildEmptyCart()
          : _buildCartContent(cartItems, cartNotifier),
      bottomNavigationBar: isEmpty
          ? null
          : _buildCheckoutBar(cartState, cartNotifier, ref),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Looks like you haven\'t added any items yet',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondaryColor),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue Shopping',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(List<dynamic> cartItems, CartNotifier cartNotifier) {
    return Column(
      children: [
        // Cart Items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildCartItem(item, index, cartNotifier);
            },
          ),
        ),

        // Bottom padding for checkout bar
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCartItem(dynamic item, int index, CartNotifier cartNotifier) {
    final int currentQty = int.tryParse(item.productQuantity ?? '0') ?? 1;
    final int maxStock = int.tryParse(item.productStock ?? '0') ?? 0;
    final bool isMaxStock = maxStock > 0 && currentQty >= maxStock;
    final currencySymbol = ref.read(currencyProvider.notifier).currencySymbol;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondaryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    item.productImage != null && item.productImage!.isNotEmpty
                    ? Image.network(
                        RepositoryImpl().getProxiedImageUrl(item.productImage!),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                          );
                        },
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
                      )
                    : Container(
                        color: AppColors.secondaryColor,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Delete Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.productTitle ?? 'Product',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isEditing)
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            cartNotifier.removeFromCart(item);
                            Fluttertoast.showToast(
                              msg: 'Item removed from cart',
                              backgroundColor: Colors.green,
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Variant
                  Text(
                    item.productVariant ?? 'Default',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Stock indicator
                  if (maxStock > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Stock: $maxStock available',
                        style: TextStyle(
                          fontSize: 11,
                          color: maxStock < 10 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Price and Quantity Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        item.productVariantPrice ?? '$currencySymbol 0',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),

                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryColor),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Decrease
                            InkWell(
                              onTap: currentQty > 1
                                  ? () => cartNotifier.decreaseQuantity(item)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: currentQty > 1
                                      ? AppColors.primaryColor
                                      : Colors.grey,
                                ),
                              ),
                            ),

                            // Quantity
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                border: Border.symmetric(
                                  vertical: BorderSide(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                              child: Text(
                                item.productQuantity ?? '1',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryColor,
                                ),
                              ),
                            ),

                            // Increase - Limited by stock
                            InkWell(
                              onTap: !isMaxStock
                                  ? () => cartNotifier.increaseQuantity(item)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.add,
                                  size: 16,
                                  color: !isMaxStock
                                      ? AppColors.primaryColor
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Max stock warning
                  if (isMaxStock)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Maximum stock reached',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Total price for this item
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Total: ${_calculateItemTotal(item)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateItemTotal(dynamic item) {
    final price =
        double.tryParse(
          item.productVariantPrice?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0',
        ) ??
        0;
    final qty = int.tryParse(item.productQuantity ?? '0') ?? 0;
    final total = price * qty;
    final currencySymbol = ref.read(currencyProvider.notifier).currencySymbol;
    return '$currencySymbol ${total.toStringAsFixed(2)}';
  }

  Widget _buildCheckoutBar(
    MultiOrderDetails? cartState,
    CartNotifier cartNotifier,
    WidgetRef ref,
  ) {
    final cartItems = cartState?.orders ?? [];
    final subtotal = cartNotifier.cartTotal;
    final itemCount = cartNotifier.totalItems;
    final currencySymbol = ref.read(currencyProvider.notifier).currencySymbol;

    // Check if any item exceeds stock
    bool hasStockIssue = false;
    for (var item in cartItems) {
      final qty = int.tryParse(item.productQuantity ?? '0') ?? 0;
      final stock = int.tryParse(item.productStock ?? '0') ?? 0;
      if (stock > 0 && qty > stock) {
        // ✅ Only check if stock > 0
        hasStockIssue = true;
        break;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Summary - Without shipping
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildSummaryRow(
                  'Grand Total',
                  '$currencySymbol ${subtotal.toStringAsFixed(2)}',
                  isTotal: true,
                ),
              ),
              const SizedBox(height: 16),

              // Stock warning if any
              if (hasStockIssue)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Some items exceed available stock',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),

              // Checkout Button
              ElevatedButton(
                onPressed: hasStockIssue
                    ? null
                    : () {
                        // Navigate to ContactScreen with cart details
                        final List<OrderDetails>
                        orderDetailsList = cartItems.map((item) {
                          return OrderDetails(
                            productId: item.productId,
                            productTitle: item.productTitle,
                            productVariant: item.productVariant,
                            productVariantPrice: item.productVariantPrice,
                            productQuantity: item.productQuantity,
                            totalPrice: _calculateItemTotal(
                              item,
                            ), // Use your existing calculation
                            // Customer fields will be filled in ContactScreen
                            customerName: '',
                            customerEmail: '',
                            customerPhone: '',
                            shippingAddress: '',
                            customerWhatsapp: '',
                          );
                        }).toList();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ContactScreen(orderDetails: orderDetailsList),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text(
                  hasStockIssue
                      ? 'Please adjust quantities'
                      : 'Place Order ($itemCount ${itemCount == 1 ? 'item' : 'items'})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? AppColors.textPrimaryColor
                : AppColors.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal
                ? AppColors.primaryColor
                : AppColors.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}
