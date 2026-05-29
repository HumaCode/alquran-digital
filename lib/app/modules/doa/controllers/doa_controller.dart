import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/doa_model.dart';
import '../../../data/repositories/doa_repository.dart';

class DoaController extends GetxController {
  final DoaRepository _repository;

  DoaController(this._repository);

  // Loading and error states
  final isLoading = false.obs;
  final isLoadMoreLoading = false.obs;
  final errorMessage = ''.obs;

  // Master data
  final _allDoas = <DataDoa>[].obs;

  // Filtered data (matching query/category)
  final filteredDoas = <DataDoa>[].obs;

  // Displayed data (paginated: 10, then 10 more, etc.)
  final displayedDoas = <DataDoa>[].obs;

  // Dynamic category list extracted from API groups
  final kategoriList = <String>['Semua'].obs;

  // Pagination parameters
  final int _pageSize = 10;
  final hasMore = true.obs;

  // Category and search states
  final currentCategory = 'Semua'.obs;
  final searchQuery = ''.obs;
  final showFavoritOnly = false.obs;

  // Favorit set
  final favoritIds = <int>{}.obs;

  // Font size and visibility settings for Doa View / Detail
  final arabicFontSize = 26.0.obs;
  final showLatin = true.obs;
  final showTranslation = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDoaList();
  }

  Future<void> fetchDoaList() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final list = await _repository.getDoas();
      _allDoas.assignAll(list);
      
      // Extract unique categories (groups) dynamically from data
      final groups = list.map((e) => e.grup).toSet().toList();
      groups.sort();
      kategoriList.assignAll(['Semua', ...groups]);

      applyFilterAndResetPagination();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilterAndResetPagination() {
    var temp = _allDoas.toList();

    // 1. Filter by category (group)
    if (currentCategory.value != 'Semua') {
      temp = temp.where((d) => d.grup == currentCategory.value).toList();
    }

    // 2. Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      temp = temp.where((d) =>
        d.nama.toLowerCase().contains(q) ||
        d.idn.toLowerCase().contains(q) ||
        d.grup.toLowerCase().contains(q) ||
        d.tag.any((t) => t.toLowerCase().contains(q))
      ).toList();
    }

    // 3. Filter by favorit status
    if (showFavoritOnly.value) {
      temp = temp.where((d) => favoritIds.contains(d.id)).toList();
    }

    filteredDoas.assignAll(temp);

    // 4. Reset pagination
    displayedDoas.clear();
    hasMore.value = filteredDoas.length > _pageSize;
    final int end = _pageSize.clamp(0, filteredDoas.length);
    displayedDoas.assignAll(filteredDoas.sublist(0, end));
  }

  void loadMoreDoa() {
    if (isLoadMoreLoading.value || !hasMore.value) return;

    isLoadMoreLoading.value = true;
    
    // Simulate slight delay for smooth visual feedback of infinite scroll
    Future.delayed(const Duration(milliseconds: 300), () {
      final int currentLength = displayedDoas.length;
      final int nextLength = currentLength + _pageSize;
      final int end = nextLength.clamp(0, filteredDoas.length);

      displayedDoas.addAll(filteredDoas.sublist(currentLength, end));
      hasMore.value = displayedDoas.length < filteredDoas.length;
      isLoadMoreLoading.value = false;
    });
  }

  void updateCategory(String category) {
    currentCategory.value = category;
    applyFilterAndResetPagination();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    applyFilterAndResetPagination();
  }

  void toggleFavorit(int id) {
    if (favoritIds.contains(id)) {
      favoritIds.remove(id);
    } else {
      favoritIds.add(id);
    }
    applyFilterAndResetPagination();
  }

  void toggleShowFavorit() {
    showFavoritOnly.value = !showFavoritOnly.value;
    applyFilterAndResetPagination();
  }

  void setArabicFontSize(double size) {
    arabicFontSize.value = size;
  }

  void toggleLatin() {
    showLatin.value = !showLatin.value;
  }

  void toggleTranslation() {
    showTranslation.value = !showTranslation.value;
  }
}
