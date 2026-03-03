import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
// Removed geocoding package import as we use direct API now
// import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:good_to_go/core/config/app_config.dart';
import 'package:good_to_go/core/services/local_storage_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

class SearchState {
  final String? location;
  final DateTimeRange? dateRange;
  final String? vehicleType;
  final double? latitude;
  final double? longitude;

  SearchState({
    this.location,
    this.dateRange,
    this.vehicleType,
    this.latitude,
    this.longitude,
  });

  SearchState copyWith({
    String? location,
    DateTimeRange? dateRange,
    String? vehicleType,
    double? latitude,
    double? longitude,
  }) {
    return SearchState(
      location: location ?? this.location,
      dateRange: dateRange ?? this.dateRange,
      vehicleType: vehicleType ?? this.vehicleType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class SearchController extends AsyncNotifier<SearchState> {
  @override
  FutureOr<SearchState> build() async {
    // Try to load last location from cache
    final storage = ref.read(localStorageServiceProvider);
    final lastLocation = await storage.getLastLocation();
    final lastCoords = await storage.getLastCoordinates();

    if (lastLocation != null) {
      return SearchState(
        location: lastLocation,
        latitude: lastCoords?['lat'],
        longitude: lastCoords?['lng'],
      );
    }

    return SearchState();
  }

  Future<void> initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await detectLocation();
      }
      // If denied, we do nothing. The UI (HomeContent) will check permission and show banner.
    } catch (e) {
      // Ignore errors during auto-init
    }
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<void> detectLocation({bool forceRefresh = false}) async {
    // Prevent duplicate calls if already loading or location is already set (unless forced)
    if (!forceRefresh &&
        (state.isLoading ||
            (state.hasValue && state.value?.location != null))) {
      return;
    }

    state = const AsyncValue<SearchState>.loading();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      debugPrint("Fetching current position...");
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 5),
        ),
      );
      debugPrint("Position found: ${position.latitude}, ${position.longitude}");

      final baseUrl = AppConfig.apiBaseUrl;
      final url = Uri.parse(
        '${baseUrl}location/reverse?lat=${position.latitude}&lon=${position.longitude}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];

        String city =
            address['city'] ??
            address['town'] ??
            address['village'] ??
            address['county'] ??
            address['state_district'] ??
            'Unknown Location';

        String stateName = address['state'] ?? '';

        String formattedAddress = city;
        if (stateName.isNotEmpty) {
          formattedAddress = "$city, $stateName";
        }

        // If everything fails, use display_name part
        if (city == 'Unknown Location' && data['display_name'] != null) {
          formattedAddress = data['display_name'].split(',')[0];
        }

        // Preserve other state values
        final currentState = state.value ?? SearchState();
        // Save to cache
        // Save to cache
        ref
            .read(localStorageServiceProvider)
            .saveLastLocation(formattedAddress);
        ref
            .read(localStorageServiceProvider)
            .saveLastCoordinates(position.latitude, position.longitude);

        state = AsyncValue.data(
          currentState.copyWith(
            location: formattedAddress,
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        );
      } else {
        throw 'Failed to fetch address';
      }
    } catch (e, st) {
      debugPrint("Error detecting location: $e");
      state = AsyncValue.error(e, st);
    }
  }

  void setLocation(String location) {
    // Save to cache when manually selected
    ref.read(localStorageServiceProvider).saveLastLocation(location);

    final currentState = state.value ?? SearchState();
    state = AsyncValue.data(currentState.copyWith(location: location));
  }

  void setDateRange(DateTimeRange range) {
    final currentState = state.value ?? SearchState();
    state = AsyncValue.data(currentState.copyWith(dateRange: range));
  }

  void setVehicleType(String type) {
    final currentState = state.value ?? SearchState();
    state = AsyncValue.data(currentState.copyWith(vehicleType: type));
  }
}

final searchControllerProvider =
    AsyncNotifierProvider<SearchController, SearchState>(() {
      return SearchController();
    });
