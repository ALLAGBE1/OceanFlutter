import 'package:flutter/material.dart';

class CartePageMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  CartePageMap({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localisation du prestataire'),
      ),
      body: Center(
        child: Text(
          'Latitude: $latitude, Longitude: $longitude',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
