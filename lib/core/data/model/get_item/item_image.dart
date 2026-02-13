class ItemImage {
  final String? url;

  ItemImage({this.url});

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    return ItemImage(url: json['url']);
  }
}

class VideoModel {
  final String? url;

  VideoModel({this.url});

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(url: json['url']);
  }
}

class SellerInfo {
  final String? nick;
  final String? itemScore;
  final String? scoreP;
  final String? deliveryScore;
  final String? zhuy;
  final String? shopName;

  SellerInfo({
    this.nick,
    this.itemScore,
    this.scoreP,
    this.deliveryScore,
    this.zhuy,
    this.shopName,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      nick: json['nick'],
      itemScore: json['item_score'],
      scoreP: json['score_p'],
      deliveryScore: json['delivery_score'],
      zhuy: json['zhuy'],
      shopName: json['shop_name'],
    );
  }
}

class PropModel {
  final String? name;
  final String? value;

  PropModel({this.name, this.value});

  factory PropModel.fromJson(Map<String, dynamic> json) {
    return PropModel(
      name: json['name'],
      value: json['value'],
    );
  }
}
