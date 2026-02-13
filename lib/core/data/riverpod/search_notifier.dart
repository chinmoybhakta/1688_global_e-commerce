import 'package:ecommece_site_1688/core/data/model/search_item/search_item_response.dart';
import 'package:ecommece_site_1688/core/data/repository/repository_impl.dart';
import 'package:flutter_riverpod/legacy.dart';

class SearchState {
  final bool isLoading;
  final SearchItemResponse? data;
  final String? error;

  SearchState({
    this.isLoading = false,
    this.data,
    this.error,
  });

  SearchState copyWith({
    bool? isLoading,
    SearchItemResponse? data,
    String? error,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final RepositoryImpl repository;

  SearchNotifier(this.repository) : super(SearchState(isLoading: false));

  String query = " ";
  int page = 1;

  Future<void> fetchSearchItems(String? query, int? page) async {
    state = SearchState(isLoading: true);
    final response = await repository.searchItems(query: query ?? " ", page: page ?? 1);

    if (response == null) {
      state = SearchState(
        isLoading: false,
        data: null,
        error: "Something went wrong",
      );
    } else {
      this.query = query ?? " ";
      this.page = page ?? 1;
      state = SearchState(
        isLoading: false,
        data: response,
        error: null,
      );
    }
  }

  Future<void> loadMore() async {
    state = SearchState(isLoading: true);
    final nextPage = page + 1;
    final response = await repository.searchItems(query: query, page: nextPage);

    if (response == null) {
      state = SearchState(
        isLoading: false,
        data: null,
        error: "Something went wrong",
      );
    } else {
      page = nextPage;
      state = SearchState(
        isLoading: false,
        data: response,
        error: null,
      );
    }
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(RepositoryImpl());
});