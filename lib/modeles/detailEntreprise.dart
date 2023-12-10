// ignore_for_file: unnecessary_string_interpolations

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:ocean/authentification/user_data.dart';
import 'package:permission_handler/permission_handler.dart';

class DetailEntreprise extends StatefulWidget {
  const DetailEntreprise({Key? key}) : super(key: key);

  @override
  State<DetailEntreprise> createState() => _DetailEntrepriseState();
}

class _DetailEntrepriseState extends State<DetailEntreprise> {
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool isLocationUpdated = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    if (await Permission.location.request().isGranted) {
      _getLocation();
    }
  }

  Future<void> _getLocation() async {
    if (await Permission.location.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        if (isLocationUpdated) {
          setState(() {
            _longitude = position.longitude;
            _latitude = position.latitude;
            print("Longitude: $_longitude");
            print("Latitude: $_latitude");
          });

          var newLocation = {
            "type": "Point",
            "coordinates": [_longitude, _latitude]
          };

          // Convertissez l'objet en format JSON
          String jsonLocation = jsonEncode({"location": newLocation});

          // Envoyez la requête PUT à l'API
          var response = await http.put(
            Uri.parse('https://ocean-52xt.onrender.com/users/prestataires/${UserData.id}'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonLocation,
          );

          // Vérifiez si la requête a réussi
          if (response.statusCode == 200) {
            // Réponse réussie, mettez à jour l'interface utilisateur si nécessaire
            setState(() {
              _longitude = position.longitude;
              _latitude = position.latitude;
              print("Coordonnées mises à jour avec succès.");
            });
          } else {
            // La requête a échoué, affichez le code d'erreur
            print("Échec de la mise à jour des coordonnées. Code d'erreur : ${response.statusCode}");
          }
        }
      } catch (e) {
        print('Erreur lors de l\'obtention de la position : $e');
        // Gérer l'erreur de géolocalisation ici
      }
    } else {
      print('Permission de localisation non accordée.');
      // Demandez à nouveau l'autorisation ou guidez l'utilisateur vers les paramètres pour les autorisations
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de l'entreprise"),
      ),
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        decoration: BoxDecoration(
            color: Colors.grey,
            border: Border.all(color: Colors.grey, width: 1.5),
            image: const DecorationImage(image: AssetImage('img/background.jpg'), fit: BoxFit.cover) // Changed Image.asset to AssetImage
          ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text("${UserData.nomprenom}", style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,)),
            const SizedBox(height: 15,),
            Text("Domaine d'activité : ${UserData.domaineactivite}", style: const TextStyle(color: Colors.white),),
            const SizedBox(height: 15,),
            Text("Disponible : ${UserData.disponible}", style: const TextStyle(color: Colors.white),),
            const SizedBox(height: 15,),
            Text("Nom commercial : ${UserData.nomcommercial}", style: const TextStyle(color: Colors.white),),
            const SizedBox(height: 15,),
            Text("Email : ${UserData.email}", style: const TextStyle(color: Colors.white),),
            const SizedBox(height: 15,),
            Text("Numéro : ${UserData.numero}", style: const TextStyle(color: Colors.white),),
            const SizedBox(height: 15,),
            Text("Latitude : ${UserData.latitude}", style: const TextStyle(color: Colors.white),),
            const SizedBox(height: 15,), 
            Text("Longitude : ${UserData.longitude}", style: const TextStyle(color: Colors.white),),
            const SizedBox(height: 15,),
            Text("Nom du lieu : ${UserData.nomDuLieu}", style: const TextStyle(color: Colors.white),),
            const SizedBox(height: 15,),
            // Text("Id de l'utilisateur : ${UserData.id}", style: const TextStyle(color: Colors.white),),

            const SizedBox(height: 20.0), // Espacement
            // ElevatedButton(
            //   onPressed: _getLocation,
            //   child: const Text("Mise à jour de la position"),
            // ),
            // Center(
            //   child: ElevatedButton(
            //     onPressed: () {
            //       setState(() {
            //         isLocationUpdated = true; // Mettez à jour le drapeau ici
            //       });
            //       _getLocation();
            //     },
            //     child: const Text("Mise à jour de la position"),
            //   ),
            // ),
            // const SizedBox(height: 20.0), // Espacement
            // const Text("Coordonnées géographiques :"),
            // Text("Latitude: $_latitude"),
            // Text("Longitude: $_longitude"),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLocationUpdated = true; // Mettez à jour le drapeau ici
                  });
                  _getLocation();
                  _showLocationDialog(); // Afficher le dialogue après la mise à jour
                },
                child: const Text("Mise à jour de la position"),
              ),
            ),
            const SizedBox(height: 20.0), // Espacement
            
           
          ],
        ),
      ),
    );
  }

  AlertDialog _buildLocationDialog(BuildContext context) {
  return AlertDialog(
    // title: const Text("Votre position géographique a été mise à jour avec succès."),
    // title: const Text("Coordonnées géographiques :"),
    content: const Text("Votre position géographique a été mise à jour avec succès.", style: TextStyle(fontSize: 20),),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(); // Fermer le dialogue lorsque le bouton est cliqué
        },
        child: const Text('Fermer'),
      ),
    ],
  );
}

