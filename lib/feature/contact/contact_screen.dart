import 'dart:developer';

import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/model/product_required_details/order_details.dart';
import 'package:ecommece_site_1688/core/data/riverpod/cart_notifier.dart';
import 'package:ecommece_site_1688/core/data/riverpod/currency_notifier.dart';
import 'package:ecommece_site_1688/core/service/google_sheets_service.dart';
import 'package:ecommece_site_1688/feature/contact/widgets/order_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactScreen extends ConsumerStatefulWidget {
  final List<OrderDetails> orderDetails; // Now accepts a list

  const ContactScreen({super.key, required this.orderDetails});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _whatsappController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _whatsappController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  // Calculate total price for all orders
  String _calculateTotalPrice() {
    double total = 0;
    for (var order in widget.orderDetails) {
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
    return widget.orderDetails.fold(0, (sum, order) {
      return sum + (int.tryParse(order.productQuantity ?? '0') ?? 0);
    });
  }

  Future<void> _showOrderSummaryDialog(WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      // Create complete order details for each order
      final List<OrderDetails> completeOrders = [];
      
      for (var order in widget.orderDetails) {
        final completeOrder = OrderDetails(
          productId: order.productId,
          productTitle: order.productTitle,
          productVariant: order.productVariant,
          productVariantPrice: order.productVariantPrice,
          productQuantity: order.productQuantity,
          totalPrice: order.totalPrice,
          customerName: _nameController.text.trim(),
          customerEmail: _emailController.text.trim(),
          customerPhone: _phoneController.text.trim(),
          shippingAddress: _addressController.text.trim(),
          customerWhatsapp: _whatsappController.text.trim(),
        );
        completeOrders.add(completeOrder);
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      );

      // Save each order to Google Sheets
      bool allSaved = true;
      for (var order in completeOrders) {
        final saved = await GoogleSheetsService.saveOrder(order);
        if (!saved) {
          allSaved = false;
          break;
        }
      }

      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      if (allSaved) {
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _addressController.clear();
        _whatsappController.clear();

        ref.read(cartProvider.notifier).clearCart();
        
        await showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return OrderConfirmationDialog(
              orders: completeOrders
            );
          },
        );
      } else {
        await showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Error',
              style: TextStyle(color: Colors.red),
            ),
            content: const Text('Failed to save orders. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = _getTotalItems();
    final totalPrice = _calculateTotalPrice();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Order Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            // Multiple Orders Summary Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
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
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
                            '$totalItems ${totalItems == 1 ? 'item' : 'items'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // List of orders
                    ...widget.orderDetails.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final order = entry.value;
                      return Column(
                        children: [
                          _buildOrderItem(index, order),
                          if (index < widget.orderDetails.length)
                            const Divider(height: 24, color: AppColors.textSecondaryColor),
                        ],
                      );
                    }),

                    const Divider(height: 24, color: AppColors.textSecondaryColor),

                    // Grand Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Grand Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                        Text(
                          totalPrice,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Contact Form Section (same as before)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text(
                    'Contact Details',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'Enter your full name',
                      labelStyle: const TextStyle(color: AppColors.textSecondaryColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address *',
                      hintText: 'Enter your email',
                      labelStyle: const TextStyle(color: AppColors.textSecondaryColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number *',
                      hintText: 'Enter your phone number',
                      labelStyle: const TextStyle(color: AppColors.textSecondaryColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.trim().length < 10 || !RegExp(r'^\+?[0-9\s]+$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // WhatsApp Number (Optional)
                  TextFormField(
                    controller: _whatsappController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'WhatsApp Number *',
                      hintText: 'Enter your WhatsApp number',
                      labelStyle: const TextStyle(color: AppColors.textSecondaryColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.chat_outlined, color: AppColors.primaryColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.trim().length < 10 || !RegExp(r'^\+?[0-9\s]+$').hasMatch(value)) {
                        return 'Please enter a valid WhatsApp number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Shipping Address
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Shipping Address *',
                      hintText: 'Enter your complete shipping address',
                      labelStyle: const TextStyle(color: AppColors.textSecondaryColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primaryColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your shipping address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  Consumer(
                    builder: (_, ref, _) {
                      return ElevatedButton(
                        onPressed: () => _showOrderSummaryDialog(ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Confirm Order (${widget.orderDetails.length} ${widget.orderDetails.length == 1 ? 'item' : 'items'})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ],
        ),
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildReadOnlyRow('Product:', order.productTitle ?? 'N/A'),
        const SizedBox(height: 4),
        _buildReadOnlyRow('Variant:', order.productVariant ?? 'N/A'),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _buildReadOnlyRow('Price:', order.productVariantPrice ?? 'N/A'),
            ),
            Expanded(
              child: _buildReadOnlyRow('Qty:', order.productQuantity ?? '1'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Item Total: ${order.totalPrice ?? 'N/A'}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }
}