import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/model/get_item/item.dart';
import 'package:ecommece_site_1688/core/data/model/product_required_details/order.dart';
import 'package:ecommece_site_1688/core/data/model/product_required_details/order_details.dart';
import 'package:ecommece_site_1688/core/data/repository/repository_impl.dart';
import 'package:ecommece_site_1688/core/data/riverpod/cart_notifier.dart';
import 'package:ecommece_site_1688/core/service/currency_service.dart';
import 'package:ecommece_site_1688/feature/contact/contact_screen.dart';
import 'package:ecommece_site_1688/feature/product/widgets/build_detail_row.dart';
import 'package:ecommece_site_1688/feature/product/widgets/build_seller_score.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return 999;
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
      _quantityController.text = _quantity.toString();
      if (value.isNotEmpty) {
        Fluttertoast.showToast(
          msg: "Please enter a valid number",
          backgroundColor: Colors.red,
        );
      }
    }
  }

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

    if (widget.item?.picUrl != null &&
        widget.item?.picUrl?.isNotEmpty == true) {
      _allImages.add(widget.item?.picUrl ?? '');
    }

    if (widget.item?.itemImgs != null) {
      _allImages.addAll(
        (widget.item?.itemImgs ?? [])
            .where((img) => img.url != null && img.url!.isNotEmpty)
            .map((img) => img.url!)
            .toList(),
      );
    }

    if (_allImages.isEmpty) {
      _allImages.add(
        'https://user-images.githubusercontent.com/24841626/43708951-e86d62b2-996b-11e8-9d2c-ee2599db49e7.png',
      );
    }
  }

  Future<void> _openWhatsApp() async {
    const String businessPhone = '8801765808909';
    const String message =
        "Hello, I'm interested in your products from 1688 Global!";
    final encodedMessage = Uri.encodeComponent(message);

    final whatsappUrl =
        'whatsapp://send?phone=$businessPhone&text=$encodedMessage';
    final fallbackUrl = 'https://wa.me/$businessPhone?text=$encodedMessage';

    try {
      if (await launchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
        await launchUrl(
          Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not open WhatsApp';
      }
    } catch (e) {
      debugPrint('Error opening WhatsApp: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please install WhatsApp to chat with us'),
            backgroundColor: Colors.orange,
          ),
        );
      }
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

  String _getCurrentPrice() {
    if (_selectedSkuIndex >= 0 &&
        widget.item?.skus?.sku != null &&
        _selectedSkuIndex < (widget.item?.skus?.sku?.length ?? 0)) {
      final sku = widget.item?.skus?.sku?[_selectedSkuIndex];
      final formattedPrice = getFormattedPrice(sku?.price);
      return formattedPrice ?? 'Price unavailable';
    } else {
      return getFormattedPrice(widget.item?.price) ?? 'Price unavailable';
    }
  }

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
        return getFormattedPrice(sku?.orginalPrice);
      }
    } else if (widget.item?.orginalPrice != null &&
        widget.item?.orginalPrice!.isNotEmpty == true) {
      return getFormattedPrice(widget.item?.orginalPrice);
    }
    return null;
  }

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

  Future<void> _shareProduct() async {
    final product = widget.item;
    if (product == null) return;

    // Create your product URL (replace with your actual domain)
    final productUrl = widget.item?.picUrl;
    final shareText =
        '''
Check out this product on 1688 Global!

${product.title}

Price: ${_getCurrentPrice()}

View product: $productUrl

Go to this website to order: https://1688global.com.bd
''';

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: 'Check out this product on 1688 Global!',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
      Fluttertoast.showToast(
        msg: 'Could not open share sheet',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final discount = _getDiscountPercentage();
    final originalPrice = _getOriginalPrice();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimaryColor,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite
                        ? Colors.red
                        : AppColors.textSecondaryColor,
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.share, color: AppColors.textSecondaryColor),
                  onPressed: () => _shareProduct(),
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
                            color: AppColors.backgroundColor,
                            child: Image.network(
                              RepositoryImpl().getProxiedImageUrl(imageUrl),
                              fit: BoxFit.contain,
                              // ✅ Loading UI
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;

                                    return Container(
                                      color: AppColors.secondaryColor,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.primaryColor,
                                              ),
                                        ),
                                      ),
                                    );
                                  },

                              // ❌ Error UI
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
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black, blurRadius: 4),
                          ],
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${_allImages.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: AppColors.textPrimaryColor,
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
                          color: AppColors.primaryColor,
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
                        style: TextStyle(
                          color: AppColors.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryColor),
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
                        if (originalPrice != null &&
                            originalPrice != _getCurrentPrice()) ...[
                          const SizedBox(width: 12),
                          Text(
                            originalPrice,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondaryColor,
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
                    Text(
                      'Select Variant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 150,
                            mainAxisExtent: 50,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
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
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : AppColors.secondaryColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : AppColors.primaryColor,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                sku?.propertiesName?.split(';').last ??
                                    'Option ${index + 1}',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimaryColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      },
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
                            : AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  // Quantity Selector
                  Row(
                    children: [
                      Text(
                        'Quantity:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.remove,
                                size: 20,
                                color: AppColors.primaryColor,
                              ),
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
                                style: TextStyle(
                                  color: AppColors.textPrimaryColor,
                                ),
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
                                onTapOutside: (event) {
                                  _validateAndUpdateQuantity(
                                    _quantityController.text,
                                  );
                                  _quantityFocusNode.unfocus();
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add,
                                size: 20,
                                color: AppColors.primaryColor,
                              ),
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
                    const Divider(color: AppColors.textSecondaryColor),
                    const SizedBox(height: 16),
                    Text(
                      'Seller Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryColor),
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimaryColor,
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
                  const Divider(color: AppColors.textSecondaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildDetailRow('Brand', widget.item?.brand ?? 'N/A'),
                  buildDetailRow('Location', widget.item?.location ?? 'N/A'),
                  buildDetailRow('Model Number', widget.item?.cid ?? 'N/A'),

                  const SizedBox(height: 20),

                  // Description Images
                  if (widget.item?.descImg != null &&
                      widget.item?.descImg!.isNotEmpty == true) ...[
                    const Divider(color: AppColors.textSecondaryColor),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(widget.item?.descImg ?? []).map(
                      (url) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Image.network(
                          RepositoryImpl().getProxiedImageUrl(url),
                          fit: BoxFit.cover,
                          // ✅ Loading UI
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;

                            return Container(
                              color: AppColors.secondaryColor,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            );
                          },

                          // ❌ Error UI
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
                        ),
                      ),
                    ),
                  ],

                  // Specifications/Props
                  if (widget.item?.props != null &&
                      widget.item?.props?.isNotEmpty == true) ...[
                    const Divider(color: AppColors.textSecondaryColor),
                    const SizedBox(height: 16),
                    Text(
                      'Specifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(widget.item?.props ?? []).map(
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
                                  color: AppColors.textSecondaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                prop.value ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
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
              color: AppColors.primaryColor,
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Add to Cart
              Expanded(
                flex: 2,
                child: Consumer(
                  builder: (_, ref, _) {
                    return ElevatedButton(
                      onPressed: () {
                        if ((widget.item?.skus?.sku?.isNotEmpty ?? false) &&
                            _selectedSkuIndex == -1) {
                          Fluttertoast.showToast(
                            msg: "Please select a variant",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                          return;
                        }
                        final singleOrderDetails = Order(
                          productId: widget.item?.numIid,
                          productTitle: widget.item?.title,
                          productVariant:
                              (widget.item?.skus?.sku?.isNotEmpty ?? false)
                              ? (widget
                                    .item
                                    ?.skus
                                    ?.sku?[_selectedSkuIndex]
                                    .propertiesName)
                              : "N/A",
                          productVariantPrice: _getCurrentPrice(),
                          productQuantity: _quantity.toString(),
                          productStock: _getCurrentStock().toString(),
                          productImage: widget.item?.picUrl,
                        );

                        try {
                          ref
                              .read(cartProvider.notifier)
                              .addToCart(singleOrderDetails);
                          Fluttertoast.showToast(
                            msg: "Added to cart",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: AppColors.primaryColor,
                            textColor: Colors.white,
                          );
                        } catch (e) {
                          log("Error in adding to cart: $e");
                          Fluttertoast.showToast(
                            msg: "Failed to add to cart",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(width: 24),

              // Place Order
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if ((widget.item?.skus?.sku?.isNotEmpty ?? false) &&
                        _selectedSkuIndex == -1) {
                      Fluttertoast.showToast(
                        msg: "Please select a variant",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                      return;
                    }
                    final orderDetails = OrderDetails(
                      productId: widget.item?.numIid,
                      productTitle: widget.item?.title,
                      productVariant:
                          (widget.item?.skus?.sku?.isNotEmpty ?? false)
                          ? (widget
                                .item
                                ?.skus
                                ?.sku?[_selectedSkuIndex]
                                .propertiesName)
                          : "N/A",
                      productVariantPrice: _getCurrentPrice(),
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

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ContactScreen(orderDetails: [orderDetails]),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              Spacer(),
              // Chat/Customer Service
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: _openWhatsApp,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: AppColors.primaryColor,
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
            ],
          ),
        ),
      ),
    );
  }
}
