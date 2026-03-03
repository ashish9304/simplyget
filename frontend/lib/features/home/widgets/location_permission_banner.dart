import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:good_to_go/core/theme/app_colors.dart';
import 'package:good_to_go/features/home/controllers/search_controller.dart';

class LocationPermissionBanner extends ConsumerWidget {
  final VoidCallback onPermissionGranted;

  const LocationPermissionBanner({
    super.key,
    required this.onPermissionGranted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      // margin handled by Positioned in parent
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enable Location Services",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "We need your location to show available vehicles near you instantly.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Trigger system permission dialog
                try {
                  await ref.read(searchControllerProvider.notifier).detectLocation();
                  // If successful (or permission granted), callback
                  final permission = await Geolocator.checkPermission();
                  if (permission == LocationPermission.whileInUse || 
                      permission == LocationPermission.always) {
                    onPermissionGranted();
                  }
                } catch (e) {
                  // Handle error
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text("Allow Location Access"),
            ),
          ),
        ],
      ),
    );
  }
}
