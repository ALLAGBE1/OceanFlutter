// ignore_for_file: unnecessary_string_interpolations, avoid_print, constant_identifier_names, unnecessary_brace_in_string_interps, prefer_const_declarations

import 'dart:convert';
import 'dart:typed_data';
// import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:ocean/Card/cardPrestatairesAverage.dart';
import 'package:ocean/authentification/connexion.dart';
import 'package:ocean/authentification/user_data.dart';
import 'package:ocean/modeles/modelePrestataire.dart';
import 'package:ocean/pages/carte_page_map.dart';
// import 'package:ocean/pages/resultatRecherche.dart';
import 'package:ocean/pages/searchePage.dart';



// Image decodeBase64ToImage(String base64String) {
//   Uint8List bytes = base64.decode(base64String);
//   return Image.memory(bytes);
// }

Image? decodeBase64ToImage(String base64String) {
  try {
    Uint8List bytes = base64.decode(base64String);
    return Image.memory(bytes);
  } catch (e) {
    print('Erreur lors du décodage de l\'image : $e');
    return null;
  }
}

class Metier {
  final String id;
  final String domaineactivite;

  Metier(this.id, this.domaineactivite);
}

class Prestataire {
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


  Prestataire(this.id, this.nomprenom, this.email, this.downloadUrl, this.prestataire, this.username, this.location, this.domaineactivite, this.distance, this.nomcommercial, this.numero, this.photoProfil,
  //  this.rating
  );
}

class PrestatairesAverage {
  final String id;
  final double averageRating;
  final Map<String, dynamic> prestataire_info; // Champ 'prestataire' est de type Map<String, dynamic>

  PrestatairesAverage(this.id, this.averageRating, this.prestataire_info);
  
  // String get nomprenom => prestataire['nomprenom']; // Accès à nomprenom à l'intérieur de l'objet author
  String get nomprenom => prestataire_info['nomprenom']; // Accès à nomprenom à l'intérieur de l'objet author
  int get numero => prestataire_info['numero']; // Accès à nomprenom à l'intérieur de l'objet author
  String get username => prestataire_info['username']; // Accès à nomprenom à l'intérieur de l'objet author
  String get email => prestataire_info['email']; // Accès à nomprenom à l'intérieur de l'objet author
  // int get distance => prestataire_info['distance']; // Accès à nomprenom à l'intérieur de l'objet author
  String get domaineactivite => prestataire_info['domaineactivite']; // Accès à nomprenom à l'intérieur de l'objet author
  String get photoProfil=> prestataire_info['photoProfil']; // Accès à nomprenom à l'intérieur de l'objet author
  bool get prestataire => prestataire_info['prestataire']; // Accès à nomprenom à l'intérieur de l'objet author
  String get nomcommercial => prestataire_info['nomcommercial']; // Accès à nomprenom à l'intérieur de l'objet author
  Map<String, dynamic> get location => prestataire_info['location']; // Accès à nomprenom à l'intérieur de l'objet author

}



class Publicites {
  final String id;
  final String? imagepublier;

  Publicites(this.id, this.imagepublier);
}

enum SelectedItem { None, Electricien, Garagiste, Plombier, Mecanicien, Menuiserie, Jardinage, Rparationlectronique, 
 Dmnagement, Informatique, Serrurerie, FroidetClimatisation, Carrelage, Tlphoneetordinateur, Freelance, Livreur, Autres, SomeOtherItem }

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  TextEditingController searchTermController = TextEditingController();
  
  SelectedItem _selectedItem = SelectedItem.None; // Initial state
  bool isLoading = true;
  List<Prestataire> prestataires = [];
  List<PrestatairesAverage> prestatairesAverages = [];
  // List<PrestataireRechercher> prestatairesRechercher = [];
  late Future<List<Publicites>> publicitesFuture; // Déclaration de la variable

  int selectedElementIndex = -1; // Initialisez avec une valeur qui n'existe pas

  // ::::
  List<Metier> metiers = [];

  Future<List<PrestatairesAverage>> fetchPrestatairesAverage() async {
    setState(() {
      isLoading = true; // Afficher le chargement
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final apiUrl = 'https://ocean-52xt.onrender.com/myrating/ratings/superieur/egale/quatre';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final fetchedPrestatairesAverage = data
            .map((item) => PrestatairesAverage(
                  item['_id'] as String,
                  (item['averageRating'] as num).toDouble(),
                  item['prestataire_info'] as Map<String, dynamic>,
                ))
            .toList();

        setState(() {
          isLoading = false; // Cacher le chargement
          prestatairesAverages = fetchedPrestatairesAverage;
        });

        return fetchedPrestatairesAverage;
      } else {
        print('Erreur lors de la récupération des données. fetchPrestatairesAverage(). Code : ${response.statusCode}');
        // Ajoutez ici la logique pour informer l'utilisateur de l'erreur ou effectuer d'autres actions nécessaires.

        // Renvoyer une liste vide en cas d'erreur
        return [];
      }
    } catch (error) {
      print('Erreur lors de la requête HTTP : $error');
      // Ajoutez ici la logique pour informer l'utilisateur de l'erreur ou effectuer d'autres actions nécessaires.

      // Renvoyer une liste vide en cas d'erreur
      return [];
    }
  }


