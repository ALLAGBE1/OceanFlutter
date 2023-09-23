import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class CartePageMap extends StatefulWidget {
  final double latitude; // Latitude du prestataire
  final double longitude; // Longitude du prestataire

  CartePageMap({required this.latitude, required this.longitude});

  @override
  _CartePageMapState createState() => _CartePageMapState();
}

class _CartePageMapState extends State<CartePageMap> {
  late GoogleMapController _controller;
  Position? _userPosition; // Change this line
  Set<Polyline> _polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userPosition = position;
      });
      _getDirections();
    } catch (e) {
      print("Erreur lors de la récupération de la position du client : $e");
    }
  }

  void _getDirections() async {
    if (_userPosition != null) { // Check if _userPosition is not null
      String googleUrl =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${_userPosition!.latitude},${_userPosition!.longitude}&destination=${widget.latitude},${widget.longitude}&key=YOUR_API_KEY";

      var response = await http.get(Uri.parse(googleUrl));

      if (response.statusCode == 200) {
        String data = response.body;
        var jsonData = convert.jsonDecode(data);

        if (jsonData["routes"] != null && jsonData["routes"].length > 0) {
          String encodedPoints = jsonData["routes"][0]["overview_polyline"]["points"];
          List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(encodedPoints);
          List<LatLng> polylineCoordinates = decodedPoints
              .map((pointLatLng) => LatLng(pointLatLng.latitude, pointLatLng.longitude))
              .toList();
          setState(() {
            Polyline polyline = Polyline(
              polylineId: PolylineId('route'),
              visible: true,
              points: polylineCoordinates,
              width: 4,
              color: Colors.blue,
            );
            _polylines.add(polyline);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng prestataireLocation = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text('Trajet vers le prestataire'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _controller = controller;
        },
        initialCameraPosition: CameraPosition(
          target: prestataireLocation, // Centrez la carte sur la position du prestataire
          zoom: 15, // Ajustez le niveau de zoom selon vos besoins
        ),
        markers: {
          Marker(
            markerId: MarkerId('prestataire'),
            position: prestataireLocation,
            infoWindow: InfoWindow(
              title: 'Prestataire',
              snippet: 'Latitude: ${widget.latitude}, Longitude: ${widget.longitude}',
            ),
          ),
          if (_userPosition != null) // Ajoutez le marqueur de la position du client si disponible
            Marker(
              markerId: MarkerId('client'),
              position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
              infoWindow: InfoWindow(
                title: 'Client',
                snippet:
                    'Latitude: ${_userPosition!.latitude}, Longitude: ${_userPosition!.longitude}',
              ),
            ),
        },
        polylines: _polylines, // Vue des polylines
      ),
    );
  }
}

// ::::::::::::::::

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_webservice/directions.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// class CartePageMap extends StatefulWidget {
//   final double latitude; // Latitude du prestataire
//   final double longitude; // Longitude du prestataire

//   CartePageMap({required this.latitude, required this.longitude});

//   @override
//   _CartePageMapState createState() => _CartePageMapState();
// }

// class _CartePageMapState extends State<CartePageMap> {
//   late GoogleMapController _controller;
//   final googleMapsServices = GoogleMapsServices();
//   late Position _userPosition; // Position du client
//   Set<Polyline> _polylines = {}; // Ajoutez ceci

//   @override
//   void initState() {
//     super.initState();
//     _getUserLocation(); // Récupérer la position du client lorsque la page est créée
//   }

//   void _getUserLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         _userPosition = position;
//       });
//       _getDirections(); // Une fois que la position du client est obtenue, obtenez les directions
//     } catch (e) {
//       print("Erreur lors de la récupération de la position du client : $e");
//     }
//   }

//   void _getDirections() async {
//     if (_userPosition != null) {
//       var directions = await googleMapsServices.getRouteCoordinates(
//         LatLng(_userPosition.latitude, _userPosition.longitude),
//         LatLng(widget.latitude, widget.longitude),
//       );
//       setState(() {
//         _polylines.add(Polyline(
//           polylineId: PolylineId('route'),
//           visible: true,
//           points: directions,
//           width: 4,
//           color: Colors.blue,
//         ));
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     LatLng prestataireLocation = LatLng(widget.latitude, widget.longitude);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Trajet vers le prestataire'),
//       ),
//       body: GoogleMap(
//         onMapCreated: (controller) {
//           setState(() {
//             _controller = controller;
//           });
//         },
//         initialCameraPosition: CameraPosition(
//           target: prestataireLocation, // Centrez la carte sur la position du prestataire
//           zoom: 15, // Ajustez le niveau de zoom selon vos besoins
//         ),
//         markers: {
//           Marker(
//             markerId: MarkerId('prestataire'),
//             position: prestataireLocation,
//             infoWindow: InfoWindow(
//               title: 'Prestataire',
//               snippet: 'Latitude: ${widget.latitude}, Longitude: ${widget.longitude}',
//             ),
//           ),
//           if (_userPosition != null) // Ajoutez le marqueur de la position du client si disponible
//             Marker(
//               markerId: MarkerId('client'),
//               position: LatLng(_userPosition.latitude, _userPosition.longitude),
//               infoWindow: InfoWindow(
//                 title: 'Client',
//                 snippet:
//                     'Latitude: ${_userPosition.latitude}, Longitude: ${_userPosition.longitude}',
//               ),
//             ),
//         },
//         polylines: _polylines, // Et changez ceci
//       ),
//     );
//   }
// }

// class GoogleMapsServices {
//   Future<List<LatLng>> getRouteCoordinates(LatLng l1, LatLng l2) async {
//     String url =
//         "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=YOUR_API_KEY";
//     http.Response response = await http.get(url);
//     Map values = jsonDecode(response.body);
//     return PolylinePoints().decodePolyline(values["routes"][0]["overview_polyline"]["points"]);
//   }
// }


// ::::::::::::::::::::::::

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';


// class CartePageMap extends StatelessWidget {
//   final double latitude;
//   final double longitude;

//   CartePageMap({required this.latitude, required this.longitude});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Localisation du prestataire'),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: LatLng(latitude, longitude),
//           zoom: 15, // Ajustez le niveau de zoom selon vos besoins
//         ),
//         markers: {
//           Marker(
//             markerId: MarkerId('prestataire'),
//             position: LatLng(latitude, longitude),
//             infoWindow: InfoWindow(
//               title: 'Prestataire',
//               snippet: 'Latitude: $latitude, Longitude: $longitude',
//             ),
//           ),
//         },
//       ),
//     );
//   }
// }


// class CartePageMap extends StatelessWidget {
//   final double latitude;
//   final double longitude;

//   CartePageMap({required this.latitude, required this.longitude});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Localisation du prestataire'),
//       ),
//       body: Center(
//         child: Text(
//           'Latitude: $latitude, Longitude: $longitude',
//           style: const TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }
