import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:good_to_go/core/theme/app_colors.dart';
import 'package:good_to_go/features/home/widgets/hero_section.dart';
import 'package:good_to_go/features/home/widgets/how_it_works_section.dart';
import 'package:good_to_go/features/home/widgets/featured_vehicles_section.dart';
import 'package:good_to_go/features/home/widgets/become_owner_section.dart';
import 'package:good_to_go/features/vehicle/presentation/vehicle_controller.dart';
import 'package:good_to_go/features/home/widgets/location_permission_banner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:good_to_go/features/home/controllers/search_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.read(vehicleControllerProvider.notifier).refresh();
          },
          child: const SingleChildScrollView(
            child: Column(children: [_HomeHeader(), HomeContent()]),
          ),
        ),
      ),
    );
  }
}

class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({super.key});

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent> {
  bool _showPermissionBanner = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _showPermissionBanner = true;
        });
      }
    } else {
      // Permission granted, do nothing. SearchController handles it.
    }
  }

  void _onPermissionGranted() {
    if (mounted) {
      setState(() {
        _showPermissionBanner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<SearchState>>(searchControllerProvider, (
      previous,
      next,
    ) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Stack(
      children: [
        const Column(
          children: [
            HeroSection(),
            HowItWorksSection(),
            SizedBox(height: 20),
            FeaturedVehiclesSection(),
            BecomeOwnerSection(),
            SizedBox(height: 40),
          ],
        ),
        if (_showPermissionBanner)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: LocationPermissionBanner(
              onPermissionGranted: _onPermissionGranted,
            ),
          ),
      ],
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final user = ref.watch(authControllerProvider).value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Good To Go",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => context.push('/login'),
                child: const Text("Login"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => context.push('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Sign Up"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
