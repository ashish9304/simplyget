import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_to_go/features/booking/data/booking_repository.dart';

final bookingControllerProvider =
    AsyncNotifierProvider<BookingController, void>(BookingController.new);

class BookingController extends AsyncNotifier<void> {
  late final BookingRepository _repo;

  @override
  FutureOr<void> build() {
    _repo = ref.read(bookingRepositoryProvider);
  }

  Future<void> createBooking(
    String vehicleId,
    DateTime start,
    DateTime end,
    double price,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.createBooking(vehicleId, start, end, price),
    );
  }
}
