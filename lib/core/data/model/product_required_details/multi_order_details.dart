import 'package:ecommece_site_1688/core/data/model/product_required_details/order.dart';

class MultiOrderDetails{
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? shippingAddress;
  final String? customerWhatsapp;
  final List<Order> orders;

  MultiOrderDetails({
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.shippingAddress,
    this.customerWhatsapp,
    this.orders = const [],
  });
}