Future<List<Metier>> fetchData() async {
  try {
    if (!mounted) {
      // Vérifier si le widget est toujours monté
      return [];
    }

    setState(() {
      isLoading = true; // Afficher le chargement
    });

    final response = await http.get(Uri.parse('https://ocean-52xt.onrender.com/domaineActivite'));

    if (!mounted) {
      // Vérifier à nouveau après l'appel réseau
      return [];
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final fetchedmetiers = data
          .map((item) => Metier(
                item['_id'] as String,
                item['domaineactivite'] as String,
              ))
          .toList();

      setState(() {
        isLoading = false; // Cacher le chargement
        metiers = fetchedmetiers;
      });

      return fetchedmetiers;
    } else {
      throw Exception('Failed to fetch data from MongoDB');
    }
  } catch (error) {
    print('Error fetching data: $error');
    if (mounted) {
      // Vérifier si le widget est toujours monté avant d'appeler setState
      setState(() {
        isLoading = false; // Cacher le chargement en cas d'erreur
      });
    }
    return []; // Retourner une liste vide en cas d'erreur
  }
}



    Future<void> fetchPrestataires(String type) async {
    setState(() {
      isLoading = true; // Afficher le chargement
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final apiUrl =
          'https://ocean-52xt.onrender.com/users/prestataires/$type?lat=${position.latitude}&lng=${position.longitude}';
      print("Je veux voir l'url.......................... : $apiUrl");
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print(
            "Voici les résultats obtenus ::::::::::::::::::::::::::::::::::::::::::::::: $data");
        final fetchedPrestataires = data
            .map((item) => Prestataire(
                  item['_id'] as String,
                  item['nomprenom'] as String,
                  item['email'] as String,
                  item['downloadUrl'] != null ? item['downloadUrl'] as String : "",
                  item['prestataire'] as bool,
                  item['username'] as String,
                  item['location'] as Map<String, dynamic>,
                  item['domaineactivite'] as String,
                  item['distance'] as int,
                  item['nomcommercial'] as String,
                  item['numero'] as int,
                  item['photoProfil'] as String,
                  // item['rating'] as int,
                ))
            .toList();

        setState(() {
          isLoading = false; // Cacher le chargement
          prestataires = fetchedPrestataires;
        });

        return;
      } else {
        print('Erreur lors de la récupération des données fetchPrestataires(String type). Code : ${response.statusCode}');
        // Ajoutez ici la logique pour informer l'utilisateur de l'erreur ou effectuer d'autres actions nécessaires.
      }
    } catch (error) {
      print('Erreur lors de la requête HTTP : $error');
      // Ajoutez ici la logique pour informer l'utilisateur de l'erreur ou effectuer d'autres actions nécessaires.
    }
  }


  Future<List<Publicites>> fetchPublicites() async {
    final apiUrl = 'https://ocean-52xt.onrender.com/publier';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        print(data);
        // var convert = data.imagepublier;
        final fetchedPublicites = data
            .map((item) => Publicites(
                  item['_id'] as String,
                  item['imagepublier'] != null ? item['imagepublier'] as String : "",
                ))
            .toList();

        return fetchedPublicites;
      } else {
        print('Erreur lors de la récupération des données. fetchPublicites()');
        return [];
      }
    } catch (error) {
      print('Erreur lors de la requête HTTP : $error');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    // _ratingController = TextEditingController(text: '3.0');
    // _rating = _initialRating;
    selectedElementIndex = -1; // Initialisez-le avec la première valeur d'index ou toute autre valeur appropriée
    _selectedItem = SelectedItem.None; // Initialisez avec la valeur par défaut
    publicitesFuture = fetchPublicites();
    fetchData();
    fetchPrestatairesAverage();
    fetchData().then((fetchedmetiers) {
      setState(() {
        metiers = fetchedmetiers;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedItem != SelectedItem.None) {
          setState(() {
            _selectedItem = SelectedItem.None;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: _vsearch(),
            ),
            // const SizedBox(height: 8,),
            _plusconsommes(),
            const SizedBox(height: 12,),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(color: Colors.white),
                child: _selectedItem == SelectedItem.None ? _mainContent() : _alternateContent()
              )
            ),
          ],
        )
      ),
    );
  }


  Widget _mainContent() {
    return Center(
      child: Column(
        children: [
          FutureBuilder<List<Publicites>>(
            future: publicitesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Erreur lors du chargement des publicités');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Espace pub"));
              } else {
                return CarouselSlider.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index, realIndex) {
                    final base64Image = snapshot.data![index].imagepublier;
                    final imageWidget = decodeBase64ToImage(base64Image!);

                    return Container(
                      margin: const EdgeInsets.only(top: 15),
                      height: MediaQuery.of(context).size.height * 0.23,
                      width: MediaQuery.of(context).size.width * 0.90,
                      decoration: const BoxDecoration(color: Colors.grey),
                      child: imageWidget,
                    );
                  },
                  options: CarouselOptions(
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.9,
                  ),
                );

                // return CarouselSlider.builder(
                //   itemCount: snapshot.data!.length,
                //   itemBuilder: (context, index, realIndex) {
                //     final imageUrl = snapshot.data![index].imagepublier;
                //     return Container(
                //       margin: const EdgeInsets.only(top: 15),
                //       height: MediaQuery.of(context).size.height * 0.23,
                //       width: MediaQuery.of(context).size.width * 0.90,
                //       decoration: const BoxDecoration(color: Colors.grey),
                //       child: CachedNetworkImage(
                //         imageUrl: imageUrl!,
                //         placeholder: (context, imageUrl) =>
                //             const CircularProgressIndicator(),
                //         errorWidget: (context, imageUrl, error) =>
                //             const Icon(Icons.error),
                //         fit: BoxFit.cover,
                //       ),
                //     );
                //   },
                //   options: CarouselOptions(
                //     autoPlay: true,
                //     aspectRatio: 16 / 9, // Ajustez la proportion comme nécessaire
                //     viewportFraction: 0.9, // Ajustez la fraction de l'écran visible comme nécessaire
                //   ),
                // );
              }
            },
          ),
          const SizedBox(height: 50,),
          const SizedBox(child: Text("Recommandations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
          // const SizedBox(height: 20,),
          Expanded(
            child: _alternateContent1(),
            
          ),
        ],
      ),
    );
  }

  Widget _plusconsommes() {
    return isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: BorderSide.strokeAlignInside,)) 
    :  Container(
      height: MediaQuery.of(context).size.height * 0.08,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(color: Colors.blue),
      child: ListView.builder(
        // padding: EdgeInsets.only(left: 50),
        itemExtent: MediaQuery.of(context).size.width * 0.3, // Largeur fixe de chaque élément
        scrollDirection: Axis.horizontal,
        itemCount: metiers.length,
        itemBuilder: (context, index) {
          final e = metiers[index];
          // bool isSelected = index == selectedElementIndex;
          bool isSelected = index == selectedElementIndex && selectedElementIndex != -1;
          return InkWell(
            onTap: () {
              fetchPrestataires(e.domaineactivite).then((_) {
                setState(() {
                  selectedElementIndex = index;
                  metiers = metiers.where((prestataire) =>
                      metiers[selectedElementIndex].domaineactivite ==
                      e.domaineactivite).toList();
                });
              });
              _selectedItem = SelectedItem.SomeOtherItem;
            },
            child: Center(
              child: Container(
                alignment: Alignment.center, // Centre verticalement
                height: MediaQuery.of(context).size.height * 0.08,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueGrey : Colors.blue, // Changer la couleur en fonction de la sélection
                ),
                child: Text(e.domaineactivite, 
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _alternateContent1() {
      return isLoading ? const Text("En cors de chargement..."):
        prestatairesAverages.isEmpty 
          ? const Center(child: Text("Il n'y a pas de prestataire à vous recommander pour le moment. On vous conseil de faire la recherche de votre prestataire.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18),)) 
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
                itemCount: prestatairesAverages.length,
                itemBuilder: (context, index) {
                  final prestataire = prestatairesAverages[index];
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
                                    imageUrl: prestataire.photoProfil,
                                    // imageUrl: prestataire.photoProfil ?? '',
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
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Column(
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(child: Text(prestataire.nomprenom)),
                                              const Expanded(child: Text("")),
                                              Expanded(child: Text("${prestataire.domaineactivite}")),
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
                                                    Text("${prestataire.nomcommercial}"), 
                                                  ],
                                                ),
                                              ),
                                              const Expanded(
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.directions_walk),
                                                    SizedBox(width: 3,),
                                                    // Text("${prestataire.distance} m")
                                                    // Text("data"),
                                                    SizedBox(width: 3,),
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

    Widget _alternateContent() {
      if (selectedElementIndex < 0 || selectedElementIndex >= metiers.length) {
        // Si selectedElementIndex est en dehors de la plage valide, affichez un message d'erreur.
        return const Center(
          child: Text(
            // "Sélection d'élément invalide.",
            "Chargement en cours ...",
            style: TextStyle(fontSize: 15),
          ),
        );
      }

      return prestataires.isEmpty 
          ? Center(child: Text("Il n'y a pas de ${metiers[selectedElementIndex].domaineactivite} dans\nla zone pour le moment.", style: const TextStyle(fontSize: 15),)) 
        : Column(
          children: [
            Center(
              child: Text(
                "${metiers[selectedElementIndex].domaineactivite}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: prestataires.length,
                itemBuilder: (context, index) {
                  final prestataire = prestataires[index];
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
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child: Text(prestataire.nomprenom)),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // Naviguer vers la page de la carte en passant les coordonnées du prestataire
                                                  final coordinates = prestataire.location['coordinates'];
                                                  final latitude = coordinates[1]; // Latitude
                                                  final longitude = coordinates[0]; // Longitude
                                            
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) => CartePageMap(
                                                        latitude: latitude,
                                                        longitude: longitude,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Icon(Icons.map),
                                              ),
                                            )
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
                                                  Text("${prestataire.nomcommercial}"), 
                                                  // Text("${prestataire.numero.toString()}"), 
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.directions_walk),
                                                  const SizedBox(width: 3,),
                                                  Text("${prestataire.distance} m"),
                                                  const SizedBox(width: 3,),
                                                  const Icon(Icons.location_on_outlined),
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


  Widget _vsearch() {
    // late searchTerm; // Le terme de recherche saisi par l'utilisateur

    return Container(
      margin: const EdgeInsets.all(15),
      child: CupertinoTextField(
        controller: searchTermController,
        padding: const EdgeInsets.all(13),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: InkWell(
            onTap: () {
              String enteredText = searchTermController.text;
              print("Valeur entrée par l'utilisateur : $enteredText");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SeachePage(searchTerm: "$enteredText",))
              );
          },
            child: const Icon(Icons.search),
          ),
        ),
        placeholder: "Rechercher un prestataire",
        onChanged: (searchTerm) {
          // Mettez à jour le terme de recherche à mesure que l'utilisateur tape
          setState(() {
            searchTermController.text = searchTerm;
          });
        },
        onSubmitted: (searchTerm) {
          print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + searchTerm);
          // Effectuez la recherche lorsque l'utilisateur appuie sur "Rechercher" dans le clavier
          // _performSearch(context, searchTerm);
        },
        decoration: BoxDecoration(
          border: Border.all(color: Colors.greenAccent),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
      ),
    );
  }
}