import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:good_to_go/features/auth/presentation/auth_controller.dart';
import 'package:good_to_go/core/theme/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. User Information
          _buildUserInfo(context, user),
          const SizedBox(height: 24),

          // 2. Account Settings
          _buildSectionHeader(context, "Account Settings"),
          _buildListTile(
            context,
            icon: Icons.person_outline,
            title: "Edit Profile",
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.phone_outlined,
            title: "Update Phone Number",
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.lock_outline,
            title: "Change Password",
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.location_on_outlined,
            title: "Manage Saved Addresses",
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.my_location,
            title: "Location Permission Status",
            trailing: const Text(
              "Enabled",
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
            onTap: () {},
          ),
          const Divider(),

          // 3. Vehicle Management (Conditional)
          if (user?.role == 'owner') ...[
            const SizedBox(height: 16),
            _buildSectionHeader(context, "Vehicle Management"),
            _buildListTile(
              context,
              icon: Icons.directions_car_outlined,
              title: "My Listed Vehicles",
              onTap: () {}, // Implement My Vehicles Screen
            ),
            _buildListTile(
              context,
              icon: Icons.add_circle_outline,
              title: "Add New Vehicle",
              onTap: () => context.push('/add-vehicle'),
            ),
            const Divider(),
          ],

          // 4. Bookings & Activity
          const SizedBox(height: 16),
          _buildSectionHeader(context, "Bookings & Activity"),
          _buildListTile(
            context,
            icon: Icons.calendar_today_outlined,
            title: "My Bookings",
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.history,
            title: "Booking History",
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.star_outline,
            title: "Reviews",
            onTap: () {},
          ),
          const Divider(),

          // 5. Payments & Earnings
          const SizedBox(height: 16),
          _buildSectionHeader(context, "Payments & Earnings"),
          _buildListTile(
            context,
            icon: Icons.payment_outlined,
            title: "Payment Methods",
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.receipt_long_outlined,
            title: "Transaction History",
            onTap: () {},
          ),
          if (user?.role == 'owner')
            _buildListTile(
              context,
              icon: Icons.attach_money,
              title: "Earnings Summary",
              onTap: () {},
            ),
          const Divider(),

          // 6. Preferences
          const SizedBox(height: 16),
          _buildSectionHeader(context, "Preferences"),
          _buildListTile(
            context,
            icon: Icons.notifications_none,
            title: "Notification Settings",
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.language,
            title: "Language",
            trailing: const Text("English"),
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: "Theme",
            trailing: const Text("Light"),
            onTap: () {},
          ),
          const Divider(),

          // 7. Legal & Support
          const SizedBox(height: 16),
          _buildSectionHeader(context, "Legal & Support"),
          _buildListTile(
            context,
            icon: Icons.description_outlined,
            title: "Terms & Conditions",
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () {},
          ),
          const SizedBox(height: 24),

          // LOGOUT
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context, ref),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, dynamic user) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: user?.profilePicture != null
                  ? NetworkImage(user!.profilePicture!)
                  : null,
              child: user?.profilePicture == null
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? "User Name",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? "email@example.com",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: const Text(
            "KYC Verified",
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.go('/'); // Redirect to Home
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
