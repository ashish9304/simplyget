import 'package:flutter_riverpod/flutter_riverpod.dart';

// Reuse Vehicle class or define Booking model
class Booking {
  final String id;
  final String vehicleId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;

  Booking({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });
}

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});

class BookingRepository {
  Future<void> createBooking(
    String vehicleId,
    DateTime start,
    DateTime end,
    double price,
  ) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API
    // Success
  }

  Future<List<Booking>> getUserBookings() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Booking(
        id: '1',
        vehicleId: '1',
        userId: 'user1',
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        totalPrice: 360,
        status: 'confirmed',
      ),
    ];
  }
}
