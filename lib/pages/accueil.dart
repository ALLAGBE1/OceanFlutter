// ignore_for_file: unnecessary_string_interpolations, avoid_print, constant_identifier_names

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Prestataire {
  final String id;
  final String nomprenom;
  final String email;
  final String? downloadUrl;
  final bool prestataire;
  final String username;

  Prestataire(this.id, this.nomprenom, this.email, this.downloadUrl, this.prestataire, this.username);
}

class Publicites {
  final String id;
  final String? imagepublier;

  Publicites(this.id, this.imagepublier);
}

enum SelectedItem { None, Electricien, Garagiste, Plombier, Mecanicien }

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

  // Future<List<Prestataire>> fetchPrestataires(String type) async {
  Future<void> fetchPrestataires(String type) async {
    setState(() {
      isLoading = true; // Afficher le chargement
    });

    final apiUrl = 'http://192.168.1.13:3000/users/prestataires/$type';
  
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Traitez les données reçues dans response.body
        final data = jsonDecode(response.body) as List<dynamic>;
        print(data);
        final fetchedPrestataires = data
          .map((item) => Prestataire(
                item['_id'] as String,
                item['nomprenom'] as String,
                item['email'] as String,
                item['downloadUrl'] != null ? item['downloadUrl'] as String : "",  // Ajoutez ceci
                item['prestataire'] as bool,
                item['username'] as String,
              ))
          .toList();


        setState(() {
          isLoading = false; // Cacher le chargement
          prestataires = fetchedPrestataires;
        });

        return ;
      } else {
        print('Erreur lors de la récupération des données');
      }
    } catch (error) {
      print('Erreur lors de la requête HTTP : $error');
    }
  }

  Future<List<Publicites>> fetchPublicites() async {
    final apiUrl = 'http://192.168.1.13:3000/publier';

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
    publicitesFuture = fetchPublicites();
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
        // FutureBuilder<List<Publicites>>(
        //   future: publicitesFuture,
          
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const CircularProgressIndicator();
        //     } else if (snapshot.hasError) {
        //       return const Text('Erreur lors du chargement des publicités');
        //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        //       return const Center(child: Text("Espace pub"));
        //     } else {
        //       return Container(
        //         margin: const EdgeInsets.only(top: 15),
        //         height: MediaQuery.of(context).size.height * 0.23,
        //         width: MediaQuery.of(context).size.width * 0.90,
        //         decoration: const BoxDecoration(color: Colors.grey),
        //         // child: Image.network(snapshot.data![0].imagepublier!),
        //         child: CachedNetworkImage(
        //           imageUrl: snapshot.data![0].imagepublier!,
        //           placeholder: (context, imageUrl) => const CircularProgressIndicator(), // Afficher un indicateur de chargement en attendant
        //           errorWidget: (context, imageUrl, error) => const Icon(Icons.error), // En cas d'erreur de chargement
        //           fit: BoxFit.cover
        //         ),
        //       );
        //     }
            
        //   },
        // ),
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
        Container(child: const Text("Recommandations")),
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
                      style: Theme.of(context).textTheme.headline5,
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

  Widget _contentElectricien() {
    return isLoading
          ? const Center(child: CircularProgressIndicator()) 
      : prestataires.isEmpty 
        ? const Center(child: Text("Il n'y a pas d'électriciens dans\nla zone pour le moment.", style: TextStyle(fontSize: 15),))
        :  ListView.builder(
            itemCount: prestataires.length,
            itemBuilder: (context, index) {
              var prestataire = prestataires[index];
              return Column(
                children: [
                  const Text("Électriciens"),
                  const Divider(height: 8,),
                  InkWell(
                    onTap: () {
                      // Gérer ce que vous voulez faire lorsque l'utilisateur clique sur un prestataire
                      print("Bonjour");
                    },
                    child: Container(
                      height: 80,
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
                          Expanded(child: Column(
                            children: [
                              Column(
                                children: [
                                  Text(prestataire.nomprenom)
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Row(children: [
                                        const Icon(Icons.location_on_outlined),
                                        const SizedBox(width: 3,),
                                        Text(prestataire.username)
                                      ],)),
                                      // SizedBox(width: 3,),
                                      Expanded(child: Row(children: [
                                        const Icon(Icons.done_outline_sharp),
                                        const SizedBox(width: 3,),
                                        Text(prestataire.username)
                                      ],)),
                                    ],
                                  ),
                                  const Row(
                                    children: [
                                      Expanded(child: Row(children: [
                                        Icon(Icons.contact_phone_outlined),
                                        SizedBox(width: 3,),
                                        Text("0585649579")
                                      ],)),
                                      // SizedBox(width: 3,),
                                      Expanded(child: Row(children: [
                                        Icon(Icons.star_rate_outlined),
                                        SizedBox(width: 3,),
                                        Text("Notes")
                                      ],)),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ))
                        
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 8,),
                ],
              );
          },
    );
  }

  Widget _contentGaragiste() {
    return isLoading
          ? const Center(child: CircularProgressIndicator()) 
      : prestataires.isEmpty 
        ? const Center(child: Text("Il n'y a pas de garagiste dans\nla zone pour le moment.", style: TextStyle(fontSize: 15),))
        :  ListView.builder(
            itemCount: prestataires.length,
            itemBuilder: (context, index) {
              var prestataire = prestataires[index];
              return Column(
                children: [
                  const Text("Garagiste"),
                  const Divider(height: 8,),
                  InkWell(
                    onTap: () {
                      // Gérer ce que vous voulez faire lorsque l'utilisateur clique sur un prestataire
                      print("Bonjour");
                    },
                    child: Container(
                      height: 80,
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
                          Expanded(child: Column(
                            children: [
                              Column(
                                children: [
                                  Text(prestataire.nomprenom)
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Row(children: [
                                        const Icon(Icons.location_on_outlined),
                                        const SizedBox(width: 3,),
                                        Text(prestataire.username)
                                      ],)),
                                      // SizedBox(width: 3,),
                                      Expanded(child: Row(children: [
                                        const Icon(Icons.done_outline_sharp),
                                        const SizedBox(width: 3,),
                                        Text(prestataire.username)
                                      ],)),
                                    ],
                                  ),
                                  const Row(
                                    children: [
                                      Expanded(child: Row(children: [
                                        Icon(Icons.contact_phone_outlined),
                                        SizedBox(width: 3,),
                                        Text("0585649579")
                                      ],)),
                                      // SizedBox(width: 3,),
                                      Expanded(child: Row(children: [
                                        Icon(Icons.star_rate_outlined),
                                        SizedBox(width: 3,),
                                        Text("Notes")
                                      ],)),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ))
                        
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 8,),
                ],
              );
          },
    );
  }

  Widget _contentPlombier() {
    return isLoading
          ? const Center(child: CircularProgressIndicator()) 
      : prestataires.isEmpty 
        ? const Center(child: Text("Il n'y a pas de plombier dans\nla zone pour le moment.", style: TextStyle(fontSize: 15),))
        :  Column(
          children: [
            const Text("Plombier"),
            Expanded(
              child: ListView.builder(
                  itemCount: prestataires.length,
                  itemBuilder: (context, index) {
                    var prestataire = prestataires[index];
                    return Column(
                      children: [
                        // const Text("Plombier"),
                        const Divider(height: 8,),
                        InkWell(
                          onTap: () {
                            // Gérer ce que vous voulez faire lorsque l'utilisateur clique sur un prestataire
                            print("Bonjour");
                          
                          },
                          child: Container(
                            height: 80,
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
                                Expanded(child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        Text(prestataire.nomprenom)
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child: Row(children: [
                                              const Icon(Icons.location_on_outlined),
                                              const SizedBox(width: 3,),
                                              Text(prestataire.username)
                                            ],)),
                                            // SizedBox(width: 3,),
                                            Expanded(child: Row(children: [
                                              const Icon(Icons.done_outline_sharp),
                                              const SizedBox(width: 3,),
                                              Text(prestataire.username)
                                            ],)),
                                          ],
                                        ),
                                        const Row(
                                          children: [
                                            Expanded(child: Row(children: [
                                              Icon(Icons.contact_phone_outlined),
                                              SizedBox(width: 3,),
                                              Text("0585649579")
                                            ],)),
                                            // SizedBox(width: 3,),
                                            Expanded(child: Row(children: [
                                              Icon(Icons.star_rate_outlined),
                                              SizedBox(width: 3,),
                                              Text("Notes")
                                            ],)),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ))
                              
                              ],
                            ),
                          ),
                        ),
                        // const Divider(height: 8,),
                      ],
                    );
                },
                ),
            ),
          ],
        );
  }

  Widget _contentMecanicien() {
    return isLoading
          ? const Center(child: CircularProgressIndicator()) 
      : prestataires.isEmpty 
        ? const Center(child: Text("Il n'y a pas de mécanicien dans\nla zone pour le moment.", style: TextStyle(fontSize: 15),))
        :  ListView.builder(
            itemCount: prestataires.length,
            itemBuilder: (context, index) {
              var prestataire = prestataires[index];
              return Column(
                children: [
                  const Text("Mécanicien"),
                  const Divider(height: 8,),
                  InkWell(
                    onTap: () {
                      // Gérer ce que vous voulez faire lorsque l'utilisateur clique sur un prestataire
                      print("Bonjour");
                    },
                    child: Container(
                      height: 80,
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
                          Expanded(child: Column(
                            children: [
                              Column(
                                children: [
                                  Text(prestataire.nomprenom)
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Row(children: [
                                        const Icon(Icons.location_on_outlined),
                                        const SizedBox(width: 3,),
                                        Text(prestataire.username)
                                      ],)),
                                      // SizedBox(width: 3,),
                                      Expanded(child: Row(children: [
                                        const Icon(Icons.done_outline_sharp),
                                        const SizedBox(width: 3,),
                                        Text(prestataire.username)
                                      ],)),
                                    ],
                                  ),
                                  const Row(
                                    children: [
                                      Expanded(child: Row(children: [
                                        Icon(Icons.contact_phone_outlined),
                                        SizedBox(width: 3,),
                                        Text("0585649579")
                                      ],)),
                                      // SizedBox(width: 3,),
                                      Expanded(child: Row(children: [
                                        Icon(Icons.star_rate_outlined),
                                        SizedBox(width: 3,),
                                        Text("Notes")
                                      ],)),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ))
                        
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 8,),
                ],
              );
          },
    );
  }


  Widget _alternateContent() {
    switch (_selectedItem) {
      case SelectedItem.Electricien:
        return _contentElectricien();
      case SelectedItem.Garagiste:
        return _contentGaragiste();
      case SelectedItem.Plombier:
        return _contentPlombier();
      case SelectedItem.Mecanicien:
        return _contentMecanicien();
      default:
        return const Center(child: Text("Erreur de contenu"));
    }
  }

  Widget _plusconsommes() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(color: Colors.blue),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _menuItem("Électricien", SelectedItem.Electricien),
          const SizedBox(width: 3,),
          _menuItem("Garagiste", SelectedItem.Garagiste),
          const SizedBox(width: 3,),
          _menuItem("Plombier", SelectedItem.Plombier),
          const SizedBox(width: 3,),
          _menuItem("Mécanicien", SelectedItem.Mecanicien),
        ],
      ),
    );
  }


  Widget _menuItem(String title, SelectedItem item) {
    Color backgroundColor = Colors.blueAccent;
    if (_selectedItem == item) {
      backgroundColor = Colors.blueGrey;
    }

    return InkWell(
      onTap: () async {
        setState(() {
          _selectedItem = item;
        });
        await fetchPrestataires(getItemType(item));
      },
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: backgroundColor,
          ),
          child: Text(title, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // String getItemType(SelectedItem item) {
  //   switch (item) {
  //     case SelectedItem.Electricien:
  //       return 'Soudeur';
  //     case SelectedItem.Garagiste:
  //       return 'Garagiste';
  //     case SelectedItem.Plombier:
  //       return 'Plombier';
  //     case SelectedItem.Mecanicien:
  //       return 'Mecanicien';
  //     default:
  //       return '';
  //   }
  // }

  String getItemType(SelectedItem item) {
    switch (item) {
      case SelectedItem.Electricien:
        // return 'electricien';
        return 'Électricien';
      case SelectedItem.Garagiste:
        // return 'garagiste';
        return 'Garagiste';
      case SelectedItem.Plombier:
        // return 'plombier';
        return 'Plombier';
      case SelectedItem.Mecanicien:
        // return 'mecanicien';
        return 'Mécanicien';
      default:
        return '';
    }
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

// :::::::::::::::::::::::::::::::::::::
// Widget _mainContent() {
//     return Column(
//       children: [
//         // Container(
//         //   margin: const EdgeInsets.only(top: 15),
//         //   height: MediaQuery.of(context).size.height*0.23,
//         //   width: MediaQuery.of(context).size.width*0.90,
//         //   decoration: const BoxDecoration(color: Colors.grey),
//         //   child: const Center(child: Text("Espace pub")),
//         // ),
//         FutureBuilder<List<Publicites>>(
//           future: publicitesFuture,
          
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const CircularProgressIndicator();
//             } else if (snapshot.hasError) {
//               return const Text('Erreur lors du chargement des publicités');
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Center(child: Text("Espace pub"));
//             } else {
//               // var convert1 = snapshot.data![0].imagepublier!.replaceAll("\\", "/");
//               // print("aaaaaaaaaaaaaaaaaaaaaaaa" + convert1);
//               // var url = "http://192.168.1.13:3000/${convert1}";
//               // var url = "http://192.168.1.13:3000/public/publicites/" + snapshot.data![0].imagepublier!;
//               // var url = "http://192.168.1.13:3000/publier/shawarma-lebanon.jpg";
//               return Container(
//                 margin: const EdgeInsets.only(top: 15),
//                 height: MediaQuery.of(context).size.height * 0.23,
//                 width: MediaQuery.of(context).size.width * 0.90,
//                 decoration: const BoxDecoration(color: Colors.grey),
//                 // child: Image.network(snapshot.data![0].imagepublier!),
//                 // child: Image.network(url, fit: BoxFit.cover),
//                 child: CachedNetworkImage(
//                   // imageUrl: 'http://192.168.1.13:3000/publier/shawarma-lebanon.jpg',
//                   imageUrl: 'snapshot.data![0].imagepublier!',
//                   placeholder: (context, imageUrl) => const CircularProgressIndicator(), // Afficher un indicateur de chargement en attendant
//                   errorWidget: (context, imageUrl, error) => const Icon(Icons.error), // En cas d'erreur de chargement
//                   fit: BoxFit.cover
//                 ),
//               );
//             }
            
//           },
//         ),
//         const SizedBox(height: 20,),
//         Container(child: const Text("Recommandations")),
//         const SizedBox(height: 20,),
//         Expanded(
//           child: GridView.count(
//             crossAxisCount: 2,
//             children: List.generate(100, (index) {
//               return Center(
//                 child: Container(
//                   decoration: const BoxDecoration(color: Colors.grey),
//                   child: Padding(
//                     padding: const EdgeInsets.all(52.0),
//                     child: Text(
//                       'Item $index',
//                       style: Theme.of(context).textTheme.headline5,
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }
// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

// // ignore_for_file: unnecessary_string_interpolations, avoid_print, constant_identifier_names

// import 'dart:convert';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class Prestataire {
//   final String id;
//   final String nomprenom;
//   final String email;
//   final String downloadUrl;
//   final bool prestataire;

//   Prestataire(this.id, this.nomprenom, this.email, this.downloadUrl, this.prestataire);
// }

// enum SelectedItem { None, Electricien, Garagiste, Plombier, Mecanicien }

// class Accueil extends StatefulWidget {
//   const Accueil({super.key});

//   @override
//   State<Accueil> createState() => _AccueilState();
// }

// class _AccueilState extends State<Accueil> {
//   SelectedItem _selectedItem = SelectedItem.None; // Initial state
//   bool isLoading = true;
//   List<Prestataire> prestataires = [];

//   // Future<List<Prestataire>> fetchPrestataires(String type) async {
//   Future<void> fetchPrestataires(String type) async {
//     setState(() {
//       isLoading = true; // Afficher le chargement
//     });

//     final apiUrl = 'http://192.168.1.13:3000/users/prestataires/$type';
//     // final apiUrl = 'http://192.168.1.13:3000/users/prestataires/soudeur';
  
//     try {
//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         // Traitez les données reçues dans response.body
//         final data = jsonDecode(response.body) as List<dynamic>;
//         final fetchedPrestataires = data
//           .map((item) => Prestataire(
//                 item['_id'] as String,
//                 item['nomprenom'] as String,
//                 item['email'] as String,
//                 item['downloadUrl'] as String,  // Ajoutez ceci
//                 item['prestataire'] as bool,
//               ))
//           .toList();


//         setState(() {
//           isLoading = false; // Cacher le chargement
//           prestataires = fetchedPrestataires;
//         });

//         return ;
//       } else {
//         print('Erreur lors de la récupération des données');
//       }
//     } catch (error) {
//       print('Erreur lors de la requête HTTP : $error');
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (_selectedItem != SelectedItem.None) {
//           setState(() {
//             _selectedItem = SelectedItem.None;
//           });
//           return false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 25.0),
//               child: _vsearch(),
//             ),
//             const SizedBox(height: 8,),
//             _plusconsommes(),
//             const SizedBox(height: 12,),
//             Expanded(
//               child: Container(
//                 height: MediaQuery.of(context).size.height,
//                 width: MediaQuery.of(context).size.width,
//                 decoration: const BoxDecoration(color: Colors.white),
//                 child: _selectedItem == SelectedItem.None ? _mainContent() : _alternateContent()
//               )
//             ),
//           ],
//         )
//       ),
//     );
//   }

//   Widget _mainContent() {
//     return Column(
//       children: [
//         Container(
//           margin: const EdgeInsets.only(top: 15),
//           height: MediaQuery.of(context).size.height*0.23,
//           width: MediaQuery.of(context).size.width*0.90,
//           decoration: const BoxDecoration(color: Colors.grey),
//           child: const Center(child: Text("Espace pub")),
//         ),
//         const SizedBox(height: 20,),
//         Container(child: const Text("Recommandations")),
//         const SizedBox(height: 20,),
//         Expanded(
//           child: GridView.count(
//             crossAxisCount: 2,
//             children: List.generate(100, (index) {
//               return Center(
//                 child: Container(
//                   decoration: const BoxDecoration(color: Colors.grey),
//                   child: Padding(
//                     padding: const EdgeInsets.all(52.0),
//                     child: Text(
//                       'Item $index',
//                       style: Theme.of(context).textTheme.headline5,
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _contentElectricien() {
//     return isLoading
//           ? const Center(child: CircularProgressIndicator()) 
//       : ListView.builder(
//       itemCount: prestataires.length,
//       itemBuilder: (context, index) {
//         var prestataire = prestataires[index];
//         return InkWell(
//           onTap: () {
//             // Gérer ce que vous voulez faire lorsque l'utilisateur clique sur un prestataire
//           },
//           child: Container(
//             height: 80,
//             margin: const EdgeInsets.all(4),
//             decoration: const BoxDecoration(
//               color: Colors.grey,
//               borderRadius: BorderRadius.all(
//                 Radius.circular(4),
//               ),
//             ),
//             child: Row(
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.all(20.0),
//                   child: Icon(Icons.person_2),
//                 ),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(prestataire.nomprenom), // Afficher le nom et prénom
//                       const SizedBox(height: 5),
//                       Row(
//                         children: [
//                           const Icon(Icons.location_on_outlined),
//                           const SizedBox(width: 3),
//                           Text(prestataire.email), // Afficher l'email
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           const Icon(Icons.contact_phone_outlined),
//                           const SizedBox(width: 3),
//                           Text(prestataire.email), // Afficher le numéro de téléphone (à modifier)
//                         ],
//                       ),
//                       const Row(
//                         children: [
//                           Icon(Icons.star_rate_outlined),
//                           SizedBox(width: 3),
//                           Text("Notes"), // Ajouter ici la logique pour afficher les notes
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _contentGaragiste() {
//     return ListView(
//       children: [
//         const Text("Garagiste"),
//         const Divider(height: 8,),
//         InkWell(
//           onTap: () async {
//             print("Bonjour !!!!");
//             await fetchPrestataires('garagiste');
//           },
//           child: Container(
//             height: 80,
//             margin: const EdgeInsets.all(4),
//             decoration: const BoxDecoration(
//               color: Colors.grey,
//               // border: Border.all(color: Colors.grey, width: 1.5),
//               borderRadius: BorderRadius.all(
//                 Radius.circular(4),
//               ),
//             ),
//             child: const Row(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(20.0),
//                   child: Icon(Icons.person_2),
//                 ),
//                 Expanded(child: Column(
//                   children: [
//                     Column(
//                       children: [
//                         Text("Yunus graphik")
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(child: Row(children: [
//                               Icon(Icons.location_on_outlined),
//                               SizedBox(width: 3,),
//                               Text("Localisation")
//                             ],)),
//                             // SizedBox(width: 3,),
//                             Expanded(child: Row(children: [
//                               Icon(Icons.done_outline_sharp),
//                               SizedBox(width: 3,),
//                               Text("Disponible oui")
//                             ],)),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             Expanded(child: Row(children: [
//                               Icon(Icons.contact_phone_outlined),
//                               SizedBox(width: 3,),
//                               Text("0585649579")
//                             ],)),
//                             // SizedBox(width: 3,),
//                             Expanded(child: Row(children: [
//                               Icon(Icons.star_rate_outlined),
//                               SizedBox(width: 3,),
//                               Text("Notes")
//                             ],)),
//                           ],
//                         ),
//                       ],
//                     )
//                   ],
//                 ))
//               ],
//             )
//           ),
//         ),
//         const Divider(height: 8,),
//       ],
//     );
//   }

//   Widget _contentPlombier() {
//     return ListView(
//       children: [
//         const Text("Plombier"),
//         const Divider(height: 8,),
//         InkWell(
//           onTap: () async {
//             print("Bonjour !!!!");
//             await fetchPrestataires('plombier');
//           },
//           child: Container(
//             height: 80,
//             margin: const EdgeInsets.all(4),
//             decoration: const BoxDecoration(
//               color: Colors.grey,
//               // border: Border.all(color: Colors.grey, width: 1.5),
//               borderRadius: BorderRadius.all(
//                 Radius.circular(4),
//               ),
//             ),
//             child: const Row(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(20.0),
//                   child: Icon(Icons.person_2),
//                 ),
//                 Expanded(child: Column(
//                   children: [
//                     Column(
//                       children: [
//                         Text("Yunus graphik")
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(child: Row(children: [
//                               Icon(Icons.location_on_outlined),
//                               SizedBox(width: 3,),
//                               Text("Localisation")
//                             ],)),
//                             // SizedBox(width: 3,),
//                             Expanded(child: Row(children: [
//                               Icon(Icons.done_outline_sharp),
//                               SizedBox(width: 3,),
//                               Text("Disponible oui")
//                             ],)),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             Expanded(child: Row(children: [
//                               Icon(Icons.contact_phone_outlined),
//                               SizedBox(width: 3,),
//                               Text("0585649579")
//                             ],)),
//                             // SizedBox(width: 3,),
//                             Expanded(child: Row(children: [
//                               Icon(Icons.star_rate_outlined),
//                               SizedBox(width: 3,),
//                               Text("Notes")
//                             ],)),
//                           ],
//                         ),
//                       ],
//                     )
//                   ],
//                 ))
//               ],
//             )
//           ),
//         ),
//         const Divider(height: 8,),
//       ],
//     );
//   }

//   Widget _contentMecanicien() {
//     return ListView(
//       children: [
//         const Text("Mecanicien"),
//         const Divider(height: 8,),
//         InkWell(
//           onTap: () async {
//             print("Bonjour !!!!");
//             await fetchPrestataires('mecanicien');
//           },
//           child: Container(
//             height: 80,
//             margin: const EdgeInsets.all(4),
//             decoration: const BoxDecoration(
//               color: Colors.grey,
//               // border: Border.all(color: Colors.grey, width: 1.5),
//               borderRadius: BorderRadius.all(
//                 Radius.circular(4),
//               ),
//             ),
//             child: const Row(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(20.0),
//                   child: Icon(Icons.person_2),
//                 ),
//                 Expanded(child: Column(
//                   children: [
//                     Column(
//                       children: [
//                         Text("Yunus graphik")
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(child: Row(children: [
//                               Icon(Icons.location_on_outlined),
//                               SizedBox(width: 3,),
//                               Text("Localisation")
//                             ],)),
//                             // SizedBox(width: 3,),
//                             Expanded(child: Row(children: [
//                               Icon(Icons.done_outline_sharp),
//                               SizedBox(width: 3,),
//                               Text("Disponible oui")
//                             ],)),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             Expanded(child: Row(children: [
//                               Icon(Icons.contact_phone_outlined),
//                               SizedBox(width: 3,),
//                               Text("0585649579")
//                             ],)),
//                             // SizedBox(width: 3,),
//                             Expanded(child: Row(children: [
//                               Icon(Icons.star_rate_outlined),
//                               SizedBox(width: 3,),
//                               Text("Notes")
//                             ],)),
//                           ],
//                         ),
//                       ],
//                     )
//                   ],
//                 ))
//               ],
//             )
//           ),
//         ),
//         const Divider(height: 8,),
//       ],
//     );
//   }


//   Widget _alternateContent() {
//     switch (_selectedItem) {
//       case SelectedItem.Electricien:
//         return _contentElectricien();
//       case SelectedItem.Garagiste:
//         return _contentGaragiste();
//       case SelectedItem.Plombier:
//         return _contentPlombier();
//       case SelectedItem.Mecanicien:
//         return _contentMecanicien();
//       default:
//         return const Center(child: Text("Erreur de contenu"));
//     }
//   }

//   Widget _plusconsommes() {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.08,
//       width: MediaQuery.of(context).size.width,
//       decoration: const BoxDecoration(color: Colors.blue),
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         children: [
//           _menuItem("Electricien", SelectedItem.Electricien),
//           const SizedBox(width: 3,),
//           _menuItem("Garagiste", SelectedItem.Garagiste),
//           const SizedBox(width: 3,),
//           _menuItem("Plombier", SelectedItem.Plombier),
//           const SizedBox(width: 3,),
//           _menuItem("Mécanicien", SelectedItem.Mecanicien),
//         ],
//       ),
//     );
//   }


//   // Widget _plusconsommes(){
//   //   return Container(
//   //     height: MediaQuery.of(context).size.height * 0.08,
//   //     width: MediaQuery.of(context).size.width,
//   //     decoration: const BoxDecoration(color: Colors.blue),
//   //     child: ListView(
//   //       scrollDirection: Axis.horizontal,
//   //       children: [
//   //         InkWell(
//   //           onTap: () async {
//   //             setState(() {
//   //               _selectedItem = SelectedItem.Electricien;
//   //             });
//   //             await fetchPrestataires('soudeur'); // Appel de l'API pour les électriciens
//   //           },
//   //           child: _menuItem("Electricien"),
//   //         ),
//   //         const SizedBox(width: 3,),
//   //         InkWell(
//   //           onTap: (){
//   //             setState(() {
//   //               _selectedItem = SelectedItem.Garagiste;
//   //             });
//   //           },
//   //           child: _menuItem("Garagiste"),
//   //         ),
//   //         const SizedBox(width: 3,),
//   //         InkWell(
//   //           onTap: (){
//   //             setState(() {
//   //               _selectedItem = SelectedItem.Plombier;
//   //             });
//   //           },
//   //           child: _menuItem("Plombier"),
//   //         ),
//   //         const SizedBox(width: 3,),
//   //         InkWell(
//   //           onTap: (){
//   //             setState(() {
//   //               _selectedItem = SelectedItem.Mecanicien;
//   //             });
//   //           },
//   //           child: _menuItem("Mécanicien"),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Widget _menuItem(String title, SelectedItem item) {
//     Color backgroundColor = Colors.blueAccent;
//     if (_selectedItem == item) {
//       backgroundColor = Colors.blueGrey;
//     }

//     return InkWell(
//       onTap: () async {
//         setState(() {
//           _selectedItem = item;
//         });
//         await fetchPrestataires(getItemType(item));
//       },
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             color: backgroundColor,
//           ),
//           child: Text(title, style: TextStyle(color: Colors.white)),
//         ),
//       ),
//     );
//   }

//   String getItemType(SelectedItem item) {
//     switch (item) {
//       case SelectedItem.Electricien:
//         return 'soudeur';
//       case SelectedItem.Garagiste:
//         return 'garagiste';
//       case SelectedItem.Plombier:
//         return 'plombier';
//       case SelectedItem.Mecanicien:
//         return 'mecanicien';
//       default:
//         return '';
//     }
//   }

// //   Widget _menuItem(String title) {
// //     Color backgroundColor = Colors.blueAccent; // Default color
// //     if (title == "Electricien" && _selectedItem == SelectedItem.Electricien) {
// //         backgroundColor = Colors.blueGrey; // Highlight color
// //     } else if(title == "Garagiste" && _selectedItem == SelectedItem.Garagiste) {
// //         backgroundColor = Colors.blueGrey; // Highlight color
// //     } else if(title == "Plombier" && _selectedItem == SelectedItem.Plombier) {
// //         backgroundColor = Colors.blueGrey; // Highlight color
// //     } else if(title == "Mécanicien" && _selectedItem == SelectedItem.Mecanicien) {
// //         backgroundColor = Colors.blueGrey; // Highlight color
// //     }
    

// //     return Center(
// //       child: Container(
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(8),
// //             color: backgroundColor),
// //         child: Text(title, style: TextStyle(color: Colors.white)),
// //       ),
// //     );
// // }


//   Widget _vsearch() {
//     return Container(
//       margin: const EdgeInsets.all(15),
//       child: CupertinoTextField(
//         padding: const EdgeInsets.all(13),
//         prefix: const Padding(
//           padding: EdgeInsets.only(left: 15.0),
//           child: Icon(Icons.search),
//         ),
//         placeholder: "Rechercher un prestataire",
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.greenAccent),
//           borderRadius: BorderRadius.circular(5),
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }


// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


  // Widget _menuItem(String title) {
  //   return Center(
  //     child: Container(
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(8),
  //           color: Colors.blueAccent),
  //       child: Text(title, style: TextStyle(color: Colors.white)),
  //     ),
  //   );
  // }


// ::::::::

// // ignore_for_file: unnecessary_string_interpolations, avoid_print

// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:ocean/pages/canevaRecherche.dart';

// class Accueil extends StatefulWidget {
//   const Accueil({super.key});

//   @override
//   State<Accueil> createState() => _AccueilState();
// }

// class _AccueilState extends State<Accueil> {


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Column(
//         // mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top : 25.0),
//             child: _vsearch(),
//           ),
//           const SizedBox(height: 8,),
//           _plusconsommes(),
//           const SizedBox(height: 12,),
//           Expanded(
//             child: Container(
//               // padding: EdgeInsets.only(bottom: 1),
//               height: MediaQuery.sizeOf(context).height/1,
//               width: MediaQuery.sizeOf(context).width,
//               decoration: const BoxDecoration(
//                 color: Colors.white
//               ),
//               child: Column(
//                 children: [
//                   // const Divider(height: 35,),
//                   // _mesCommandes1(),
//                   Container(
//                     margin: const EdgeInsets.only(top: 15),
//                     height: MediaQuery.sizeOf(context).height*0.23,
//                     width: MediaQuery.sizeOf(context).width*0.90,
//                     decoration: const BoxDecoration(
//                       color: Colors.grey
//                     ),
//                     child: const Center(child: Text("Espace pub")),
//                   ),
//                   const SizedBox(height: 20,),
//                   Container(
//                     child: const Text("Recommandations"),
//                   ),
//                   const SizedBox(height: 20,),
//                   Expanded(
//                     child: GridView.count(
//                       // Create a grid with 2 columns. If you change the scrollDirection to
//                       // horizontal, this produces 2 rows.
//                       crossAxisCount: 2,
//                       // Generate 100 widgets that display their index in the List.
//                       children: List.generate(100, (index) {
//                         return Center(
//                           child: Container(
//                             decoration: const BoxDecoration(
//                               color: Colors.grey
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(52.0),
//                               child: Text(
//                                 'Item $index',
//                                 style: Theme.of(context).textTheme.headlineSmall,
//                               ),
//                             ),
//                           ),
//                         );
//                       }),
//                     ),
//                   ),

//                 ],
//               ),
//             ),
//           ),
          
//         ],
//       ),
//     );
//   }

//   Widget _plusconsommes(){
//     return Container(
//       // backgroundColor: Colors.red,
//       height: MediaQuery.of(context).size.height * 0.08,
//       width: MediaQuery.of(context).size.width,
//       decoration: const BoxDecoration(
//         color: Colors.blue
//         // image: DecorationImage(
//         //   image: AssetImage(("img/banniere.jpg")),
//         //   fit: BoxFit.cover,
//         // ),
//       ),
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         children: [
//           Center(
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                   // border: Border.all(color: Colors.greenAccent),
//                   borderRadius: BorderRadius.circular(8),
//                   color: Colors.blueAccent),
//               child: InkWell(
//                 onTap: (){
//                   print("oui");
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const CanevaRecherche()),
//                   );
//                 },
//                 child: const Text("Electricien", style: TextStyle(
//                   color: Colors.white
//                 ),),
//               )),
//           ), 
//           const SizedBox(width: 3,),
//           Center(
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                   // border: Border.all(color: Colors.greenAccent),
//                   borderRadius: BorderRadius.circular(8),
//                   color: Colors.blueAccent),
//               child: const Text("Garagiste", style: TextStyle(
//                 color: Colors.white
//               ),)),
//           ), 
//           const SizedBox(width: 3,),
//           Center(
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                   // border: Border.all(color: Colors.greenAccent),
//                   borderRadius: BorderRadius.circular(8),
//                   color: Colors.blueAccent),
//               child: const Text("Plombier", style: TextStyle(
//                 color: Colors.white
//               ),)),
//           ), 
//           const SizedBox(width: 3,),
//           Center(
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                   // border: Border.all(color: Colors.greenAccent),
//                   borderRadius: BorderRadius.circular(8),
//                   color: Colors.blueAccent),
//               child: const Text("Légumes", style: TextStyle(
//                 color: Colors.white
//               ),)),
//           ), 
//         ],
//       ),
//     );
// }

//   Widget _vsearch() {
//     return Container(
//       margin: const EdgeInsets.all(15),
//       child: CupertinoTextField(
//         padding: const EdgeInsets.all(13),
//         prefix: const Padding(
//           padding: EdgeInsets.only(left: 15.0),
//           child: Icon(Icons.search),
//         ),
//         // controller: usernameController,
//         placeholder: "Rechercher un prestataire",
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.greenAccent),
//           borderRadius: BorderRadius.circular(5),
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _mesCommandes1() {
//     return Expanded(
//       child: ListView(
//         children: [
//           const Divider(height: 8,),
//           InkWell(
//             onTap: (){
//               print("Bonjour !!!!");
//             },
//             child: Container(
//               height: 80,
//               margin: const EdgeInsets.all(4),
//               decoration: const BoxDecoration(
//                 color: Colors.grey,
//                 // border: Border.all(color: Colors.grey, width: 1.5),
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(4),
//                 ),
//               ),
//               child: const Row(
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(20.0),
//                     child: Icon(Icons.person_2),
//                   ),
//                   Expanded(child: Column(
//                     children: [
//                       Column(
//                         children: [
//                           Text("Yunus graphik")
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.location_on_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("Localisation")
//                               ],)),
//                               // SizedBox(width: 3,),
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.done_outline_sharp),
//                                 SizedBox(width: 3,),
//                                 Text("Disponible oui")
//                               ],)),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.contact_phone_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("0585649579")
//                               ],)),
//                               // SizedBox(width: 3,),
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.star_rate_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("Notes")
//                               ],)),
//                             ],
//                           ),
//                         ],
//                       )
//                     ],
//                   ))
//                 ],
//               )
//             ),
//           ),
//           const Divider(height: 8,),
//         ],
//       ),
//     );
//   }

// }




// :::::

// // ignore_for_file: unnecessary_string_interpolations, avoid_print

// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class Accueil extends StatefulWidget {
//   const Accueil({super.key});

//   @override
//   State<Accueil> createState() => _AccueilState();
// }

// class _AccueilState extends State<Accueil> {


//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: DefaultTabController(
//         length: 5,
//         child: Scaffold(
//           appBar: AppBar(
//             title: _vsearch(),
//             automaticallyImplyLeading: false,
//             bottom: const TabBar(
//               isScrollable: true,
//               tabs: [
//                 Tab(text: "Electricien"),
//                 Tab(text: "Garagiste"),
//                 Tab(text: "Plombier"),
//                 Tab(text: "Soudeur"),
//                 Tab(text: "Mécanicien"),
//               ]
//             ),
//           ),
//           backgroundColor: Colors.transparent,
//           body: TabBarView(
//             children: [
//               Container(color: Colors.white, child: _electricien(),),
//               Container(color: Colors.white, child: _garagiste(),),
//               Container(color: Colors.white, child: _plombier(),),
//               Container(color: Colors.white, child: _soudeur(),),
//               Container(color: Colors.white, child: _mecanicien(),)
//               // Icon(Icons.directions_bike),
//               // Column(
//               //   // mainAxisAlignment: MainAxisAlignment.spaceAround,
//               //   children: [
//               //     Padding(
//               //       padding: const EdgeInsets.only(top : 25.0),
//               //       child: _vsearch(),
//               //     ),
//               //     const SizedBox(height: 8,),
//               //     _plusconsommes(),
//               //     const SizedBox(height: 12,),
//               //     Expanded(
//               //       child: Container(
//               //         // padding: EdgeInsets.only(bottom: 1),
//               //         height: MediaQuery.sizeOf(context).height/1,
//               //         width: MediaQuery.sizeOf(context).width,
//               //         decoration: const BoxDecoration(
//               //           color: Colors.white
//               //         ),
//               //         child: Column(
//               //           children: [
//               //             // const Divider(height: 35,),
//               //             _mesCommandes1(),
//               //           ],
//               //         ),
//               //       ),
//               //     ),
                  
//               //   ],
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

// //   Widget _plusconsommes(){
// //     return Container(
// //       // backgroundColor: Colors.red,
// //       height: MediaQuery.of(context).size.height * 0.08,
// //       width: MediaQuery.of(context).size.width,
// //       decoration: const BoxDecoration(
// //         color: Colors.blue
// //         // image: DecorationImage(
// //         //   image: AssetImage(("img/banniere.jpg")),
// //         //   fit: BoxFit.cover,
// //         // ),
// //       ),
// //       child: ListView(
// //         scrollDirection: Axis.horizontal,
// //         children: [
// //           Center(
// //             child: Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                   // border: Border.all(color: Colors.greenAccent),
// //                   borderRadius: BorderRadius.circular(8),
// //                   color: Colors.blueAccent),
// //               child: const Text("Electricien", style: TextStyle(
// //                 color: Colors.white
// //               ),)),
// //           ), 
// //           const SizedBox(width: 3,),
// //           Center(
// //             child: Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                   // border: Border.all(color: Colors.greenAccent),
// //                   borderRadius: BorderRadius.circular(8),
// //                   color: Colors.blueAccent),
// //               child: const Text("Garagiste", style: TextStyle(
// //                 color: Colors.white
// //               ),)),
// //           ), 
// //           const SizedBox(width: 3,),
// //           Center(
// //             child: Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                   // border: Border.all(color: Colors.greenAccent),
// //                   borderRadius: BorderRadius.circular(8),
// //                   color: Colors.blueAccent),
// //               child: const Text("Plombier", style: TextStyle(
// //                 color: Colors.white
// //               ),)),
// //           ), 
// //           const SizedBox(width: 3,),
// //           Center(
// //             child: Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                   // border: Border.all(color: Colors.greenAccent),
// //                   borderRadius: BorderRadius.circular(8),
// //                   color: Colors.blueAccent),
// //               child: const Text("Légumes", style: TextStyle(
// //                 color: Colors.white
// //               ),)),
// //           ), 
// //         ],
// //       ),
// //     );
// // }

//   Widget _vsearch() {
//     return Container(
//       margin: const EdgeInsets.all(15),
//       child: CupertinoTextField(
//         padding: const EdgeInsets.all(13),
//         prefix: const Padding(
//           padding: EdgeInsets.only(left: 15.0),
//           child: Icon(Icons.search, color: Colors.black,),
//         ),
//         // controller: usernameController,
//         placeholder: "Rechercher un prestataire",
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.greenAccent),
//           borderRadius: BorderRadius.circular(5),
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _electricien() {
//     return Expanded(
//       child: ListView(
//         children: [
//           const Divider(height: 8,),
//           InkWell(
//             onTap: (){
//               print("Bonjour !!!!");
//             },
//             child: Container(
//               height: 80,
//               margin: const EdgeInsets.all(4),
//               decoration: const BoxDecoration(
//                 color: Colors.grey,
//                 // border: Border.all(color: Colors.grey, width: 1.5),
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(4),
//                 ),
//               ),
//               child: const Row(
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(20.0),
//                     child: Icon(Icons.person_2),
//                   ),
//                   Expanded(child: Column(
//                     children: [
//                       Column(
//                         children: [
//                           Text("Yunus graphik")
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.location_on_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("Localisation")
//                               ],)),
//                               // SizedBox(width: 3,),
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.done_outline_sharp),
//                                 SizedBox(width: 3,),
//                                 Text("Disponible oui")
//                               ],)),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.contact_phone_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("0585649579")
//                               ],)),
//                               // SizedBox(width: 3,),
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.star_rate_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("Notes")
//                               ],)),
//                             ],
//                           ),
//                         ],
//                       )
//                     ],
//                   ))
//                 ],
//               )
//             ),
//           ),
//           const Divider(height: 8,),
//         ],
//       ),
//     );
//   }

//   Widget _garagiste() {
//     return Expanded(
//       child: ListView(
//         children: [
//           const Divider(height: 8,),
//           InkWell(
//             onTap: (){
//               print("Bonjour !!!!");
//             },
//             child: Container(
//               height: 80,
//               margin: const EdgeInsets.all(4),
//               decoration: const BoxDecoration(
//                 color: Colors.grey,
//                 // border: Border.all(color: Colors.grey, width: 1.5),
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(4),
//                 ),
//               ),
//               child: const Row(
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(20.0),
//                     child: Icon(Icons.person_2),
//                   ),
//                   Expanded(child: Column(
//                     children: [
//                       Column(
//                         children: [
//                           Text("Yunus graphik")
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.location_on_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("Localisation")
//                               ],)),
//                               // SizedBox(width: 3,),
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.done_outline_sharp),
//                                 SizedBox(width: 3,),
//                                 Text("Disponible oui")
//                               ],)),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.contact_phone_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("0585649579")
//                               ],)),
//                               // SizedBox(width: 3,),
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.star_rate_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("Notes")
//                               ],)),
//                             ],
//                           ),
//                         ],
//                       )
//                     ],
//                   ))
//                 ],
//               )
//             ),
//           ),
//           const Divider(height: 8,),
//         ],
//       ),
//     );
//   }

//   Widget _plombier() {
//     return Expanded(
//       child: ListView(
//         children: [
//           const Divider(height: 8,),
//           InkWell(
//             onTap: (){
//               print("Bonjour !!!!");
//             },
//             child: Container(
//               height: 80,
//               margin: const EdgeInsets.all(4),
//               decoration: const BoxDecoration(
//                 color: Colors.grey,
//                 // border: Border.all(color: Colors.grey, width: 1.5),
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(4),
//                 ),
//               ),
//               child: const Row(
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(20.0),
//                     child: Icon(Icons.person_2),
//                   ),
//                   Expanded(child: Column(
//                     children: [
//                       Column(
//                         children: [
//                           Text("Yunus graphik")
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.location_on_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("Localisation")
//                               ],)),
//                               // SizedBox(width: 3,),
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.done_outline_sharp),
//                                 SizedBox(width: 3,),
//                                 Text("Disponible oui")
//                               ],)),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.contact_phone_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("0585649579")
//                               ],)),
//                               // SizedBox(width: 3,),
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.star_rate_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("Notes")
//                               ],)),
//                             ],
//                           ),
//                         ],
//                       )
//                     ],
//                   ))
//                 ],
//               )
//             ),
//           ),
//           const Divider(height: 8,),
//         ],
//       ),
//     );
//   }

//   Widget _soudeur() {
//     return Expanded(
//       child: ListView(
//         children: [
//           const Divider(height: 8,),
//           InkWell(
//             onTap: (){
//               print("Bonjour !!!!");
//             },
//             child: Container(
//               height: 80,
//               margin: const EdgeInsets.all(4),
//               decoration: const BoxDecoration(
//                 color: Colors.grey,
//                 // border: Border.all(color: Colors.grey, width: 1.5),
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(4),
//                 ),
//               ),
//               child: const Row(
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(20.0),
//                     child: Icon(Icons.person_2),
//                   ),
//                   Expanded(child: Column(
//                     children: [
//                       Column(
//                         children: [
//                           Text("Yunus graphik")
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.location_on_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("Localisation")
//                               ],)),
//                               // SizedBox(width: 3,),
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.done_outline_sharp),
//                                 SizedBox(width: 3,),
//                                 Text("Disponible oui")
//                               ],)),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.contact_phone_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("0585649579")
//                               ],)),
//                               // SizedBox(width: 3,),
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.star_rate_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("Notes")
//                               ],)),
//                             ],
//                           ),
//                         ],
//                       )
//                     ],
//                   ))
//                 ],
//               )
//             ),
//           ),
//           const Divider(height: 8,),
//         ],
//       ),
//     );
//   }
  
//   Widget _mecanicien() {
//     return Expanded(
//       child: ListView(
//         children: [
//           const Divider(height: 8,),
//           InkWell(
//             onTap: (){
//               print("Bonjour !!!!");
//             },
//             child: Container(
//               height: 80,
//               margin: const EdgeInsets.all(4),
//               decoration: const BoxDecoration(
//                 color: Colors.grey,
//                 // border: Border.all(color: Colors.grey, width: 1.5),
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(4),
//                 ),
//               ),
//               child: const Row(
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(20.0),
//                     child: Icon(Icons.person_2),
//                   ),
//                   Expanded(child: Column(
//                     children: [
//                       Column(
//                         children: [
//                           Text("Yunus graphik")
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.location_on_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("Localisation")
//                               ],)),
//                               // SizedBox(width: 3,),
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.done_outline_sharp),
//                                 SizedBox(width: 3,),
//                                 Text("Disponible oui")
//                               ],)),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.contact_phone_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("0585649579")
//                               ],)),
//                               // SizedBox(width: 3,),
//                               Expanded(child: Row(children: [
//                                 Icon(Icons.star_rate_outlined),
//                                 SizedBox(width: 3,),
//                                 Text("Notes")
//                               ],)),
//                             ],
//                           ),
//                         ],
//                       )
//                     ],
//                   ))
//                 ],
//               )
//             ),
//           ),
//           const Divider(height: 8,),
//         ],
//       ),
//     );
//   }

// }






// :::::::::::::

