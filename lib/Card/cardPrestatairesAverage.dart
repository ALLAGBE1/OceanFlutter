import 'package:flutter/material.dart';

class cardPrestatairesAverage extends StatelessWidget {
  // final String imageUrl;
  final double averageRating;
  final String id;

  const cardPrestatairesAverage({super.key, 
    // required this.imageUrl,
    required this.averageRating,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.8,
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.black54,
          child: Column(
            children: [
              Text(
                // averageRating as String,
                averageRating.toString(), // Convertir en String
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
