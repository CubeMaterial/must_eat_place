import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:must_eat_place/model/place.dart';

class ShowPlace extends StatefulWidget {
  const ShowPlace({super.key});

  @override
  State<ShowPlace> createState() => _ShowPlaceState();
}

class _ShowPlaceState extends State<ShowPlace> {
   // === Property ===
  late double _latData; // 위도
  late double _longData; // 경도
  late MapController _mapController; // flutter_map에서 가져온 MapController

  final Place _place = Get.arguments ?? '__';
  @override
  void initState() {
    super.initState();
    _latData = _place.placeLat;
    _longData = _place.placeLng;
    _mapController = MapController();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('위치 보기'),
         centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: flutterMap(),
    );
  } // build

  FlutterMap flutterMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: latlng.LatLng(_latData, _longData),
        initialZoom: 17.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: "com.t.t",
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 150,
              height: 80,
              point: latlng.LatLng(_latData, _longData),
              child: Column(
                children: [
                  Icon(Icons.pin_drop, color: Colors.red, size: 50,)
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  
} // class