import 'package:ecommece_site_1688/core/data/model/search_item/call_args_model.dart';
import 'package:ecommece_site_1688/core/data/model/search_item/item_data.dart';
import 'package:ecommece_site_1688/core/data/model/search_item/language_model.dart';

class SearchItemResponse {
  final ItemsData? items;
  final String? errorCode;
  final String? reason;
  final String? secache;
  final int? secacheTime;
  final String? secacheDate;
  final String? translateStatus;
  final double? translateTime;
  final LanguageModel? language;
  final String? error;
  final int? cache;
  final String? apiInfo;
  final String? executionTime;
  final String? serverTime;
  final String? clientIp;
  final CallArgsModel? callArgs;
  final String? apiType;
  final String? translateLanguage;
  final String? translateEngine;
  final String? serverMemory;
  final String? requestId;
  final String? lastId;

  SearchItemResponse({
    this.items,
    this.errorCode,
    this.reason,
    this.secache,
    this.secacheTime,
    this.secacheDate,
    this.translateStatus,
    this.translateTime,
    this.language,
    this.error,
    this.cache,
    this.apiInfo,
    this.executionTime,
    this.serverTime,
    this.clientIp,
    this.callArgs,
    this.apiType,
    this.translateLanguage,
    this.translateEngine,
    this.serverMemory,
    this.requestId,
    this.lastId,
  });

  factory SearchItemResponse.fromJson(Map<String, dynamic> json) {
    return SearchItemResponse(
      items: json['items'] != null ? ItemsData.fromJson(json['items']) : null,
      errorCode: json['error_code'],
      reason: json['reason'],
      secache: json['secache'],
      secacheTime: json['secache_time'],
      secacheDate: json['secache_date'],
      translateStatus: json['translate_status'],
      translateTime: (json['translate_time'] as num?)?.toDouble(),
      language: json['language'] != null
          ? LanguageModel.fromJson(json['language'])
          : null,
      error: json['error'],
      cache: json['cache'],
      apiInfo: json['api_info'],
      executionTime: json['execution_time'],
      serverTime: json['server_time'],
      clientIp: json['client_ip'],
      callArgs: json['call_args'] != null
          ? CallArgsModel.fromJson(json['call_args'])
          : null,
      apiType: json['api_type'],
      translateLanguage: json['translate_language'],
      translateEngine: json['translate_engine'],
      serverMemory: json['server_memory'],
      requestId: json['request_id'],
      lastId: json['last_id'],
    );
  }
}
