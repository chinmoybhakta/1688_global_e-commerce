import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/model/product_required_details/order_details.dart';
import 'package:ecommece_site_1688/core/data/riverpod/currency_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderConfirmationDialog extends StatelessWidget {
  final List<OrderDetails> orders; // Now accepts a list

  const OrderConfirmationDialog({super.key, required this.orders});

  // Calculate total price for all orders
  String _calculateTotalPrice(WidgetRef ref) {
    double total = 0;
    for (var order in orders) {
      final price = double.tryParse(
            order.totalPrice?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0',
          ) ??
          0;
      total += price;
    }
    final currencySymbol = ref.read(currencyProvider.notifier).currencySymbol;
    return '$currencySymbol ${total.toStringAsFixed(2)}';
  }

  // Calculate total items count
  int _getTotalItems() {
    return orders.fold(0, (sum, order) {
      return sum + (int.tryParse(order.productQuantity ?? '0') ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final totalItems = _getTotalItems();
    // final totalPrice = _calculateTotalPrice();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle, 
                color: AppColors.primaryColor, 
                size: 60,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Confirmed!',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order has been placed successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14, 
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Orders Summary
            _buildOrdersSummary(),

            const SizedBox(height: 20),

            // Contact Info (same for all orders)
            if (orders.isNotEmpty) _buildContactInfo(orders.first),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Orders Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${orders.length} ${orders.length == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.textSecondaryColor),

          // List all orders
          ...orders.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final order = entry.value;
            return Column(
              children: [
                _buildOrderItem(index, order),
                if (index < orders.length)
                  const Divider(height: 16, color: AppColors.textSecondaryColor),
              ],
            );
          }),

          const Divider(height: 20, color: AppColors.textSecondaryColor),

          // Grand Total
          Consumer(
            builder: (_, ref, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Grand Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  Text(
                    _calculateTotalPrice(ref),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(int index, OrderDetails order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item #$index',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        _buildRow('Product:', order.productTitle ?? 'N/A'),
        const SizedBox(height: 2),
        _buildRow('Variant:', order.productVariant ?? 'N/A'),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: _buildRow('Price:', order.productVariantPrice ?? 'N/A'),
            ),
            Expanded(
              child: _buildRow('Qty:', order.productQuantity ?? '1'),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Item Total: ${order.totalPrice ?? 'N/A'}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(OrderDetails order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),

          // Name
          _buildInfoRow('Name:', order.customerName),

          // Email
          _buildInfoRow('Email:', order.customerEmail),

          // Phone
          _buildInfoRow('Phone:', order.customerPhone),

          // WhatsApp (optional)
          if (order.customerWhatsapp?.isNotEmpty == true)
            _buildInfoRow('WhatsApp:', order.customerWhatsapp),

          // Address
          _buildInfoRow('Address:', order.shippingAddress),
        ],
      ),
    );
  }

  // Helper method for consistent label-value rows
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryColor,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : 'N/A',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimaryColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: AppColors.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              foregroundColor: AppColors.textSecondaryColor,
            ),
            child: const Text('Close'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Text('Go to Home'),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, {bool isTotal = false}) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 14 : 12,
              color: isTotal ? AppColors.textPrimaryColor : AppColors.textSecondaryColor,
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primaryColor : AppColors.textPrimaryColor,
              fontSize: isTotal ? 15 : 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}