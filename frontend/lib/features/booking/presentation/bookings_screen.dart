import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_to_go/core/theme/app_colors.dart';
import 'package:good_to_go/features/auth/presentation/auth_controller.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${user?.name ?? "User"}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          _buildBookingsList(context),
        ],
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Bookings',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Placeholder for booking list
        // Map from actual bookings
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.directions_car, color: AppColors.primary),
            ),
            title: const Text(
              'Tesla Model 3',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Feb 12 - Feb 15 • \$360'),
            trailing: Chip(
              label: const Text('Confirmed'),
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              labelStyle: const TextStyle(color: Colors.green),
            ),
          ),
        ),
      ],
    );
  }
}
