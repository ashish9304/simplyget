import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dio/dio.dart';
import 'package:good_to_go/shared/models/vehicle_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:good_to_go/core/network/dio_provider.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository(ref.read(dioProvider));
});

class VehicleRepository {
  final Dio _dio;
  VehicleRepository(this._dio);

  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await _dio.get('vehicles/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Vehicle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load vehicles');
      }
    } catch (e) {
      throw Exception('Failed to match vehicles: $e');
    }
  }

  Future<List<Vehicle>> getFeaturedVehicles() async {
    try {
      final response = await _dio.get('vehicles/featured');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Vehicle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load featured vehicles');
      }
    } catch (e) {
      throw Exception('Failed to load featured vehicles: $e');
    }
  }

  Future<List<Vehicle>> searchVehicles({
    String? type,
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? location,
  }) async {
    try {
      final response = await _dio.get(
        'vehicles/',
        queryParameters: {
          'type': type,
          'min_price': minPrice,
          'max_price': maxPrice,
          'brand': brand,
          'location': location,
        }..removeWhere((key, value) => value == null),
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search vehicles: $e');
    }
  }

  Future<String> uploadImage(XFile file) async {
    try {
      String fileName = file.name;
      final bytes = await file.readAsBytes();
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(bytes, filename: fileName),
      });
      final response = await _dio.post('upload/', data: formData);
      return response.data['url'];
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<Vehicle> createVehicle(Map<String, dynamic> vehicleData) async {
    try {
      final response = await _dio.post('vehicles/', data: vehicleData);
      return Vehicle.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create vehicle: $e');
    }
  }
}
