import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/riverpod/currency_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrencyDropdown extends ConsumerWidget {
  final Color? backgroundColor;
  final Color? textColor;

  const CurrencyDropdown({
    super.key,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCurrency = ref.watch(currencyProvider);
    final currencyNotifier = ref.read(currencyProvider.notifier);

    return DropdownButton<DisplayCurrency>(
      focusColor: Colors.transparent,
      value: currentCurrency,
      underline: const SizedBox(),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: textColor ?? AppColors.textPrimaryColor,
      ),
      items: [
        _buildDropdownItem('¥ 🇨🇳', DisplayCurrency.cny),
        _buildDropdownItem('\$ 🇺🇸', DisplayCurrency.usd),
        _buildDropdownItem('৳ 🇧🇩', DisplayCurrency.bdt),
      ],
      onChanged: (currency) {
        if (currency != null) {
          currencyNotifier.setCurrency(currency);
        }
      },
      dropdownColor: backgroundColor ?? Colors.white,
      style: TextStyle(
        color: textColor ?? AppColors.textPrimaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  DropdownMenuItem<DisplayCurrency> _buildDropdownItem(
    String label,
    DisplayCurrency value,
  ) {
    return DropdownMenuItem(
      value: value,
      child: Row(children: [
        Text(label),
      ],),
    );
  }
}