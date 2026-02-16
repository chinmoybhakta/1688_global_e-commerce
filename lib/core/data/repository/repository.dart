import 'package:ecommece_site_1688/core/data/model/get_item/product_response.dart';
import 'package:ecommece_site_1688/core/data/model/search_item/search_item_response.dart';

abstract class Repository {
  Future<ProductResponse?> getItem({required String numiid});
  Future<SearchItemResponse?> searchItems({required String query, required int page});
  String getProxiedImageUrl(String originalUrl);
}