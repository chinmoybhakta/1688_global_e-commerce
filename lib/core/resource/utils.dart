import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class Utils {
  static String formatDateTime(DateTime date) {
    final DateFormat formatter = DateFormat(
      'yyyy-MM-dd',
    ); // Customize your format here
    return formatter.format(date);
  }

  static Future<bool?> showErrorToast({required String message}) {
    return Fluttertoast.showToast(
      msg: message,
      webBgColor: "#ff4000",
      textColor: AppColors.backgroundColor,
    );
  }

  static void showToast({
    required String message,
    required Color backgroundColor,
    required Color textColor,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
}