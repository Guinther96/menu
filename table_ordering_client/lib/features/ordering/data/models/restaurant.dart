import 'package:table_ordering_client/features/ordering/domain/entities/restaurant_entity.dart';

class Restaurant {
  const Restaurant({required this.id, required this.name});

  final String id;
  final String name;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(id: json['id'] as String, name: json['name'] as String);
  }

  RestaurantEntity toEntity() => RestaurantEntity(id: id, name: name);
}
