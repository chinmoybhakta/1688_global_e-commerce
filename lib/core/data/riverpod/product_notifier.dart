import 'package:ecommece_site_1688/core/data/model/get_item/product_response.dart';
import 'package:ecommece_site_1688/core/data/repository/repository_impl.dart';
import 'package:riverpod/riverpod.dart';

class ProductNotifier extends StateNotifier<ProductResponse?> {
  final RepositoryImpl repository;
  
  ProductNotifier(this.repository) : super(null);

  Future<void> fetchProduct(String numiid) async {
    final productResponse = await repository.getItem(numiid: numiid);
    state = productResponse;
  }
}


final product_provider = StateNotifierProvider<ProductNotifier, ProductResponse?>((ref) {
  final repository = RepositoryImpl();
  return ProductNotifier(repository);
});