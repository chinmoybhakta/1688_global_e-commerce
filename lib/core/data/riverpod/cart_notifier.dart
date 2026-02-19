import 'package:ecommece_site_1688/core/data/model/product_required_details/multi_order_details.dart';
import 'package:ecommece_site_1688/core/data/model/product_required_details/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartNotifier extends StateNotifier<MultiOrderDetails?> {
  CartNotifier() : super(null);

  List<Order> orders = [];
  String customerName = '';
  String customerEmail = '';
  String customerPhone = '';
  String shippingAddress = '';
  String customerWhatsapp = '';

  void addToCart(Order order) {
    final existingIndex = orders.indexWhere(
      (o) => o.productId == order.productId && o.productVariant == order.productVariant
    );
    
    if (existingIndex != -1) {
      final existing = orders[existingIndex];
      int currentQty = int.parse(existing.productQuantity ?? "0");
      int addQty = int.parse(order.productQuantity ?? "1");
      int newQty = currentQty + addQty;
      
      // Check stock limit
      final stock = int.tryParse(existing.productStock ?? '0') ?? 0;
      if (stock > 0 && newQty > stock) {
        newQty = stock;
        Fluttertoast.showToast(
          msg: 'Only $stock items available in stock',
          backgroundColor: Colors.orange,
        );
      }
      
      // ✅ Using copyWith
      orders[existingIndex] = existing.copyWith(
        productQuantity: newQty.toString(),
      );
    } else {
      orders.add(order);
    }
    
    _updateState();
  }

  void removeFromCart(Order order) {
    orders.remove(order);
    _updateState();
  }

  void increaseQuantity(Order order) {
    int index = orders.indexOf(order);
    if (index != -1) {
      final existing = orders[index];
      int currentQty = int.parse(existing.productQuantity ?? "0");
      
      // Check stock limit
      final stock = int.tryParse(existing.productStock ?? '0') ?? 0;
      if (stock > 0 && currentQty >= stock) {
        Fluttertoast.showToast(
          msg: 'Maximum stock limit reached ($stock)',
          backgroundColor: Colors.orange,
        );
        return;
      }
      
      int newQty = currentQty + 1;
      
      // ✅ Using copyWith
      orders[index] = existing.copyWith(
        productQuantity: newQty.toString(),
      );
      
      _updateState();
    }
  }

  void decreaseQuantity(Order order) {
    int index = orders.indexOf(order);
    if (index != -1) {
      final existing = orders[index];
      int currentQty = int.parse(existing.productQuantity ?? "0");
      
      if (currentQty > 1) {
        int newQty = currentQty - 1;
        
        // ✅ Using copyWith
        orders[index] = existing.copyWith(
          productQuantity: newQty.toString(),
        );
        
        _updateState();
      } else {
        removeFromCart(order);
      }
    }
  }

  void addContactDetails(
    String customerName,
    String customerEmail,
    String customerPhone,
    String shippingAddress,
    String customerWhatsapp
  ) {
    this.customerName = customerName;
    this.customerEmail = customerEmail;
    this.customerPhone = customerPhone;
    this.shippingAddress = shippingAddress;
    this.customerWhatsapp = customerWhatsapp;

    _updateState();
  }

  void clearCart() {
    orders.clear();
    customerName = '';
    customerEmail = '';
    customerPhone = '';
    shippingAddress = '';
    customerWhatsapp = '';
    state = null;
  }

  void _updateState() {
    state = MultiOrderDetails(
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      shippingAddress: shippingAddress,
      customerWhatsapp: customerWhatsapp,
      orders: List.from(orders),
    );
  }

  double get cartTotal {
    return orders.fold(0, (sum, order) {
      final priceStr = order.productVariantPrice?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0';
      final price = double.tryParse(priceStr) ?? 0.0;
      final qty = int.tryParse(order.productQuantity ?? '0') ?? 0;
      
      return sum + (price * qty);
    });
  }

  int get totalItems {
    return orders.length;
  }

  bool get hasItems => orders.isNotEmpty;
  
  bool get hasContactInfo => 
      customerName.isNotEmpty && 
      customerEmail.isNotEmpty && 
      customerPhone.isNotEmpty && 
      shippingAddress.isNotEmpty;

  bool get hasStockIssue {
    for (var order in orders) {
      final qty = int.tryParse(order.productQuantity ?? '0') ?? 0;
      final stock = int.tryParse(order.productStock ?? '0') ?? 0;
      if (stock > 0 && qty > stock) {
        return true;
      }
    }
    return false;
  }

  int getItemQuantity(String productId, String variant) {
    final order = orders.firstWhere(
      (o) => o.productId == productId && o.productVariant == variant,
      orElse: () => Order(productQuantity: '0'),
    );
    return int.tryParse(order.productQuantity ?? '0') ?? 0;
  }

  bool isInCart(String productId, String variant) {
    return orders.any(
      (o) => o.productId == productId && o.productVariant == variant
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, MultiOrderDetails?>(
  (ref) => CartNotifier()
);