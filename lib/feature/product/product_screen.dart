import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/model/get_item/item.dart';
import 'package:ecommece_site_1688/core/data/model/product_required_details/order_details.dart';
import 'package:ecommece_site_1688/core/service/currency_service.dart';
import 'package:ecommece_site_1688/feature/contact/contact_screen.dart';
import 'package:ecommece_site_1688/feature/product/widgets/build_detail_row.dart';
import 'package:ecommece_site_1688/feature/product/widgets/build_seller_score.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductScreen extends StatefulWidget {
  final Item? item;
  const ProductScreen({super.key, required this.item});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  int _selectedSkuIndex = -1;
  int _quantity = 1;

  // Collect all images for the carousel
  late List<String> _allImages;

  int _getCurrentStock() {
    if (_selectedSkuIndex >= 0 &&
        widget.item?.skus?.sku != null &&
        _selectedSkuIndex < (widget.item?.skus?.sku?.length ?? 0)) {
      final sku = widget.item?.skus?.sku?[_selectedSkuIndex];
      return int.tryParse(sku?.quantity ?? '0') ?? 0;
    }
    // If no SKU selected or no SKU data, return a large number or 0
    return 999; // or return 0 if you want to disable when no variant selected
  }

  void _validateAndUpdateQuantity(String value) {
    final newQuantity = int.tryParse(value);
    final maxStock = _getCurrentStock();

    if (newQuantity != null) {
      if (newQuantity < 1) {
        setState(() {
          _quantity = 1;
          _quantityController.text = '1';
        });
        Fluttertoast.showToast(
          msg: "Quantity cannot be less than 1",
          backgroundColor: Colors.orange,
        );
      } else if (newQuantity > maxStock) {
        setState(() {
          _quantity = maxStock;
          _quantityController.text = maxStock.toString();
        });
        Fluttertoast.showToast(
          msg: maxStock > 0
              ? "Only $maxStock items available in stock"
              : "This variant is out of stock",
          backgroundColor: Colors.orange,
        );
      } else {
        setState(() {
          _quantity = newQuantity;
        });
      }
    } else {
      // Invalid input, revert to previous quantity
      _quantityController.text = _quantity.toString();
      if (value.isNotEmpty) {
        Fluttertoast.showToast(
          msg: "Please enter a valid number",
          backgroundColor: Colors.red,
        );
      }
    }
  }

  // Add TextEditingController for quantity
  late final TextEditingController _quantityController;
  late final FocusNode _quantityFocusNode;

  @override
  void initState() {
    super.initState();
    _prepareImages();
    _quantityController = TextEditingController(text: '$_quantity');
    _quantityFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  void _prepareImages() {
    _allImages = [];

    // Add main image
    if (widget.item?.picUrl != null &&
        widget.item?.picUrl?.isNotEmpty == true) {
      _allImages.add(widget.item?.picUrl ?? '');
    }

    // Add item images
    if (widget.item?.itemImgs != null) {
      _allImages.addAll(
        (widget.item?.itemImgs ?? [])
            .where((img) => img.url != null && img.url!.isNotEmpty)
            .map((img) => img.url!)
            .toList(),
      );
    }

    // If no images, add placeholder
    if (_allImages.isEmpty) {
      _allImages.add(
        'https://user-images.githubusercontent.com/24841626/43708951-e86d62b2-996b-11e8-9d2c-ee2599db49e7.png',
      );
    }
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

  // Get current price based on selection (in BDT)
  String _getCurrentPrice() {
    if (_selectedSkuIndex >= 0 &&
        widget.item?.skus?.sku != null &&
        _selectedSkuIndex < (widget.item?.skus?.sku?.length ?? 0)) {
      final sku = widget.item?.skus?.sku?[_selectedSkuIndex];
      // Use getFormattedPrice to convert SKU price to BDT
      final formattedPrice = getFormattedPrice(sku?.price);
      return formattedPrice ?? 'Price unavailable';
    } else {
      // Use getFormattedPrice to convert main item price to BDT
      return getFormattedPrice(widget.item?.price) ?? 'Price unavailable';
    }
  }

  // Get original price for comparison (in BDT)
  String? _getOriginalPrice() {
    if (_selectedSkuIndex >= 0 &&
        widget.item?.skus?.sku != null &&
        _selectedSkuIndex < (widget.item?.skus?.sku?.length ?? 0)) {
      final sku = widget.item?.skus?.sku?[_selectedSkuIndex];
      if (sku?.orginalPrice != null &&
          (double.tryParse(
                    sku?.orginalPrice?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0',
                  ) ??
                  0) >
              0) {
        // Use getFormattedPrice to convert SKU original price to BDT
        return getFormattedPrice(sku?.orginalPrice);
      }
    } else if (widget.item?.orginalPrice != null &&
        widget.item?.orginalPrice!.isNotEmpty == true) {
      // Use getFormattedPrice to convert main item original price to BDT
      return getFormattedPrice(widget.item?.orginalPrice);
    }
    return null;
  }

  // Calculate discount percentage
  int? _getDiscountPercentage() {
    double currentPrice = 0;
    double originalPrice = 0;

    if (_selectedSkuIndex >= 0 &&
        widget.item?.skus?.sku != null &&
        _selectedSkuIndex < (widget.item?.skus?.sku?.length ?? 0)) {
      final sku = widget.item?.skus?.sku?[_selectedSkuIndex];
      currentPrice = double.tryParse(sku?.price ?? '0') ?? 0;
      originalPrice = double.tryParse(sku?.orginalPrice ?? '0') ?? 0;
    } else {
      final currentPriceStr = widget.item?.price ?? '0';
      final originalPriceStr = widget.item?.orginalPrice ?? '0';

      currentPrice =
          double.tryParse(currentPriceStr.replaceAll(RegExp(r'[^\d.]'), '')) ??
          0;
      originalPrice =
          double.tryParse(originalPriceStr.replaceAll(RegExp(r'[^\d.]'), '')) ??
          0;
    }

    if (originalPrice > 0 && currentPrice < originalPrice) {
      return ((originalPrice - currentPrice) / originalPrice * 100).round();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final discount = _getDiscountPercentage();
    final originalPrice = _getOriginalPrice();
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with image carousel
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.black87,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.black87),
                  onPressed: () {
                    // Share functionality
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image Carousel
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 400,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: _allImages.length > 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                    items: _allImages.map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey[100],
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),

                  // Image Counter
                  if (_allImages.length > 1)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${_allImages.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.item?.title ?? 'Product Title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Rating and Sales
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '4.5',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.star, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${widget.item?.totalSold ?? 0} sold',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _getCurrentPrice(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        if (originalPrice != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            originalPrice,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        if (discount != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-$discount%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SKU/Variant Selection
                  if (widget.item?.skus?.sku != null &&
                      widget.item?.skus?.sku?.isNotEmpty == true) ...[
                    const Text(
                      'Select Variant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.item?.skus?.sku?.length ?? 0,
                        itemBuilder: (context, index) {
                          final sku = widget.item?.skus?.sku?[index];
                          final isSelected = _selectedSkuIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSkuIndex = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  sku?.propertiesName?.split(';').last ??
                                      'Option ${index + 1}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_selectedSkuIndex >= 0) ...[
                    const SizedBox(width: 12),
                    Text(
                      'Stock: ${_getCurrentStock()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _getCurrentStock() < 10
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  // Quantity Selector
                  Row(
                    children: [
                      const Text(
                        'Quantity:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 20),
                              onPressed: _quantity > 1
                                  ? () {
                                      setState(() {
                                        _quantity--;
                                        _quantityController.text = _quantity
                                            .toString();
                                      });
                                    }
                                  : null,
                            ),
                            SizedBox(
                              width: 60,
                              child: TextField(
                                controller: _quantityController,
                                focusNode: _quantityFocusNode,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                                onSubmitted: _validateAndUpdateQuantity,
                                onEditingComplete: () {
                                  _validateAndUpdateQuantity(
                                    _quantityController.text,
                                  );
                                  _quantityFocusNode.unfocus();
                                },
                                // Add focus listener to validate when losing focus
                                onTapOutside: (event) {
                                  _validateAndUpdateQuantity(
                                    _quantityController.text,
                                  );
                                  _quantityFocusNode.unfocus();
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              onPressed: () {
                                final maxStock = _getCurrentStock();
                                if (_quantity < maxStock) {
                                  setState(() {
                                    _quantity++;
                                    _quantityController.text = _quantity
                                        .toString();
                                  });
                                } else {
                                  Fluttertoast.showToast(
                                    msg:
                                        "Maximum stock limit reached ($maxStock)",
                                    backgroundColor: Colors.orange,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Seller Information
                  if (widget.item?.sellerInfo != null) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Seller Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primaryColor,
                            child: Text(
                              widget.item?.sellerInfo?.shopName?.substring(
                                    0,
                                    1,
                                  ) ??
                                  'S',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item?.sellerInfo?.shopName ??
                                      'Shop Name',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    buildSellerScore(
                                      'Item',
                                      widget.item?.sellerInfo?.itemScore ?? '0',
                                    ),
                                    const SizedBox(width: 16),
                                    buildSellerScore(
                                      'Service',
                                      widget.item?.sellerInfo?.scoreP ?? '0',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Product Details Section
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Product Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  buildDetailRow('Brand', widget.item?.brand ?? 'N/A'),
                  buildDetailRow('Location', widget.item?.location ?? 'N/A'),
                  buildDetailRow('Model Number', widget.item?.cid ?? 'N/A'),

                  const SizedBox(height: 20),

                  // Description Images
                  if (widget.item?.descImg != null &&
                      widget.item?.descImg!.isNotEmpty == true) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(widget.item?.descImg ?? [])
                        .map(
                          (url) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 50),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                  ],

                  // Specifications/Props
                  if (widget.item?.props != null &&
                      widget.item?.props?.isNotEmpty == true) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Specifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(widget.item?.props ?? [])
                        .map(
                          (prop) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    prop.name ?? '',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    prop.value ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Chat/Customer Service
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_outlined,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chat',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Buy Now
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if ((widget.item?.skus?.sku?.isNotEmpty ?? false) && _selectedSkuIndex == -1) {
                      Fluttertoast.showToast(
                        msg: "Please select a variant",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                      return;
                    }
                    // Create OrderDetails with product data
                    final orderDetails = OrderDetails(
                      productId: widget.item?.numIid,
                      productTitle: widget.item?.title,
                      productVariant: (widget.item?.skus?.sku?.isNotEmpty ?? false) ? (widget
                          .item
                          ?.skus
                          ?.sku?[_selectedSkuIndex]
                          .propertiesName) : "N/A",
                      productVariantPrice: _getCurrentPrice(), // Your BDT price
                      productQuantity: _quantity.toString(),
                      totalPrice:
                          ((double.tryParse(
                                        _getCurrentPrice().replaceAll(
                                          RegExp(r'[^\d.]'),
                                          '',
                                        ),
                                      ) ??
                                      0) *
                                  _quantity)
                              .toStringAsFixed(2),
                    );

                    // Navigate to contact screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ContactScreen(orderDetails: orderDetails),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
