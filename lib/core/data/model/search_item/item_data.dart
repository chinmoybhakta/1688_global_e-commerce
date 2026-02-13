import 'package:ecommece_site_1688/core/data/model/search_item/search_item.dart';

class ItemsData {
  final String? page;
  final int? realTotalResults;
  final int? totalResults;
  final int? pageSize;
  final int? pageCount;
  final List<SearchItem>? item;
  final String? ddf;

  ItemsData({
    this.page,
    this.realTotalResults,
    this.totalResults,
    this.pageSize,
    this.pageCount,
    this.item,
    this.ddf,
  });

  factory ItemsData.fromJson(Map<String, dynamic> json) {
    return ItemsData(
      page: json['page'],
      realTotalResults: json['real_total_results'],
      totalResults: json['total_results'],
      pageSize: json['page_size'],
      pageCount: json['page_count'],
      item: json['item'] != null
          ? (json['item'] as List)
              .map((e) => SearchItem.fromJson(e))
              .toList()
          : [],
      ddf: json['_ddf'],
    );
  }
}
