import 'package:ecommece_site_1688/core/data/model/get_item/item.dart';

class ProductResponse {
  final Item? item;
  final String? error;
  final String? errorCode;
  final String? secache;
  final String? secacheTime;        // Changed from int? to String?
  final String? secacheDate;
  final String? translateStatus;
  final String? translateTime;      // Changed from double? to String?
  final String? reason;
  final String? cache;              // Changed from int? to String?
  final String? apiInfo;
  final String? executionTime;
  final String? serverTime;
  final String? clientIp;
  final CallArgs? callArgs;
  final String? apiType;

  ProductResponse({
    this.item,
    this.error,
    this.errorCode,
    this.secache,
    this.secacheTime,
    this.secacheDate,
    this.translateStatus,
    this.translateTime,
    this.reason,
    this.cache,
    this.apiInfo,
    this.executionTime,
    this.serverTime,
    this.clientIp,
    this.callArgs,
    this.apiType,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert any value to String
    String? toString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      return value.toString();
    }

    return ProductResponse(
      item: json['item'] != null ? Item.fromJson(json['item']) : null,
      error: toString(json['error']),
      errorCode: toString(json['error_code']),
      secache: toString(json['secache']),
      secacheTime: toString(json['secache_time']),
      secacheDate: toString(json['secache_date']),
      translateStatus: toString(json['translate_status']),
      translateTime: toString(json['translate_time']),
      reason: toString(json['reason']),
      cache: toString(json['cache']),
      apiInfo: toString(json['api_info']),
      executionTime: toString(json['execution_time']),
      serverTime: toString(json['server_time']),
      clientIp: toString(json['client_ip']),
      callArgs: json['call_args'] != null ? CallArgs.fromJson(json['call_args']) : null,
      apiType: toString(json['api_type']),
    );
  }
}

class CallArgs {
  final String? numIid;
  final String? apiType;

  CallArgs({this.numIid, this.apiType});

  factory CallArgs.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert any value to String
    String? toString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      return value.toString();
    }

    return CallArgs(
      numIid: toString(json['num_iid']),
      apiType: toString(json['API_type']),
    );
  }
}