
import 'dart:developer';
import 'package:ecommece_site_1688/core/data/riverpod/currency_notifier.dart';
import 'package:ecommece_site_1688/core/service/currency_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider that takes original price and returns formatted price based on selected currency
final formattedPriceProvider = Provider.family<String, String?>((ref, originalPrice) {
  final selectedCurrency = ref.watch(currencyProvider);
  
  if (originalPrice == null || originalPrice.isEmpty) {
    return 'N/A';
  }

  try {
    // Extract numeric value from price string
    final numericString = originalPrice.replaceAll(RegExp(r'[^\d.]'), '');
    final double priceInCNY = double.tryParse(numericString) ?? 0.0;
    
    String formattedPrice;
    String symbol;
    
    switch (selectedCurrency) {
      case DisplayCurrency.cny:
        formattedPrice = priceInCNY.toStringAsFixed(2);
        symbol = '¥';
        break;
      case DisplayCurrency.usd:
        final usdPrice = CurrencyService.convertCnyToUsd(priceInCNY);
        formattedPrice = usdPrice.toStringAsFixed(2);
        symbol = '\$';
        break;
      case DisplayCurrency.bdt:
        final bdtPrice = CurrencyService.convertCnyToBdt(priceInCNY);
        formattedPrice = bdtPrice.toStringAsFixed(2);
        symbol = '৳';
        break;
    }
    
    return '$symbol $formattedPrice';
    
  } catch (e) {
    log('Error formatting price: $e');
    return 'N/A';
  }
});