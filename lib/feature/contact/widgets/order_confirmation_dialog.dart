import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/model/product_required_details/order_details.dart';
import 'package:flutter/material.dart';

class OrderConfirmationDialog extends StatelessWidget {
  final OrderDetails orderDetails;

  const OrderConfirmationDialog({super.key, required this.orderDetails});

  @override
  Widget build(BuildContext context) {
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

            // Order Summary
            _buildOrderSummary(),

            const SizedBox(height: 20),

            // Contact Info
            _buildContactInfo(),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
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
            'Order Summary',
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              color: AppColors.textPrimaryColor,
            ),
          ),
          Divider(height: 20, color: AppColors.textSecondaryColor),
          _buildRow('Order ID:', '#${orderDetails.productId ?? 'N/A'}'),
          const SizedBox(height: 8),
          _buildRow('Product:', orderDetails.productTitle ?? 'N/A'),
          const SizedBox(height: 8),
          _buildRow('Variant:', orderDetails.productVariant ?? 'N/A'),
          const SizedBox(height: 8),
          _buildRow('Price:', orderDetails.productVariantPrice ?? 'N/A'),
          const SizedBox(height: 8),
          _buildRow('Quantity:', orderDetails.productQuantity ?? '1'),
          Divider(height: 20, color: AppColors.textSecondaryColor),
          _buildRow(
            'Total:',
            "৳ ${orderDetails.totalPrice ?? 'N/A'}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
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

          // Name with overflow handling
          _buildInfoRow('Name:', orderDetails.customerName),

          // Email with overflow handling
          _buildInfoRow('Email:', orderDetails.customerEmail),

          // Phone with overflow handling
          _buildInfoRow('Phone:', orderDetails.customerPhone),

          // WhatsApp (optional) with overflow handling
          if (orderDetails.customerWhatsapp?.isNotEmpty == true)
            _buildInfoRow('WhatsApp:', orderDetails.customerWhatsapp),

          // Address with overflow handling
          _buildInfoRow('Address:', orderDetails.shippingAddress)
        ],
      ),
    );
  }

  // Helper method for consistent label-value rows
  Widget _buildInfoRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 8,
          child: Text(
            value?.isNotEmpty == true ? value! : 'N/A',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimaryColor,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
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
        // Left side (label) - takes 40% of space
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 15 : 13,
              color: isTotal ? AppColors.textPrimaryColor : AppColors.textSecondaryColor,
            ),
          ),
        ),

        // Right side (value) - takes 60% of space
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primaryColor : AppColors.textPrimaryColor,
              fontSize: isTotal ? 16 : 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}