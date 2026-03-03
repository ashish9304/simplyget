import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_to_go/features/auth/presentation/auth_controller.dart';
import 'package:good_to_go/features/profile/profile_screen.dart';
import 'package:good_to_go/features/home/home_screen.dart'; // For HomeContent
import 'package:good_to_go/features/booking/presentation/bookings_screen.dart';
import 'package:good_to_go/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    Widget bodyContent;
    switch (_selectedIndex) {
      case 0:
        bodyContent = const SingleChildScrollView(child: HomeContent());
        break;
      case 1:
        // Rentals (Bookings) - MOVED TO POSITION 1
        bodyContent = user != null
            ? const BookingsScreen()
            : const _GuestPlaceholder(
                title: "My Rentals",
                message: "Login to view your rentals",
                icon: Icons.calendar_today_outlined,
              );
        break;
      case 2:
        // Sell Tab - MOVED TO POSITION 2
        bodyContent = user != null
            ? const _SellTab()
            : const _GuestPlaceholder(
                title: "Start Selling",
                message: "Login to list your vehicle",
                icon: Icons.monetization_on_outlined,
              );
        break;
      case 3:
        // Profile
        bodyContent = user != null
            ? const ProfileScreen()
            : const _GuestProfilePlaceholder();
        break;
      default:
        bodyContent = const SingleChildScrollView(child: HomeContent());
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: _buildAppBarTitle(),
        actions: [
          if (_selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  _onItemTapped(3);
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: user?.profilePicture != null
                      ? NetworkImage(user!.profilePicture!)
                      : null,
                  child: user?.profilePicture == null
                      ? const Icon(
                          Icons.person,
                          size: 20,
                          color: AppColors.primary,
                        )
                      : null,
                ),
              ),
            ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: bodyContent,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Rentals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Sell',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primary,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.directions_car,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Good To Go",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      case 1:
        return const Text(
          "My Rentals",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 2:
        return const Text(
          "Sell & Earn",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 3:
        return const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      default:
        return const Text("Good To Go");
    }
  }
}

class _GuestPlaceholder extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _GuestPlaceholder({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Determine what to do. Maybe switch to Profile tab?
              // Or navigate to full login?
              // Let's go to full Login for now, or context.go('/login')
              // But user wants bottom bar...
              // Ideally, we switch to tab 2 (Profile) which has the login form.
              // But we don't have access to _onItemTapped from here easily without callback.
              // For now, simpler: context.go('/login');
              // BUT user hates losing bottom bar.
              // So I will make the Profile Tab the login tab.
              // I need to find the Dashboard state to switch tab?
              // Or just show login form here?
              // Let's show a "Login / Register" button that goes to the Profile tab logic?
              // Actually, let's just use context.push('/login') but make LoginScreen WRAPPED in Dashboard? No.
              // Best bet: The Profile Tab IS the login screen for guests.
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Login / Sign Up"),
          ),
        ],
      ),
    );
  }
}

class _GuestProfilePlaceholder extends StatelessWidget {
  const _GuestProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          Text(
            "Log in to your account",
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Access your bookings, profile, and more.",
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              context.push('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Login"),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              context.push('/register');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Create Account"),
          ),
        ],
      ),
    );
  }
}

class _SellTab extends StatelessWidget {
  const _SellTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_business_outlined,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Start Earning Today",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "List your vehicle and rent it out to others.\nJoin our community of owners.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/add-vehicle'),
            icon: const Icon(Icons.add),
            label: const Text("List Your Vehicle"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
