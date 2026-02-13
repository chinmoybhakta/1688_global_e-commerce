class SearchItem {
  final String? title;
  final String? picUrl;
  final String? price;
  final String? promotionPrice;
  final int? sales;
  final int? numIid;
  final String? tagPercent;
  final String? detailUrl;

  SearchItem({
    this.title,
    this.picUrl,
    this.price,
    this.promotionPrice,
    this.sales,
    this.numIid,
    this.tagPercent,
    this.detailUrl,
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      title: json['title'],
      picUrl: json['pic_url'],
      price: json['price'],
      promotionPrice: json['promotion_price'],
      sales: json['sales'],
      numIid: json['num_iid'],
      tagPercent: json['tag_percent'],
      detailUrl: json['detail_url'],
    );
  }
}
