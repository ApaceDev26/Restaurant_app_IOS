import 'package:google_maps_flutter/google_maps_flutter.dart';

class ZoneModel {
  int? id;
  String? name;
  Coordinates? coordinates;
  List<LatLng>? formatedCoordinates;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? restaurantWiseTopic;
  String? customerWiseTopic;
  String? deliverymanWiseTopic;
  double? minimumShippingCharge;
  double? perKmShippingCharge;

  ZoneModel({
    this.id,
    this.name,
    this.coordinates,
    this.formatedCoordinates,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.restaurantWiseTopic,
    this.customerWiseTopic,
    this.deliverymanWiseTopic,
    this.minimumShippingCharge,
    this.perKmShippingCharge,
  });

  ZoneModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    coordinates =
        json['coordinates'] != null ? Coordinates.fromJson(json['coordinates']) : null;
    if (json['formated_coordinates'] != null) {
      formatedCoordinates = <LatLng>[];
      json['formated_coordinates'].forEach((v) {
        formatedCoordinates!.add(LatLng(
          double.parse(v['lat'].toString()),
          double.parse(v['lng'].toString()),
        ));
      });
    } else if (coordinates?.coordinates != null) {
      formatedCoordinates = List<LatLng>.from(coordinates!.coordinates!);
    }
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    restaurantWiseTopic = json['restaurant_wise_topic'];
    customerWiseTopic = json['customer_wise_topic'];
    deliverymanWiseTopic = json['deliveryman_wise_topic'];
    minimumShippingCharge = json['minimum_shipping_charge']?.toDouble();
    perKmShippingCharge = json['per_km_shipping_charge']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (coordinates != null) {
      data['coordinates'] = coordinates!.toJson();
    }
    if (formatedCoordinates != null) {
      data['formated_coordinates'] = formatedCoordinates!
          .map((e) => {'lat': e.latitude, 'lng': e.longitude})
          .toList();
    }
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['restaurant_wise_topic'] = restaurantWiseTopic;
    data['customer_wise_topic'] = customerWiseTopic;
    data['deliveryman_wise_topic'] = deliverymanWiseTopic;
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    return data;
  }
}

class Coordinates {
  String? type;
  List<LatLng>? coordinates;

  Coordinates({this.type, this.coordinates});

  Coordinates.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['coordinates'] != null) {
      coordinates = <LatLng>[];
      // GeoJSON: [lng, lat]
      json['coordinates'][0].forEach((v) {
        coordinates!.add(LatLng(
          double.parse(v[1].toString()),
          double.parse(v[0].toString()),
        ));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (coordinates != null) {
      data['coordinates'] =
          coordinates!.map((v) => [v.longitude, v.latitude]).toList();
    }
    return data;
  }
}
