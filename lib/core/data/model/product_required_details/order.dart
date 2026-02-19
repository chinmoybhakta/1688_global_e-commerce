class Order {
  final String? productId;
  final String? productTitle;
  final String? productVariant;
  final String? productVariantPrice;
  final String? productQuantity;
  final String? productStock;
  final String? productImage;

  Order({
    this.productId,
    this.productTitle,
    this.productVariant,
    this.productVariantPrice,
    this.productQuantity,
    this.productStock,
    this.productImage,
  });

  /// Creates a copy of this Order with the given fields replaced
  Order copyWith({
    String? productId,
    String? productTitle,
    String? productVariant,
    String? productVariantPrice,
    String? productQuantity,
    String? productStock,
    String? productImage,
  }) {
    return Order(
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productVariant: productVariant ?? this.productVariant,
      productVariantPrice: productVariantPrice ?? this.productVariantPrice,
      productQuantity: productQuantity ?? this.productQuantity,
      productStock: productStock ?? this.productStock,
      productImage: productImage ?? this.productImage,
    );
  }

  /// Optional: Add a toString for debugging
  @override
  String toString() {
    return 'Order(productId: $productId, productTitle: $productTitle, quantity: $productQuantity)';
  }

  /// Optional: Add equality operator if needed
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order &&
        other.productId == productId &&
        other.productVariant == productVariant;
  }

  @override
  int get hashCode => productId.hashCode ^ productVariant.hashCode;
}