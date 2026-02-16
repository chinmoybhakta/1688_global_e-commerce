import 'dart:developer';
import 'package:ecommece_site_1688/core/data/model/get_item/product_response.dart';
import 'package:ecommece_site_1688/core/data/model/search_item/search_item_response.dart';
import 'package:ecommece_site_1688/core/data/repository/repository.dart';
import 'package:ecommece_site_1688/core/network/api_client.dart';
import 'package:ecommece_site_1688/core/network/api_endpoint.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RepositoryImpl extends Repository {
  final header = {"accept": "application/json"};
  @override
  Future<ProductResponse?> getItem({required String numiid}) async {
    log("🟡 Repository: Calling API for numiid: $numiid");
    try {
      final response = await ApiClient().getRequest(
        endpoints: ApiEndpoints.getItem(numiid),
        headers: header,
      );
      log("🟡 Repository: Response type: ${response.runtimeType}");

      if (response['error_code'] == "0000") {
        log("🟡 Repository: Response keys: ${response.keys}");
        log(
          "🟡 Repository: 'item' key exists? ${response.containsKey('item')}",
        );
        log(
          "🟢 Repository: Parsed successfully. Item exists: ${ProductResponse.fromJson(response).item != null}",
        );
        return ProductResponse.fromJson(response);
      } else {
        Fluttertoast.showToast(msg: response['error'] ?? 'Unknown error');
        return null;
      }
    } catch (e) {
      log("🔴 Repository: Error - $e");
      rethrow;
    }
  }

  @override
  Future<SearchItemResponse?> searchItems({
    required String query,
    required int page,
  }) async {
    try {
      final response = await ApiClient().getRequest(
        endpoints: ApiEndpoints.serachItems(query, page),
        headers: header,
      );

      if (response['error_code'] == "0000") {
        return SearchItemResponse.fromJson(response);
      } else {
        Fluttertoast.showToast(msg: response['error'] ?? 'Unknown error');
        return null;
      }
    } catch (e) {
      log("🔴 Repository: Error - $e");
      rethrow;
    }
  }

  @override
  String getProxiedImageUrl(String originalUrl) {
    final encodedUrl = Uri.encodeComponent(originalUrl);
    return '${ApiEndpoints.baseUrl}proxy-image?url=$encodedUrl';
  }
}
