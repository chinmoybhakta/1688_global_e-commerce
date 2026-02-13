import 'dart:developer';

import 'package:ecommece_site_1688/core/data/model/get_item/product_response.dart';
import 'package:ecommece_site_1688/core/data/repository/repository_impl.dart';
import 'package:flutter_riverpod/legacy.dart';

class ProductState {
  final bool isLoading;
  final ProductResponse? data;
  final String? error;

  ProductState({
    this.isLoading = false,
    this.data,
    this.error,
  });

  ProductState copyWith({
    bool? isLoading,
    ProductResponse? data,
    String? error,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final RepositoryImpl repository;

  ProductNotifier(this.repository) : super(ProductState(isLoading: false));

  Future<void> fetchProduct(String numiid) async {
    log("🟡 ProductNotifier: Starting fetch for $numiid");
    state = ProductState(isLoading: true);
    
    try {
      log("🟡 ProductNotifier: Calling repository...");
      final productResponse = await repository.getItem(numiid: numiid);
      
      log("🟡 ProductNotifier: Repository returned: ${productResponse.runtimeType}");
      log("🟡 ProductNotifier: Response null? ${productResponse == null}");
      
      if (productResponse != null) {
        log("🟡 ProductNotifier: Response has item? ${productResponse.item != null}");
        log("🟡 ProductNotifier: Item title: ${productResponse.item?.title}");
        
        state = ProductState(isLoading: false, data: productResponse);
        log("🟢 ProductNotifier: State updated successfully");
      } else {
        log("🔴 ProductNotifier: Response is null");
        state = ProductState(isLoading: false, error: "Product not found");
      }
    } catch (e, stackTrace) {
      log("🔴 ProductNotifier: Error - $e");
      log("🔴 ProductNotifier: StackTrace - $stackTrace");
      state = ProductState(isLoading: false, error: e.toString());
    }
  }
}

final productProvider =
    StateNotifierProvider<ProductNotifier, ProductState?>((ref) {
      final repository = RepositoryImpl();
      return ProductNotifier(repository);
    });
