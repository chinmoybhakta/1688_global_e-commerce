import 'package:ecommece_site_1688/core/resource/font_manager.dart';
import 'package:flutter/material.dart';

const defaultTextColor = Color(0xFF999999);

TextStyle _getTextStyle(double fontSize ,String fontFamily,FontWeight fontWeight,Color color){
  return TextStyle(fontSize:fontSize,fontFamily: fontFamily, fontWeight: fontWeight, color: color);
}

TextStyle getSmallStyle({double fontSize=FontSize.s12, FontWeight fontWeight = FontWeightManager.regural, Color color = defaultTextColor}){
  return _getTextStyle(fontSize, FontConstants.fontFamily, fontWeight, color);
}

TextStyle getMediumStyle({double fontSize=FontSize.s14, FontWeight fontWeight = FontWeightManager.regural, Color color = defaultTextColor}){
  return _getTextStyle(fontSize, FontConstants.fontFamily,fontWeight, color);
}

TextStyle getExtraMediumStyle({double fontSize=FontSize.s16, FontWeight fontWeight = FontWeightManager.regural, Color color = defaultTextColor}){
  return _getTextStyle(fontSize, FontConstants.fontFamily,fontWeight, color);
}

TextStyle getSemiLargeStyle({double fontSize=FontSize.s24, FontWeight fontWeight = FontWeightManager.semiBold, Color color = defaultTextColor}){
  return _getTextStyle(fontSize, FontConstants.fontFamily, fontWeight, color);
}

TextStyle getLargeStyle({double fontSize=FontSize.s28, FontWeight fontWeight = FontWeightManager.bold, Color color = defaultTextColor}){
  return _getTextStyle(fontSize, FontConstants.fontFamily, fontWeight, color);
}