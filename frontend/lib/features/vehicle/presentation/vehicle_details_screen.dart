import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:good_to_go/shared/models/vehicle_model.dart';
import 'package:good_to_go/core/theme/app_colors.dart';

class VehicleDetailsScreen extends ConsumerWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('${vehicle.brand} ${vehicle.model}'),
              background:
                  vehicle.imageUrls != null && vehicle.imageUrls!.isNotEmpty
                  ? PageView.builder(
                      itemCount: vehicle.imageUrls!.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          vehicle.imageUrls![index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 50),
                              ),
                        );
                      },
                    )
                  : (vehicle.imageUrl != null
                        ? Image.network(
                            vehicle.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                  ),
                                ),
                          )
                        : Container(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            child: Center(
                              child: Icon(
                                vehicle.type == 'car'
                                    ? Icons.directions_car
                                    : Icons.directions_bike,
                                size: 100,
                                color: AppColors.primary,
                              ),
                            ),
                          )),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${vehicle.pricePerDay.toStringAsFixed(0)}/day',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: vehicle.isAvailable
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        vehicle.isAvailable ? 'Available' : 'Unavailable',
                        style: TextStyle(
                          color: vehicle.isAvailable
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      vehicle.location,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Features',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text(vehicle.type.toUpperCase())),
                    const Chip(label: Text('Bluetooth')),
                    const Chip(label: Text('GPS')),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: vehicle.isAvailable
                        ? () {
                            context.push('/booking', extra: vehicle);
                          }
                        : null,
                    child: const Text('Book Now'),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
