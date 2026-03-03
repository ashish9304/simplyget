import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:good_to_go/shared/models/vehicle_model.dart';
import 'package:good_to_go/core/theme/app_colors.dart';
import 'package:good_to_go/features/booking/presentation/booking_controller.dart';
import 'package:intl/intl.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Vehicle vehicle;

  const BookingScreen({super.key, required this.vehicle});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingControllerProvider);

    // Calculate price
    double totalPrice = 0;
    int days = 0;
    if (_selectedDateRange != null) {
      days = _selectedDateRange!.duration.inDays;
      if (days == 0) days = 1; // Minimum 1 day
      totalPrice = days * widget.vehicle.pricePerDay;
    }

    ref.listen<AsyncValue>(bookingControllerProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
      if (!next.isLoading &&
          !next.hasError &&
          next.value == null &&
          prev?.isLoading == true) {
        // Success
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Booking Confirmed'),
            content: const Text('Your ride is good to go!'),
            actions: [
              TextButton(
                onPressed: () {
                  context.go('/'); // Go home
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Book Your Ride')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vehicle Summary
            Card(
              child: ListTile(
                leading: Icon(
                  widget.vehicle.type == 'car'
                      ? Icons.directions_car
                      : Icons.directions_bike,
                ),
                title: Text('${widget.vehicle.brand} ${widget.vehicle.model}'),
                subtitle: Text('\$${widget.vehicle.pricePerDay}/day'),
              ),
            ),
            const SizedBox(height: 24),

            // Date Picker
            Text(
              'Select Dates',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDateRange = picked;
                  });
                }
              },
              child: Text(
                _selectedDateRange == null
                    ? 'Choose Dates'
                    : '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)} ($days days)',
              ),
            ),

            const Spacer(),

            // Price Breakdown
            if (_selectedDateRange != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Price',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '\$${totalPrice.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Book Button
            ElevatedButton(
              onPressed: _selectedDateRange == null || bookingState.isLoading
                  ? null
                  : () {
                      ref
                          .read(bookingControllerProvider.notifier)
                          .createBooking(
                            widget.vehicle.id,
                            _selectedDateRange!.start,
                            _selectedDateRange!.end,
                            totalPrice,
                          );
                    },
              child: bookingState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