void _showLocationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return _buildLocationDialog(context);
    },
  );
}
}




// // ignore_for_file: unnecessary_string_interpolations, use_build_context_synchronously, prefer_const_constructors, avoid_print
// // AIzaSyAsNXk9Lonwzza_cKPSRKlcQmpNZIXNh_U
// // AIzaSyCr1RuzlktW07p-DPaQylXgtuVdWGmFd1A
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
// import 'package:ocean/authentification/user_data.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;

// class DetailEntreprise extends StatefulWidget {
//   const DetailEntreprise({super.key});

//   @override
//   State<DetailEntreprise> createState() => _DetailEntrepriseState();
// }

// class _DetailEntrepriseState extends State<DetailEntreprise> {
//   double _latitude = 0.0;
//   double _longitude = 0.0;
//   bool isLocationUpdated = false;


//   @override
//   void initState() {
//     super.initState();
//     _checkPermission();
//   }

//   Future<void> _checkPermission() async {
//     if (await Permission.location.request().isGranted) {
//       _getLocation();
//     }
//   }

//   // Future<void> _getLocation() async {
//   //   try {
//   //     final position = await Geolocator.getCurrentPosition(
//   //       desiredAccuracy: LocationAccuracy.best,
//   //     );
//   //     if (isLocationUpdated) {
//   //       setState(() {
//   //         _longitude = position.longitude;
//   //         _latitude = position.latitude;
//   //         print("Longitude: $_longitude");
//   //         print("Latitude: $_latitude");
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print('Erreur lors de l\'obtention de la position : $e');
//   //     // Gérer l'erreur de géolocalisation ici
//   //   }
//   // }

//   Future<void> _getLocation() async {
//     if (await Permission.location.isGranted) {
//       try {
//         final position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.best,
//         );
//         if (isLocationUpdated) {
//           setState(() {
//             _longitude = position.longitude;
//             _latitude = position.latitude;
//             print("Longitude: $_longitude");
//             print("Latitude: $_latitude");
//           });
//         }
//       } catch (e) {
//         print('Erreur lors de l\'obtention de la position : $e');
//         // Gérer l'erreur de géolocalisation ici
//       }
//     } else {
//       print('Permission de localisation non accordée.');
//       // Demandez à nouveau l'autorisation ou guidez l'utilisateur vers les paramètres pour les autorisations
//     }
//   }



//   Future<void> _updateLocation() async {
//     setState(() {
//       isLocationUpdated = true;
//     });
//     // _getLocation(); // Mettre à jour les coordonnées géographiques

//     try {
//       // _getLocation();
//       // Créez un objet contenant les nouvelles coordonnées géographiques au format requis par votre API
//       var newLocation = {
//         "type": "Point",
//         "coordinates": [_longitude, _latitude]
//       };

//       // Convertissez l'objet en format JSON
//       String jsonLocation = jsonEncode({"location": newLocation});

