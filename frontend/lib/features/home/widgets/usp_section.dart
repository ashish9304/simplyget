import 'package:flutter/material.dart';
import 'package:good_to_go/core/theme/app_colors.dart';

class USPSection extends StatelessWidget {
  const USPSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildUSPItem(
          icon: Icons.directions_car,
          title: "31,000+",
          subtitle: "High-quality car options",
        ),
        const SizedBox(height: 16),
        _buildUSPItem(
          icon: Icons.all_inclusive,
          title: "Unlimited kms",
          subtitle: "To drive and stop anywhere",
        ),
        const SizedBox(height: 16),
        _buildUSPItem(
          icon: Icons.security,
          title: "100% Trip Protection",
          subtitle: "For a safe, hassle-free drive",
        ),
      ],
    );
  }

  Widget _buildUSPItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.secondary),
          ),
          child: Icon(icon, color: AppColors.secondary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
