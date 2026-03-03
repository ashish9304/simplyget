import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String keyLastLocation = 'last_location';

  static const String keyLastLat = 'last_lat';
  static const String keyLastLng = 'last_lng';

  Future<void> saveLastLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastLocation, location);
  }

  Future<void> saveLastCoordinates(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyLastLat, lat);
    await prefs.setDouble(keyLastLng, lng);
  }

  Future<String?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLastLocation);
  }

  Future<Map<String, double>?> getLastCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(keyLastLat);
    final lng = prefs.getDouble(keyLastLng);
    if (lat != null && lng != null) {
      return {'lat': lat, 'lng': lng};
    }
    return null;
  }
}