//       // Envoyez la requête PUT à l'API
//       var response = await http.put(
//         Uri.parse('https://ocean-52xt.onrender.com/users/prestataires/${UserData.id}'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonLocation,
//       );

//       // Vérifiez si la requête a réussi
//       if (response.statusCode == 200) {
//         // Réponse réussie, mettez à jour l'interface utilisateur si nécessaire
//         print("Coordonnées mises à jour avec succès.");
//       } else {
//         // La requête a échoué, affichez le code d'erreur
//         print("Échec de la mise à jour des coordonnées. Code d'erreur : ${response.statusCode}");
//       }
//     } catch (e) {
//       print('Erreur lors de l\'obtention de la position : $e');
//       // Gérer l'erreur de géolocalisation ici
//     }

//     // try {
//     //   final position = await Geolocator.getCurrentPosition(
//     //     desiredAccuracy: LocationAccuracy.best,
//     //   );

//     //   // Créez un objet contenant les nouvelles coordonnées géographiques au format requis par votre API
//     //   var newLocation = {
//     //     "type": "Point",
//     //     "coordinates": [_longitude, _latitude]
//     //   };

//     //   // Convertissez l'objet en format JSON
//     //   String jsonLocation = jsonEncode({"location": newLocation});

//     //   // Envoyez la requête PUT à l'API
//     //   var response = await http.put(
//     //     Uri.parse('https://ocean-52xt.onrender.com/users/prestataires/${UserData.id}'),
//     //     headers: <String, String>{
//     //       'Content-Type': 'application/json; charset=UTF-8',
//     //     },
//     //     body: jsonLocation,
//     //   );

