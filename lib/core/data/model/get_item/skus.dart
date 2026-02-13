class Skus {
  final List<SkuModel>? sku;

  Skus({this.sku});

  factory Skus.fromJson(Map<String, dynamic> json) {
    return Skus(
      sku: json['sku'] != null
          ? (json['sku'] as List).map((e) => SkuModel.fromJson(e)).toList()
          : [],
    );
  }
}

class SkuModel {
  final String? price;           // Changed from double? to String?
  final String? orginalPrice;    // Changed from double? to String?
  final String? properties;
  final String? propertiesName;
  final String? quantity;        // Changed from int? to String?
  final String? skuId;

  SkuModel({
    this.price,
    this.orginalPrice,
    this.properties,
    this.propertiesName,
    this.quantity,
    this.skuId,
  });

  factory SkuModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert any value to String
    String? toString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      return value.toString();
    }

    return SkuModel(
      price: toString(json['price']),
      orginalPrice: toString(json['orginal_price']),
      properties: toString(json['properties']),
      propertiesName: toString(json['properties_name']),
      quantity: toString(json['quantity']),
      skuId: toString(json['sku_id']),
    );
  }
}