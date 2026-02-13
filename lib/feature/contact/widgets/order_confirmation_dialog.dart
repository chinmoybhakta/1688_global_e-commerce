import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/model/product_required_details/order_details.dart';
import 'package:flutter/material.dart';

class OrderConfirmationDialog extends StatelessWidget {
  final OrderDetails orderDetails;

  const OrderConfirmationDialog({
    super.key,
    required this.orderDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Confirmed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order has been placed successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Divider(height: 20),
          _buildDialogRow('Order ID:', '#${orderDetails.productId ?? 'N/A'}'),
          const SizedBox(height: 8),
          _buildDialogRow('Product:', orderDetails.productTitle ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDialogRow('Variant:', orderDetails.productVariant ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDialogRow('Price:', orderDetails.productVariantPrice ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDialogRow('Quantity:', orderDetails.productQuantity ?? '1'),
          const Divider(height: 20),
          _buildDialogRow(
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
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text('Name: ${orderDetails.customerName}'),
          Text('Email: ${orderDetails.customerEmail}'),
          Text('Phone: ${orderDetails.customerPhone}'),
          if (orderDetails.customerWhatsapp?.isNotEmpty == true)
            Text('WhatsApp: ${orderDetails.customerWhatsapp}'),
          Text('Address: ${orderDetails.shippingAddress}'),
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
              Navigator.pop(context); // Close dialog
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Go to Home'),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.primaryColor : Colors.black,
          ),
        ),
      ],
    );
  }
}