//     //   // Vérifiez si la requête a réussi
//     //   if (response.statusCode == 200) {
//     //     // Réponse réussie, mettez à jour l'interface utilisateur si nécessaire
//     //     print("Coordonnées mises à jour avec succès.");
//     //   } else {
//     //     // La requête a échoué, affichez le code d'erreur
//     //     print("Échec de la mise à jour des coordonnées. Code d'erreur : ${response.statusCode}");
//     //   }
//     // } catch (e) {
//     //   print('Erreur lors de l\'obtention de la position : $e');
//     //   // Gérer l'erreur de géolocalisation ici
//     // }
//     // _getLocation();
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Détails de l'entreprise"),
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("${UserData.nomprenom}", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
//             Text("Domaine d'activité : ${UserData.domaineactivite}"),
//             Text("Disponible : ${UserData.disponible}"),
//             Text("Nom commercial : ${UserData.nomcommercial}"),
//             Text("Email : ${UserData.email}"),
//             Text("Latitude : ${UserData.latitude}"),
//             Text("Longitude : ${UserData.longitude}"),
//             Text("Nom du lieu : ${UserData.nomDuLieu}"),
//             Text("Id de l'utilisateur : ${UserData.id}"),

//             SizedBox(height: 20.0), // Espacement
//             ElevatedButton(
//               onPressed: _updateLocation,
//               child: const Text("Mise à jour de la position"),
//             ),
//             SizedBox(height: 20.0), // Espacement
//             Text("Coordonnées géographiques :"),
//             Text("Latitude: $_latitude"),
//             Text("Longitude: $_longitude"),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ::::::::::

// // ignore_for_file: unnecessary_string_interpolations, use_build_context_synchronously

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
// import 'package:ocean/authentification/user_data.dart';
// import 'package:permission_handler/permission_handler.dart';

// class DetailEntreprise extends StatefulWidget {
//   const DetailEntreprise({super.key});

//   @override
//   State<DetailEntreprise> createState() => _DetailEntrepriseState();
// }

// class _DetailEntrepriseState extends State<DetailEntreprise> {
//   double _latitude = 0.0;
//   double _longitude = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _checkPermission();
//   }

//   Future<void> _checkPermission() async {
//     if (await Permission.location.request().isGranted) {
//       _getLocation();
//     }
//   }

//   Future<void> _getLocation() async {
//     try {
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.best,
//       );
//       setState(() {
//         _longitude = position.longitude;
//         _latitude = position.latitude;
//         print("Longitude: $_longitude");
//         print("Latitude: $_latitude");
//     });
//     } catch (e) {
//       print('Erreur lors de l\'obtention de la position : $e');
//       // Gérer l'erreur de géolocalisation ici
//     }
//   }

//   Future<void> enregistrerUtilisateur() async {

//     // Créez une requête multipart
//     var uri = Uri.parse('https://ocean-52xt.onrender.com/users/sinscrire');
//     var request = http.MultipartRequest('POST', uri)
//       ..fields['location'] = jsonEncode({
//         'type': 'Point',
//         'coordinates': [_longitude, _latitude]
//       });

//       print('Réponse du ppppppppppppppppppppppppppppp: ${request}');

//     try {
//       print('Réponse du serveur: 111111111111111111111111111');
//       var response = await request.send();
//       print('Réponse du serveur: 2222222222222222222222222222');
//       // Vérifier la réponse du serveur
//       if (response.statusCode == 200) {
//         print('Réponse du serveur: 3333333333333333333333333333');
//         // Vous pouvez également convertir la réponse en texte pour obtenir des détails
//         String responseBody = await response.stream.bytesToString();
//         print('Réponse du serveur: 4444444444444444444444444444444444');
//         print('Réponse du serveur: $responseBody');
//         print('Réponse du serveur: 555555555555555555555555555555555');
//         // Enregistrement réussi
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Succès'),
//               content: const Text('L\'utilisateur a été enregistré avec succès.'),
//               actions: [
//                 TextButton(
//                   child: const Text('OK'),
//                   onPressed: () {
//                     Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const Connexion())
//                     // MaterialPageRoute(
//                     //     builder: (context) => const ConfirmationScreen())
//                   );
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       } else {
//         // Erreur lors de l'enregistrement
//         print('Réponse du serveur: 6666666666666666666666666666666');
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Erreur'),
//               content: const Text('Une erreur est survenue lors de l\'enregistrement de l\'utilisateur.'),
//               actions: [
//                 TextButton(
//                   child: const Text('OK'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     } catch (error) {
//       print('Erreur : $error');
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Erreur'),
//             content: const Text('Une erreur est survenue lors de la connexion au serveur.'),
//             actions: [
//               TextButton(
//                 child: const Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Détails de l'entreprise"),
//       ),
//       body: Container(
//         child: Column(
//           children: [
//             Text("${UserData.nomprenom}"),
//             Text("${UserData.domaineactivite}"),
//             Text("${UserData.disponible}"),
//             Text("${UserData.nomcommercial}"),
//             ElevatedButton(onPressed: (){}, child: const Text("Mise à jour de la position"))
//           ],
//         ), // Accéder à la liste une fois qu'elle n'est plus vide
//       ), 
//     );
//   }
// }


// ::::::::::::




// class Partenaire {
//   final String id;
//   final String nomprenom;
//   final String email;
//   final String domaineactivite;
//   final String downloadUrl;
//   final bool prestataire; 

//   Partenaire(this.id, this.nomprenom, this.email, this.domaineactivite, this.downloadUrl, this.prestataire);
// }




  // bool isLoading = true;
  // List<Partenaire> partenaires = [];

  // Future<List<Partenaire>> fetchData() async {
  //   setState(() {
  //     isLoading = true; // Afficher le chargement
  //   });

  //   final response = await http.get(Uri.parse('https://ocean-52xt.onrender.com/users/partenaires'));

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body) as List<dynamic>;
  //     print("Bonjour ici .............. ${data}");
  //     final fetchedPartenaires = data
  //       .map((item) => Partenaire(
  //             item['_id'] as String,
  //             item['nomprenom'] as String,
  //             item['email'] as String,
  //             item['domaineactivite'] as String,
  //             item['downloadUrl'] as String,  // Ajoutez ceci
  //             item['prestataire'] as bool,
              
  //           ))
  //       .toList();


  //     setState(() {
  //       isLoading = false; // Cacher le chargement
  //       partenaires = fetchedPartenaires;
  //     });

  //     return fetchedPartenaires;
  //   } else {
  //     throw Exception('Failed to fetch data from MongoDB');
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   fetchData();  
  // }

