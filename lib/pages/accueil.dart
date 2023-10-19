// ignore_for_file: unnecessary_string_interpolations, avoid_print, constant_identifier_names, unnecessary_brace_in_string_interps, prefer_const_declarations

import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ocean/modeles/modelePrestataire.dart';
import 'package:ocean/pages/carte_page_map.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';


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
  final int distance;
  final String domaineactivite;
  final Map<String, dynamic> location;
  // final int rating; // Nouvelle propriété pour stocker la notation du prestataire


  Prestataire(this.id, this.nomprenom, this.email, this.downloadUrl, this.prestataire, this.username, this.location, this.domaineactivite, this.distance, this.nomcommercial, this.numero,
  //  this.rating
  );
}


class Publicites {
  final String id;
  final String? imagepublier;

  Publicites(this.id, this.imagepublier);
}

enum SelectedItem { None, Electricien, Garagiste, Plombier, Mecanicien, SomeOtherItem }

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  SelectedItem _selectedItem = SelectedItem.None; // Initial state
  bool isLoading = true;
  List<Prestataire> prestataires = [];
  late Future<List<Publicites>> publicitesFuture; // Déclaration de la variable

  int selectedElementIndex = -1; // Initialisez avec une valeur qui n'existe pas

  // ::::
  List<Metier> metiers = [];
  // bool isLoading = true;

  Future<List<Metier>> fetchData() async {
    setState(() {
      isLoading = true; // Afficher le chargement
    });

    final response = await http.get(Uri.parse('http://192.168.31.206:3000/domaineActivite/'));

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
  }

  // ::::::::::

  Future<void> fetchPrestataires(String type) async {
    setState(() {
      isLoading = true; // Afficher le chargement
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final apiUrl = 'http://192.168.31.206:3000/users/prestataires/$type?lat=${position.latitude}&lng=${position.longitude}';
      print("Je veux voir l'url.......................... : ${apiUrl}");
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        print("Voici les résultats obtenus ::::::::::::::::::::::::::::::::::::::::::::::: ${data}");
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
                // item['rating'] as int,
              ))
          .toList();

        setState(() {
          isLoading = false; // Cacher le chargement
          prestataires = fetchedPrestataires;
        });

        return;
      } else {
        print('Erreur lors de la récupération des données');
      }
    } catch (error) {
      print('Erreur lors de la requête HTTP : $error');
    }
  }


  Future<List<Publicites>> fetchPublicites() async {
    final apiUrl = 'http://192.168.31.206:3000/publier';

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
        print('Erreur lors de la récupération des données');
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
            const SizedBox(height: 8,),
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
    return Column(
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
                  final imageUrl = snapshot.data![index].imagepublier;
                  return Container(
                    margin: const EdgeInsets.only(top: 15),
                    height: MediaQuery.of(context).size.height * 0.23,
                    width: MediaQuery.of(context).size.width * 0.90,
                    decoration: const BoxDecoration(color: Colors.grey),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl!,
                      placeholder: (context, imageUrl) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, imageUrl, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  );
                },
                options: CarouselOptions(
                  autoPlay: true,
                  aspectRatio: 16 / 9, // Ajustez la proportion comme nécessaire
                  viewportFraction: 0.9, // Ajustez la fraction de l'écran visible comme nécessaire
                ),
              );
            }
          },
        ),
        const SizedBox(height: 20,),
        const SizedBox(child: Text("Recommandations")),
        const SizedBox(height: 20,),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            children: List.generate(100, (index) {
              return Center(
                child: Container(
                  decoration: const BoxDecoration(color: Colors.grey),
                  child: Padding(
                    padding: const EdgeInsets.all(52.0),
                    child: Text(
                      'Item $index',
                      // style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ModelePrestataire(nomprenom: prestataire.nomprenom, email: prestataire.email, prestataire: prestataire.prestataire, 
                                  id: prestataire.id, domaineactivite: prestataire.domaineactivite, nomcommercial: prestataire.nomcommercial, latitude: prestataire.location['coordinates'][1], 
                                  longitude: prestataire.location['coordinates'][0], numero: prestataire.numero,),
                              ),
                          );
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
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Icon(Icons.person_2),
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
                                                  const Icon(Icons.location_on_outlined),
                                                  const SizedBox(width: 3,),
                                                  Text(prestataire.username)
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.done_outline_sharp),
                                                  const SizedBox(width: 3,),
                                                  Text("${prestataire.distance} m")
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        const Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Icon(Icons.contact_phone_outlined),
                                                  SizedBox(width: 3,),
                                                  Text("0585649579")
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Icon(Icons.star_rate_outlined),
                                                  SizedBox(width: 3,),
                                                  // Text("Notes")
                                                  // Text("Rating: ${prestataire.rating}"),
                                                  
                                                ],
                                              ),
                                            ),
                                            
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
    return Container(
      margin: const EdgeInsets.all(15),
      child: CupertinoTextField(
        padding: const EdgeInsets.all(13),
        prefix: const Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: Icon(Icons.search),
        ),
        placeholder: "Rechercher un prestataire",
        decoration: BoxDecoration(
          border: Border.all(color: Colors.greenAccent),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
      ),
    );
  }

}





  //   Widget _ratingBar() {
  //     return RatingBar.builder(
  //           initialRating: _initialRating,
  //           direction: _isVertical ? Axis.vertical : Axis.horizontal,
  //           itemCount: 5,
  //           itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
  //           itemBuilder: (context, index) {
  //             switch (index) {
  //               case 0:
  //                 return Icon(
  //                   Icons.sentiment_very_dissatisfied,
  //                   color: Colors.red,
  //                   size: 2,
  //                 );
  //               case 1:
  //                 return Icon(
  //                   Icons.sentiment_dissatisfied,
  //                   color: Colors.redAccent,
  //                 );
  //               case 2:
  //                 return Icon(
  //                   Icons.sentiment_neutral,
  //                   color: Colors.amber,
  //                 );
  //               case 3:
  //                 return Icon(
  //                   Icons.sentiment_satisfied,
  //                   color: Colors.lightGreen,
  //                 );
  //               case 4:
  //                 return Icon(
  //                   Icons.sentiment_very_satisfied,
  //                   color: Colors.green,
  //                 );
  //               default:
  //                 return Container();
  //             }
  //           },
  //           onRatingUpdate: (rating) {
  //             setState(() {
  //               _rating = rating;
  //             });
  //           },
  //           updateOnDrag: true,
  //         );
  // }

  

  //   Widget _ratingBar() {
  //   switch (mode) {
  //     case 1:
  //       return RatingBar.builder(
  //         initialRating: _initialRating,
  //         minRating: 1,
  //         direction: _isVertical ? Axis.vertical : Axis.horizontal,
  //         allowHalfRating: true,
  //         unratedColor: Colors.amber.withAlpha(50),
  //         itemCount: 5,
  //         itemSize: 50.0,
  //         itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
  //         itemBuilder: (context, _) => Icon(
  //           _selectedIcon ?? Icons.star,
  //           color: Colors.amber,
  //         ),
  //         onRatingUpdate: (rating) {
  //           setState(() {
  //             _rating = rating;
  //           });
  //         },
  //         updateOnDrag: true,
  //       );
  //     case 2:
  //       return RatingBar(
  //         initialRating: _initialRating,
  //         direction: _isVertical ? Axis.vertical : Axis.horizontal,
  //         allowHalfRating: true,
  //         itemCount: 5,
  //         ratingWidget: RatingWidget(
  //           full: _image('assets/heart.png'),
  //           half: _image('assets/heart_half.png'),
  //           empty: _image('assets/heart_border.png'),
  //         ),
  //         itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
  //         onRatingUpdate: (rating) {
  //           setState(() {
  //             _rating = rating;
  //           });
  //         },
  //         updateOnDrag: true,
  //       );
  //     case 3:
  //       return RatingBar.builder(
  //         initialRating: _initialRating,
  //         direction: _isVertical ? Axis.vertical : Axis.horizontal,
  //         itemCount: 5,
  //         itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
  //         itemBuilder: (context, index) {
  //           switch (index) {
  //             case 0:
  //               return Icon(
  //                 Icons.sentiment_very_dissatisfied,
  //                 color: Colors.red,
  //               );
  //             case 1:
  //               return Icon(
  //                 Icons.sentiment_dissatisfied,
  //                 color: Colors.redAccent,
  //               );
  //             case 2:
  //               return Icon(
  //                 Icons.sentiment_neutral,
  //                 color: Colors.amber,
  //               );
  //             case 3:
  //               return Icon(
  //                 Icons.sentiment_satisfied,
  //                 color: Colors.lightGreen,
  //               );
  //             case 4:
  //               return Icon(
  //                 Icons.sentiment_very_satisfied,
  //                 color: Colors.green,
  //               );
  //             default:
  //               return Container();
  //           }
  //         },
  //         onRatingUpdate: (rating) {
  //           setState(() {
  //             _rating = rating;
  //           });
  //         },
  //         updateOnDrag: true,
  //       );
  //     default:
  //       return Container();
  //   }
  // }

  // Widget _image(String asset) {
  //   return Image.asset(
  //     asset,
  //     height: 30.0,
  //     width: 30.0,
  //     color: Colors.amber,
  //   );
  // }