import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:good_to_go/core/theme/app_colors.dart';
import 'package:good_to_go/features/vehicle/data/vehicle_repository.dart';
import 'package:good_to_go/features/home/controllers/search_controller.dart';
import 'package:good_to_go/shared/models/vehicle_model.dart';

// Provider for search results
final vehicleSearchProvider = FutureProvider.autoDispose
    .family<List<Vehicle>, Map<String, dynamic>>((ref, filters) async {
      final repo = ref.read(vehicleRepositoryProvider);
      return repo.searchVehicles(
        type: filters['type'],
        minPrice: filters['min_price'],
        maxPrice: filters['max_price'],
        location: filters['location'],
      );
    });

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  // Filters
  String? _selectedType;
  RangeValues _priceRange = const RangeValues(0, 10000);
  final TextEditingController _locationController = TextEditingController();

  void _applyFilters() {
    setState(() {}); // Trigger rebuild to refetch provider
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill location from global search state if available
    final searchState = ref.read(searchControllerProvider).value;
    if (searchState?.location != null) {
      _locationController.text = searchState!.location!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = {
      'type': _selectedType,
      'min_price': _priceRange.start > 0 ? _priceRange.start : null,
      'max_price': _priceRange.end < 10000 ? _priceRange.end : null,
      'location': _locationController.text.isNotEmpty
          ? _locationController.text
          : null,
    };

    final searchResults = ref.watch(vehicleSearchProvider(filters));

    return Scaffold(
      appBar: AppBar(title: const Text("Find Your Vehicle")),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Location Input
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on),
                    hintText: "Location",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _applyFilters,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 10,
                    ),
                  ),
                  onSubmitted: (_) => _applyFilters(),
                ),
                const SizedBox(height: 10),
                // Filters Row
                Row(
                  children: [
                    // Type Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          border: OutlineInputBorder(),
                          labelText: "Type",
                        ),
                        // initialValue: _selectedType, // Using value instead as it's a controlled field
                        // ignore: deprecated_member_use
                        value: _selectedType,
                        items: const [
                          DropdownMenuItem(value: null, child: Text("All")),
                          DropdownMenuItem(value: 'car', child: Text("Car")),
                          DropdownMenuItem(value: 'bike', child: Text("Bike")),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedType = val);
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Price Filter Config (Button to open dialog or simplified)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _showPriceFilterDialog,
                        child: Text(
                          "Price: ₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()}",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Results List
          Expanded(
            child: searchResults.when(
              data: (vehicles) {
                if (vehicles.isEmpty) {
                  return const Center(
                    child: Text("No vehicles found matching your criteria."),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return _buildVehicleCard(context, vehicle);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }

  void _showPriceFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Price Range (Per Day)"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    labels: RangeLabels(
                      "₹${_priceRange.start.toInt()}",
                      "₹${_priceRange.end.toInt()}",
                    ),
                    onChanged: (values) {
                      setState(() => _priceRange = values);
                    },
                  ),
                  Text(
                    "₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()}",
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => _applyFilters());
  }

  Widget _buildVehicleCard(BuildContext context, Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/vehicle', extra: vehicle),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                vehicle.imageUrl ?? 'https://via.placeholder.com/400x200',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${vehicle.brand} ${vehicle.model}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "₹${vehicle.pricePerDay.toInt()}/day",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        vehicle.type == 'car'
                            ? Icons.directions_car
                            : Icons.two_wheeler,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.type.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          vehicle.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (vehicle.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        Text(
                          " ${vehicle.rating}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
