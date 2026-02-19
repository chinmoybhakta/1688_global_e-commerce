import 'package:flutter_riverpod/legacy.dart';

enum DisplayCurrency { cny, usd, bdt }

class CurrencyNotifier extends StateNotifier<DisplayCurrency> {
  CurrencyNotifier() : super(DisplayCurrency.bdt); // Default to BDT

  void setCurrency(DisplayCurrency currency) {
    state = currency;
  }

  void toggleCurrency() {
    switch (state) {
      case DisplayCurrency.cny:
        state = DisplayCurrency.usd;
        break;
      case DisplayCurrency.usd:
        state = DisplayCurrency.bdt;
        break;
      case DisplayCurrency.bdt:
        state = DisplayCurrency.cny;
        break;
    }
  }

  // Helper to get currency symbol
  String get currencySymbol {
    switch (state) {
      case DisplayCurrency.cny:
        return '¥';
      case DisplayCurrency.usd:
        return '\$';
      case DisplayCurrency.bdt:
        return '৳';
    }
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, DisplayCurrency>(
  (ref) => CurrencyNotifier(),
);