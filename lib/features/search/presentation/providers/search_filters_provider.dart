import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../shared/models/listing_model.dart';

part 'search_filters_provider.g.dart';
part 'search_filters_provider.freezed.dart';

@freezed
class SearchFilters with _$SearchFilters {
  const factory SearchFilters({
    @Default([]) List<ListingType> types,
    double? minPrice,
    double? maxPrice,
    String? region,
    @Default([]) List<String> amenities,
    int? minGuests,
    double? minRating,
    DateTime? checkIn,
    DateTime? checkOut,
  }) = _SearchFilters;
}

@riverpod
class SearchFiltersNotifier extends _$SearchFiltersNotifier {
  @override
  SearchFilters build() {
    return const SearchFilters();
  }

  void setTypes(List<ListingType> types) {
    state = state.copyWith(types: types);
  }

  void setPriceRange(double? minPrice, double? maxPrice) {
    state = state.copyWith(minPrice: minPrice, maxPrice: maxPrice);
  }

  void setRegion(String? region) {
    state = state.copyWith(region: region);
  }

  void setAmenities(List<String> amenities) {
    state = state.copyWith(amenities: amenities);
  }

  void setMinGuests(int? minGuests) {
    state = state.copyWith(minGuests: minGuests);
  }

  void setMinRating(double? minRating) {
    state = state.copyWith(minRating: minRating);
  }

  void setDates(DateTime? checkIn, DateTime? checkOut) {
    state = state.copyWith(checkIn: checkIn, checkOut: checkOut);
  }

  void clearFilters() {
    state = const SearchFilters();
  }
}
