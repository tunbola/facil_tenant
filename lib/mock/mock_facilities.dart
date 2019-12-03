import 'package:facil_tenant/models/property_model.dart';

final List<PropertyModel> facilities = [
  PropertyModel(
    name: "Ibukun House",
    address: "12 Ibukun Drive, off Glorious Lane, V.I",
    /*city: "Victoria Island",
    state: "Lagos",
    country: "Nigeria",
    picture: "assets/img/apartments.png",
    apartments: 20,
    lat: 0,
    lng: 0,*/
  ),
  PropertyModel(
    name: "Bourdillion House",
    address: "12 Bourdillion Way, Ikoyi",
    /*city: "Ikoyi",
    state: "Lagos",
    country: "Nigeria",
    picture: "assets/img/block.png",
    apartments: 10,
    lat: 0,
    lng: 0,*/
  ),
  PropertyModel(
    name: "Agbowo Building",
    address: "Agbowo, Bodija, Ibadan",
    /*city: "Ibadan",
    state: "Oyo",
    country: "Nigeria",
    picture: "assets/img/properties.png",
    apartments: 600,
    lat: 0,
    lng: 0,*/
  ),
  PropertyModel(
    name: "Kings Court",
    address: "12, Tolbugatta Drive, Ibikan Street",
    /*city: "Banana Island",
    state: "Lagos",
    country: "Nigeria",
    picture: "assets/img/building.png",
    apartments: 200,
    lat: 0,
    lng: 0,*/
  ),
  PropertyModel(
    name: "Aso Rock Villa",
    address: "Presidential Drive, Asokoro",
    /*city: "Central Business District",
    state: "Abuja",
    country: "Nigeria",
    picture: "assets/img/apartment_building.png",
    apartments: 60,
    lat: 0,
    lng: 0,*/
  ),
];

Future<List<PropertyModel>> getFacilities() async {
  await Future.delayed(Duration(seconds: 2));
  return Future.value(facilities);
}

PropertyModel getFacility({String id}) {
  return facilities.firstWhere((it) => it.id == id);
}
