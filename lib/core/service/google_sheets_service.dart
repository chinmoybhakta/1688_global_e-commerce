import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:ecommece_site_1688/core/data/model/product_required_details/order_details.dart';

class GoogleSheetsService {
  static const String _webAppUrl = 'https://script.google.com/macros/s/AKfycbzyRn1_Up0Pd_tb3RHY9p58H7dZMb0CZvPkK1n_pK5pObk7ZdLvrVvP0aOeZtLBkY8MFA/exec';
  
  static Future<bool> saveOrder(OrderDetails order) async {
    try {
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      
      log("🟡 Saving order to Google Sheets: $orderId");

      // Create a simple map - Dio will handle encoding
      final data = {
        'orderId': orderId,
        'productId': order.productId ?? '',
        'productTitle': order.productTitle ?? '',
        'productVariant': order.productVariant ?? '',
        'productVariantPrice': order.productVariantPrice ?? '',
        'productQuantity': order.productQuantity ?? '',
        'totalPrice': order.totalPrice ?? '',
        'customerName': order.customerName ?? '',
        'customerEmail': order.customerEmail ?? '',
        'customerPhone': order.customerPhone ?? '',
        'customerWhatsapp': order.customerWhatsapp ?? '',
        'shippingAddress': order.shippingAddress ?? '',
      };

      log("🟡 Sending data: $data");

      // Use Dio with urlencoded format
      final dio = Dio();
      
      final response = await dio.post(
        _webAppUrl,
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType, // This is key!
          followRedirects: true,
          maxRedirects: 5,
        ),
      );
      
      log("🟢 Response status: ${response.statusCode}");
      log("🟢 Response data: ${response.data}");
      
      return response.statusCode == 200;
      
    } on DioException catch (e) {
      log("🔴 DioException: ${e.message}");
      log("🔴 Response: ${e.response?.data}");
      return false;
    } catch (e) {
      log("🔴 Error: $e");
      return false;
    }
  }
}