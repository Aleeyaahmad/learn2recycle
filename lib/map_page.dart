import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  LatLng? _userLocation;
  final Set<Marker> _markers = {};
  final LatLng _defaultLocation = LatLng(3.1390, 101.6869); // Kuala Lumpur
  final TextEditingController _locationSearchController = TextEditingController();

  final String apiKey = 'AIzaSyBkHOjTjil-E826hUanAPFxRJGoZ_PQtPU';

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      await Geolocator.requestPermission();
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });

      _controller?.animateCamera(
        CameraUpdate.newLatLng(_userLocation!),
      );

      _loadRecyclingCenters();
    } catch (e) {
      setState(() {
        _userLocation = _defaultLocation;
      });
      _loadRecyclingCenters();
    }
  }

  Future<void> _loadRecyclingCenters() async {
    if (_userLocation == null) return;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${_userLocation!.latitude},${_userLocation!.longitude}'
      '&radius=10000'
      '&keyword=recycling%20center'
      '&key=$apiKey',
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      setState(() {
        _markers.clear();
        for (var place in data['results']) {
          final lat = place['geometry']['location']['lat'];
          final lng = place['geometry']['location']['lng'];
          final name = place['name'];

          _markers.add(Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
          ));
        }
      });
    } else {
      debugPrint("Places API error: ${data['status']}");
    }
  }

  Future<void> _searchLocation(String placeName) async {
    if (placeName.isEmpty) return;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?address=${Uri.encodeComponent(placeName)}'
      '&key=$apiKey',
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      final location = data['results'][0]['geometry']['location'];
      final LatLng newLocation = LatLng(location['lat'], location['lng']);

      setState(() {
        _userLocation = newLocation;
      });

      _controller?.animateCamera(
        CameraUpdate.newLatLng(newLocation),
      );

      _loadRecyclingCenters();
    } else {
      debugPrint("Geocoding API error: ${data['status']}");
    }
  }

  Future<void> _resetToCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _userLocation = currentLatLng;
      });

      _controller?.animateCamera(
        CameraUpdate.newLatLng(currentLatLng),
      );

      _loadRecyclingCenters();
    } catch (e) {
      debugPrint("Error resetting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recycling Centers Around You',
          style: TextStyle(fontSize: 20, fontFamily: 'Comfortaa', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFFa4c291),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationSearchController,
                    decoration: InputDecoration(
                      hintText: 'Search city or place',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (value) {
                      _searchLocation(value);
                    },
                  ),
                ),
                IconButton(
                  icon: Image.asset('assets/icons/search.png', height: 28, width: 28, color: Color(0xFFa4c291)),
                  onPressed: () {
                    _searchLocation(_locationSearchController.text);
                  },
                ),
              ],
            ),
          ),
          // Map Section
          Expanded(
            child: Stack(
              children: [
                _userLocation == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        onMapCreated: (controller) {
                          _controller = controller;
                          if (_userLocation != null) {
                            _controller?.animateCamera(
                              CameraUpdate.newLatLng(_userLocation!),
                            );
                          }
                        },
                        initialCameraPosition: CameraPosition(
                          target: _userLocation ?? _defaultLocation,
                          zoom: 14,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        markers: _markers,
                      ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetToCurrentLocation,
        backgroundColor: Color(0xFFa4c291),
        child: Image.asset('assets/icons/location.png', height: 28, width: 28, color: Colors.white),
      ),
    );
  }
}
