import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_to_go/features/auth/presentation/login_screen.dart';
import 'package:good_to_go/features/auth/presentation/register_screen.dart';

import 'package:good_to_go/features/auth/presentation/auth_controller.dart';
import 'package:good_to_go/features/vehicle/presentation/vehicle_details_screen.dart';
import 'package:good_to_go/shared/models/vehicle_model.dart';
import 'package:good_to_go/features/booking/presentation/booking_screen.dart';
import 'package:good_to_go/features/profile/dashboard_screen.dart';
import 'package:good_to_go/features/vehicle/presentation/add_vehicle_screen.dart';
import 'package:good_to_go/features/home/presentation/search_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final location = state.uri.toString();
      final isLoggingIn = location == '/login' || location == '/register';
      final isPublic =
          location == '/' ||
          location.startsWith('/vehicle') ||
          location == '/dashboard';

      // If user is guest and trying to access a protected route (not public and not logging in)
      if (!isLoggedIn && !isLoggingIn && !isPublic) return '/login';

      // If user is logged in and trying to access login/register, verify context or redirect to dashboard
      // We'll redirect to dashboard if they try to access login/register
      if (isLoggedIn && isLoggingIn) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/vehicle',
        builder: (context, state) {
          final vehicle = state.extra as Vehicle; // Pass vehicle object
          return VehicleDetailsScreen(vehicle: vehicle);
        },
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) {
          final vehicle = state.extra as Vehicle;
          return BookingScreen(vehicle: vehicle);
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/add-vehicle',
        builder: (context, state) => const AddVehicleScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
    ],
  );
});
