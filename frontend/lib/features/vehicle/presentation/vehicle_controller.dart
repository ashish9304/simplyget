import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_to_go/features/vehicle/data/vehicle_repository.dart';
import 'package:good_to_go/shared/models/vehicle_model.dart';

final vehicleControllerProvider =
    AsyncNotifierProvider<VehicleController, List<Vehicle>>(
      VehicleController.new,
    );

final featuredVehiclesControllerProvider = FutureProvider<List<Vehicle>>((
  ref,
) async {
  return ref.read(vehicleRepositoryProvider).getFeaturedVehicles();
});

class VehicleController extends AsyncNotifier<List<Vehicle>> {
  @override
  FutureOr<List<Vehicle>> build() {
    return _fetchVehicles();
  }

  Future<List<Vehicle>> _fetchVehicles() async {
    return ref.read(vehicleRepositoryProvider).getVehicles();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchVehicles());
    ref.invalidate(featuredVehiclesControllerProvider);
  }
}
