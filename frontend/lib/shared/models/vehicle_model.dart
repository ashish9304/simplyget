class Vehicle {
  final String id;
  final String ownerId;
  final String type;
  final String brand;
  final String model;
  final double pricePerDay;
  final String location;
  final bool isAvailable;
  final String? imageUrl;
  final List<String>? imageUrls;
  final double? rating;
  final String? description;
  final double? lat;
  final double? lng;

  Vehicle({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.brand,
    required this.model,
    required this.pricePerDay,
    required this.location,
    required this.isAvailable,
    this.imageUrl,
    this.imageUrls,
    this.rating,
    this.description,
    this.lat,
    this.lng,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      type: json['type'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      pricePerDay: (json['price_per_day'] as num).toDouble(),
      location: json['location'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      imageUrl: json['image_url'] as String?,
      imageUrls: (json['image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      rating: (json['rating'] as num?)?.toDouble(),
      description: json['description'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }
}
