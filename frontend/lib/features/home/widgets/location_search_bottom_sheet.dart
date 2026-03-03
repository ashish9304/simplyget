import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:good_to_go/core/theme/app_colors.dart';
import 'package:good_to_go/features/home/controllers/search_controller.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:good_to_go/core/config/app_config.dart';

class LocationSearchBottomSheet extends ConsumerStatefulWidget {
  const LocationSearchBottomSheet({super.key});

  @override
  ConsumerState<LocationSearchBottomSheet> createState() =>
      _LocationSearchBottomSheetState();
}

class _LocationSearchBottomSheetState
    extends ConsumerState<LocationSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  bool _isLoadingSuggestions = false;

  List<Map<String, String>> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Auto-focus after the sheet animation completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _filteredLocations = [];
        _isLoadingSuggestions = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      final baseUrl = AppConfig.apiBaseUrl;
      final url = Uri.parse('${baseUrl}location/search?q=$query');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<Map<String, String>> results = [];
        for (var item in data) {
          final address = item['address'];
          // Extract relevant parts for "Area" and "City"
          String area = item['name'] ?? '';
          if (area.isEmpty) {
            area =
                address['suburb'] ??
                address['neighbourhood'] ??
                address['city_district'] ??
                address['town'] ??
                address['city'] ??
                item['display_name'].split(',')[0];
          }

          String cityState = "";
          final city =
              address['city'] ??
              address['town'] ??
              address['village'] ??
              address['county'];
          final state = address['state'];

          if (city != null && state != null) {
            cityState = "$city, $state";
          } else {
            cityState = item['display_name']
                .split(',')
                .skip(1)
                .take(2)
                .join(',')
                .trim();
          }

          results.add({
            'area': area,
            'city': cityState,
            'full_text': item['display_name'], // useful if we want full address
          });
        }

        if (mounted) {
          setState(() {
            _filteredLocations = results;
            _isLoadingSuggestions = false;
          });
        }
      } else {
        throw "Failed to load";
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSuggestions = false;
          // Optionally show error or just empty list
        });
      }
    }
  }

  bool _isCheckingLocation = false;

  Future<void> _handleUseCurrentLocation() async {
    setState(() {
      _isCheckingLocation = true;
    });

    try {
      // Check service enablement first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showErrorDialog(
            'Location services are disabled.',
            'Please enable location services in your device settings.',
          );
        }
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            _showErrorDialog(
              'Permission Denied',
              'Location permission is required to use this feature.',
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showErrorDialog(
            'Permission Permanently Denied',
            'Location permission is permanently denied. Please enable it in your device settings to use this feature.',
            openSettings: true,
          );
        }
        return;
      }

      // Permission granted, close sheet and fetch
      if (mounted) {
        Navigator.pop(context); // Close sheet
        // Trigger detection in controller
        ref.read(searchControllerProvider.notifier).detectLocation();
      }
    } catch (e) {
      debugPrint("Error in _handleUseCurrentLocation: $e");
      if (mounted) {
        _showErrorDialog('Error', 'An unexpected error occurred: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingLocation = false;
        });
      }
    }
  }

  void _showErrorDialog(
    String title,
    String message, {
    bool openSettings = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (openSettings)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleLocationSelect(String location) {
    ref.read(searchControllerProvider.notifier).setLocation(location);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Column(
          children: [
            // Header / Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search, color: Colors.grey),
                          hintText: "Search city or area",
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Use Current Location Option
            InkWell(
              onTap: _isCheckingLocation
                  ? null
                  : () {
                      debugPrint("Use Current Location Tapped");
                      _handleUseCurrentLocation();
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: _isCheckingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                              color: AppColors.primary,
                              size: 20,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isCheckingLocation
                              ? "Checking Permissions..."
                              : "Use Current Location",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        if (!_isCheckingLocation)
                          const Text(
                            "Enable location access",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, indent: 20, endIndent: 20),

            // Suggestions List
            Expanded(
              child: _isLoadingSuggestions
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _filteredLocations.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 20, endIndent: 20),
                      itemBuilder: (context, index) {
                        final loc = _filteredLocations[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                          ),
                          title: Text(
                            loc['area']!,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(loc['city']!),
                          onTap: () => _handleLocationSelect(
                            "${loc['area']}, ${loc['city']}",
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
