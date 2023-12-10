// ignore_for_file: unnecessary_string_interpolations

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:ocean/authentification/connexion.dart';
import 'package:ocean/authentification/user_data.dart';
import 'package:ocean/modeles/modelePrestataire.dart';
import 'package:ocean/pages/carte_page_map.dart';



class PrestataireRechercher {
  final String id;
  final String nomprenom;
  final String email;
  final String nomcommercial;
  final int numero;
  final String? downloadUrl;
  final bool prestataire;
  final String username;
  final String photoProfil;
  final int distance;
  final String domaineactivite;
  final Map<String, dynamic> location;
  // final int rating; // Nouvelle propriété pour stocker la notation du prestataire


  PrestataireRechercher(this.id, this.nomprenom, this.email, this.downloadUrl, this.prestataire, this.username, this.location, this.domaineactivite, this.distance, this.nomcommercial, this.numero, this.photoProfil,
  //  this.rating
  );
}

class SeachePage extends StatefulWidget {
  final String searchTerm;
  const SeachePage({super.key, required this.searchTerm});

  @override
  State<SeachePage> createState() => _SeachePageState();
}

class _SeachePageState extends State<SeachePage> {
  bool isLoading = true;
  List<PrestataireRechercher> prestatairesRechercher = [];

  Future<void> fetchPrestatairesByName() async {
    setState(() {
      isLoading = true; // Afficher le chargement
    });

    try {
      // final position = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      // );

      final apiUrl = 'https://ocean-52xt.onrender.com/users/prestatairesNom/${widget.searchTerm}';
      // final apiUrl = 'https://ocean-52xt.onrender.com/users/prestatairesNom/${widget.searchTerm}?lat=${position.latitude}&lng=${position.longitude}';
      print("Je veux voir l'url rechercher .......................... : ${apiUrl}");
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        print("Voici les résultats obtenus ::::::::::::::::::::::::::::::::::::::::::::::: ${data}");
        final fetchedPrestatairesRechercher = data
          .map((item) => PrestataireRechercher(
                item['_id'] as String,
                item['nomprenom'] as String,
                item['email'] as String,
                item['downloadUrl'] != null ? item['downloadUrl'] as String : "",
                item['prestataire'] as bool,
                item['username'] as String,
                item['location'] as Map<String, dynamic>,
                item['domaineactivite'] as String,
                // item['distance'] as int,
                item['distance'] != null ? item['distance'] as int : 0,
                item['nomcommercial'] as String,
                item['numero'] as int,
                item['photoProfil'] as String,
                // item['rating'] as int,
              ))
          .toList();

        setState(() {
          isLoading = false; // Cacher le chargement
          prestatairesRechercher = fetchedPrestatairesRechercher;
        });

        return;
      } else {
        print('Erreur lors de la récupération des données');
      }
    } catch (error) {
      print('Erreur lors de la requête HTTP : $error');
    }
  } 

  @override
  void initState() {
    super.initState();
    fetchPrestatairesByName();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.searchTerm}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Effectuez les actions nécessaires

            // Revenir à la page précédente
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(
              color: Colors.grey,
              border: Border.all(color: Colors.grey, width: 1.5),
              image: const DecorationImage(image: AssetImage('img/background.jpg'), fit: BoxFit.cover) // Changed Image.asset to AssetImage
          ),
          child: Center(child: _alternateContent()),
        ),
      ),
    );
  }

  Widget _alternateContent() {
      return isLoading ? const CircularProgressIndicator(color: Colors.white,) :
        prestatairesRechercher.isEmpty 
          ? Center(child: Text("Il n'y a aucun prestataire du nom de ${widget.searchTerm} dans\nla zone pour le moment.", style: const TextStyle(fontSize: 15),)) 
        : Column(
          children: [
            const Center(
              child: Text(
                " ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: prestatairesRechercher.length,
                itemBuilder: (context, index) {
                  final prestataire = prestatairesRechercher[index];
                  return Column(
                    children: [
                      const Divider(height: 8,),
                      InkWell(
                        onTap: () {
                          // Gérer ce que vous voulez faire lorsque l'utilisateur clique sur un prestataire

                          print("Bonjour");
                          if(UserData.token.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Info'),
                                  content: const Text("Veuillez-vous connecter pour avoir accès !"),
                                  actions: [
                                    TextButton(
                                      child: const Text('Connexion'),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const Connexion())
                                          // MaterialPageRoute(builder: (context) => CompteClient(documentFourni: documentFourni))
                                        );
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ModelePrestataire(nomprenom: prestataire.nomprenom, email: prestataire.email, prestataire: prestataire.prestataire, 
                                  id: prestataire.id, domaineactivite: prestataire.domaineactivite, nomcommercial: prestataire.nomcommercial, latitude: prestataire.location['coordinates'][1], 
                                  longitude: prestataire.location['coordinates'][0], numero: prestataire.numero, photoProfil: prestataire.photoProfil,),
                              ),
                            );
                            
                          }
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => ModelePrestataire(nomprenom: prestataire.nomprenom, email: prestataire.email, prestataire: prestataire.prestataire, 
                          //         id: prestataire.id, domaineactivite: prestataire.domaineactivite, nomcommercial: prestataire.nomcommercial, latitude: prestataire.location['coordinates'][1], 
                          //         longitude: prestataire.location['coordinates'][0], numero: prestataire.numero,),
                          //     ),
                          // );
                        },
                        child: Container(
                          height: 100,
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                          child: Row(
                            children: [
                              // const Padding(
                              //   padding: EdgeInsets.all(20.0),
                              //   child: Icon(Icons.person_2),
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Container(
                                  height: 100,
                                  width: MediaQuery.of(context).size.width * 0.350,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    // color: color, 
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: prestataire.photoProfil ?? '',
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                    height: 100,
                                    width: MediaQuery.of(context).size.width * 0.350,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  // padding: const EdgeInsets.all(8.0),
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Column(
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(child: Text(prestataire.nomprenom)),
                                              Expanded(child: Text("${prestataire.domaineactivite}")),
                                              // Expanded(
                                              //   child: ElevatedButton(
                                              //     onPressed: () {
                                              //       // Naviguer vers la page de la carte en passant les coordonnées du prestataire
                                              //       final coordinates = prestataire.location['coordinates'];
                                              //       final latitude = coordinates[1]; // Latitude
                                              //       final longitude = coordinates[0]; // Longitude
                                              
                                              //       Navigator.of(context).push(
                                              //         MaterialPageRoute(
                                              //           builder: (context) => CartePageMap(
                                              //             latitude: latitude,
                                              //             longitude: longitude,
                                              //           ),
                                              //         ),
                                              //       );
                                              //     },
                                              //     child: const Icon(Icons.map),
                                              //   ),
                                              // )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    // const Icon(Icons.location_on_outlined),
                                                    // const SizedBox(width: 3,),
                                                    Text(prestataire.username)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    // const Icon(Icons.contact_phone_outlined),
                                                    // const SizedBox(width: 3,),
                                                    // Text("0585649579")
                                                    // Text("${prestataire.numero.toString()}"), 
                                                    Text("${prestataire.nomcommercial}"), 
                                                  ],
                                                ),
                                              ),
                                              const Expanded(
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.directions_walk),
                                                    SizedBox(width: 3,),
                                                    // Text("${prestataire.distance} m"),
                                                    // const SizedBox(width: 3,),
                                                    Icon(Icons.location_on_outlined),
                                
                                                  ],
                                                ),
                                              )
                                              
                                            ],
                                          ),
                                          // _ratingBar()
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 8,),
                    ],
                  );
                },
              ),
            ),
          ],
      );
}
}