import 'package:cash/cash.dart';

class CurrencyService {
  // Cache exchange rates to avoid fetching on every conversion
  static bool _isInitialized = false;
  
  // Target currency (BDT for Bangladesh)
  static final Currency _targetCurrency = Currency.bdt;
  
  // Source currency (CNY for Chinese Yuan - 1688 uses CNY)
  static final Currency _sourceCurrency = Currency.cny;
  
  /// Initialize the currency service
  static Future<void> initialize() async {
    if (!_isInitialized) {
      // Fetch latest exchange rates
      Currency.refetchExchangeRates();
      _isInitialized = true;
    }
  }
  
  /// Convert CNY amount to BDT
  static double convertCnyToBdt(double cnyAmount) {
    final money = Cash(cnyAmount, _sourceCurrency);
    final moneyInBdt = money.convertTo(_targetCurrency);
    return moneyInBdt.value;
  }
}