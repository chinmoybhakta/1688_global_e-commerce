import 'package:ecommece_site_1688/core/data/model/search_item/search_item.dart';
import 'package:ecommece_site_1688/core/data/repository/repository_impl.dart';
import 'package:flutter_riverpod/legacy.dart';

class SearchState {
  final bool isLoading;
  final bool isLoadingMore; // New flag for load more
  final List<SearchItem> dataList;
  final String? error;
  final int currentPage;
  final bool hasReachedMax; // To know if there's more data

  SearchState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.dataList = const [],
    this.error,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  SearchState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<SearchItem>? dataList,
    String? error,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      dataList: dataList ?? this.dataList,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final RepositoryImpl repository;
  String query = " ";

  SearchNotifier(this.repository) : super(SearchState());

  Future<void> fetchSearchItems(String? query, int? page) async {
    // Reset state for new search
    state = state.copyWith(
      isLoading: true,
      error: null,
      dataList: [], // Clear previous results
      currentPage: 1,
      hasReachedMax: false,
    );
    
    this.query = query ?? " ";
    final response = await repository.searchItems(query: this.query, page: page ?? 1);

    if (response == null) {
      state = state.copyWith(
        isLoading: false,
        error: "Something went wrong",
      );
    } else {
      final newItems = response.items?.item ?? [];
      state = state.copyWith(
        isLoading: false,
        dataList: newItems,
        error: null,
        currentPage: page ?? 1,
        hasReachedMax: newItems.isEmpty, // If no items, we've reached the end
      );
    }
  }

  Future<void> loadMore() async {
    // Prevent multiple load more calls
    if (state.isLoadingMore || state.hasReachedMax) return;
    
    final nextPage = state.currentPage + 1;
    
    state = state.copyWith(
      isLoadingMore: true,
      error: null,
    );

    final response = await repository.searchItems(query: query, page: nextPage);

    if (response == null) {
      state = state.copyWith(
        isLoadingMore: false,
        error: "Something went wrong",
      );
    } else {
      final newItems = response.items?.item ?? [];
      
      state = state.copyWith(
        isLoadingMore: false,
        dataList: [...state.dataList, ...newItems],
        currentPage: nextPage,
        hasReachedMax: newItems.isEmpty,
        error: null,
      );
    }
  }

  // Optional: Reset search
  void resetSearch() {
    query = "";
    state = SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(RepositoryImpl());
});