import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:good_to_go/features/auth/presentation/auth_controller.dart';
import 'package:good_to_go/core/theme/app_colors.dart';
import 'package:good_to_go/features/home/controllers/search_controller.dart';
import 'package:good_to_go/features/home/widgets/location_search_bottom_sheet.dart';

class HeroSection extends ConsumerWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for search errors
    ref.listen<AsyncValue<SearchState>>(searchControllerProvider, (
      previous,
      next,
    ) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rent Nearby \nBikes & Cars Instantly",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildLocationButton(context, ref),
            const SizedBox(height: 24),
            _buildSearchBar(context, ref),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      return ElevatedButton(
                        onPressed: () {
                          context.push('/search');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Find Vehicles",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      return OutlinedButton(
                        onPressed: () {
                          final user = ref.read(authControllerProvider).value;
                          if (user != null) {
                            context.push('/add-vehicle');
                          } else {
                            context.push('/login');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "List Your Vehicle",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(searchControllerProvider);
    final isLoading = searchAsync.isLoading;

    return TextButton.icon(
      onPressed: isLoading
          ? null
          : () {
              ref
                  .read(searchControllerProvider.notifier)
                  .detectLocation(forceRefresh: true);
            },
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            )
          : const Icon(Icons.my_location, color: Colors.white70, size: 20),
      label: Text(
        isLoading ? "Detecting..." : "Detect Current Location",
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(searchControllerProvider);
    final searchState = searchAsync.value ?? SearchState();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // LOCATION ROW
          InkWell(
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const LocationSearchBottomSheet(),
              );
            },
            child: _buildSearchRow(
              icon: Icons.location_on_outlined,
              title: "Location",
              subtitle: searchAsync.isLoading
                  ? "Detecting Location..."
                  : (searchState.location ?? "Enter Location"),
            ),
          ),
          const Divider(height: 24, thickness: 1, color: Colors.grey),
          Row(
            children: [
              // DATES ROW
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: searchState.dateRange,
                    );
                    if (picked != null) {
                      ref
                          .read(searchControllerProvider.notifier)
                          .setDateRange(picked);
                    }
                  },
                  child: _buildSearchRow(
                    icon: Icons.calendar_today_outlined,
                    title: "Dates",
                    subtitle: searchState.dateRange != null
                        ? "${DateFormat('MMM d').format(searchState.dateRange!.start)} - ${DateFormat('MMM d').format(searchState.dateRange!.end)}"
                        : "Add Dates",
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              // TYPE ROW
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final String? picked = await showDialog<String>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text("Select Vehicle Type"),
                        children: [
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, "Bike"),
                            child: const Text("Bike"),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, "Car"),
                            child: const Text("Car"),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, "Both"),
                            child: const Text("Both (All Types)"),
                          ),
                        ],
                      ),
                    );
                    if (picked != null) {
                      ref
                          .read(searchControllerProvider.notifier)
                          .setVehicleType(picked);
                    }
                  },
                  child: _buildSearchRow(
                    icon: Icons.directions_car_outlined,
                    title: "Type",
                    subtitle: searchState.vehicleType ?? "Bike / Car",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    // Wrapped in a transparent Container to ensure hit test works on full width/height
    return Container(
      color: Colors.transparent, // Ensures hit test works on empty space
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ), // Add padding for touch target
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
