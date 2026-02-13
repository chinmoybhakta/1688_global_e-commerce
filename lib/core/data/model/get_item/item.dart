import 'package:ecommece_site_1688/core/data/model/get_item/item_image.dart';
import 'package:ecommece_site_1688/core/data/model/get_item/skus.dart';

class Item {
  final String? numIid;
  final String? title;
  final String? price;
  final String? orginalPrice;
  final String? nick;
  final String? num;           // Changed from int? to String?
  final String? detailUrl;
  final String? picUrl;
  final String? brand;
  final String? cid;
  final String? location;

  final List<String>? descImg;
  final List<ItemImage>? itemImgs;

  final VideoModel? video;
  final SellerInfo? sellerInfo;

  final List<PropModel>? props;
  final Skus? skus;            // Changed from SkuModel? to Skus?

  final String? sales;         // Changed from int? to String?
  final String? totalSold;

  Item({
    this.numIid,
    this.title,
    this.price,
    this.orginalPrice,
    this.nick,
    this.num,
    this.detailUrl,
    this.picUrl,
    this.brand,
    this.cid,
    this.location,
    this.descImg,
    this.itemImgs,
    this.video,
    this.sellerInfo,
    this.props,
    this.skus,
    this.sales,
    this.totalSold,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert any value to String
    String? toString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      return value.toString();
    }

    return Item(
      numIid: toString(json['num_iid']),
      title: toString(json['title']),
      price: toString(json['price']),
      orginalPrice: toString(json['orginal_price']),
      nick: toString(json['nick']),
      num: toString(json['num']),                    // Now converts int to String
      detailUrl: toString(json['detail_url']),
      picUrl: toString(json['pic_url']),
      brand: toString(json['brand']),
      cid: toString(json['cid']),
      location: toString(json['location']),
      sales: toString(json['sales']),                 // Now converts int to String
      totalSold: toString(json['total_sold']),

      descImg: json['desc_img'] != null
          ? List<String>.from(json['desc_img'].map((e) => toString(e)))
          : [],

      itemImgs: json['item_imgs'] != null
          ? (json['item_imgs'] as List)
              .map((e) => ItemImage.fromJson(e))
              .toList()
          : [],

      video: json['video'] != null ? VideoModel.fromJson(json['video']) : null,

      sellerInfo: json['seller_info'] != null
          ? SellerInfo.fromJson(json['seller_info'])
          : null,

      props: json['props'] != null
          ? (json['props'] as List)
              .map((e) => PropModel.fromJson(e))
              .toList()
          : [],

      skus: json['skus'] != null ? Skus.fromJson(json['skus']) : null,  // Fixed: Skus not SkuModel
    );
  }
}