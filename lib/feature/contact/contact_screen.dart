import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/model/product_required_details/order_details.dart';
import 'package:ecommece_site_1688/core/service/google_sheets_service.dart';
import 'package:ecommece_site_1688/feature/contact/widgets/order_confirmation_dialog.dart';
import 'package:flutter/material.dart';

class ContactScreen extends StatefulWidget {
  final OrderDetails orderDetails;

  const ContactScreen({super.key, required this.orderDetails});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
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

  Future<void> _showOrderSummaryDialog() async {
    if (_formKey.currentState!.validate()) {
      final completeOrder = OrderDetails(
        productId: widget.orderDetails.productId,
        productTitle: widget.orderDetails.productTitle,
        productVariant: widget.orderDetails.productVariant,
        productVariantPrice: widget.orderDetails.productVariantPrice,
        productQuantity: widget.orderDetails.productQuantity,
        totalPrice: widget.orderDetails.totalPrice,
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        shippingAddress: _addressController.text.trim(),
        customerWhatsapp: _whatsappController.text.trim(),
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      );

      final saved = await GoogleSheetsService.saveOrder(completeOrder);

      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      if (saved) {
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _addressController.clear();
        _whatsappController.clear();
        
        await showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return OrderConfirmationDialog(orderDetails: completeOrder);
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
            content: const Text('Failed to save order. Please try again.'),
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

  void _submitOrder() {
    _showOrderSummaryDialog();
  }

  @override
  Widget build(BuildContext context) {
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
            // Product Summary Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildReadOnlyRow(
                      'Product:',
                      widget.orderDetails.productTitle ?? 'N/A',
                    ),
                    const Divider(height: 16, color: AppColors.textSecondaryColor),
                    _buildReadOnlyRow(
                      'Variant:',
                      widget.orderDetails.productVariant ?? 'N/A',
                    ),
                    const Divider(height: 16, color: AppColors.textSecondaryColor),
                    Row(
                      children: [
                        Expanded(
                          child: _buildReadOnlyRow(
                            'Price:',
                            widget.orderDetails.productVariantPrice ?? 'N/A',
                          ),
                        ),
                        Expanded(
                          child: _buildReadOnlyRow(
                            'Quantity:',
                            widget.orderDetails.productQuantity ?? '1',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Contact Form Section
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
                  ElevatedButton(
                    onPressed: _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Confirm Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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