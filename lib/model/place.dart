import 'dart:typed_data';

class Place {
  int? seq;
  String placeName;
  String placePhone;
  double placeLat;
  double placeLng;
  Uint8List placeImage;
  String placeEstimate;
  String initDate;
  String updateDate;

  Place({
    this.seq,
    required this.placeName,
    required this.placePhone,
    required this.placeLat,
    required this.placeLng,
    required this.placeImage,
    required this.placeEstimate,
    required this.initDate,
    required this.updateDate,
  });

  Place.fromMap(Map<String, dynamic> res):
  seq = res['id'],
  placeName = res['placeName'],
  placePhone = res['placePhone'],
  placeLat = res['placeLat'],
  placeLng = res['placeLng'],
  placeImage = res['placeImage'],
  placeEstimate = res['placeEstimate'],
  initDate = res['initDate'],
  updateDate = res['updateDate'];
}