// ignore_for_file: prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, avoid_print, prefer_const_constructors

import 'dart:ffi';
import 'dart:math';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// import 'package:ocean/authentification/user_data.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ocean/authentification/user_data.dart';
import 'package:ocean/pages/carte_page_map.dart';


class Commentaire {
  final String id;
  final String comment;
  final Map<String, dynamic> author; // Champ 'author' est de type Map<String, dynamic>

  Commentaire(this.id, this.comment, this.author);
  
  String get nomprenom => author['nomprenom']; // Accès à nomprenom à l'intérieur de l'objet author
}


class ModelePrestataire extends StatefulWidget {
  final String id;
  final String nomprenom;
  final String email;
  final bool prestataire;
  final String domaineactivite;
  final int numero;
  
  final String nomcommercial;
  final double longitude;
  final double latitude;

  

  const ModelePrestataire({super.key, 
  required this.id,
    required this.nomprenom,
    required this.email,
    required this.nomcommercial,
    required this.prestataire, required this.domaineactivite, required this.longitude, required this.latitude, required this.numero, 
    
  });

  @override
  State<ModelePrestataire> createState() => _ModelePrestataireState();
}

class _ModelePrestataireState extends State<ModelePrestataire> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isPrestataire = false; // Utiliser une variable d'état locale

  late Future<List<Commentaire>> publicitesFuture;

  bool isLoading = true;

  List<Commentaire> commentaires = [];

  TextEditingController usernameController = TextEditingController();

  late double _rating;
  final double _initialRating = 0.0;
  // IconData? _selectedIcon;
  final bool _isVertical = false;

  int _selectedIndex = 0; // Ajoutez cette ligne pour déclarer la variable _selectedIndex

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  // TextEditingController nomprenomController = TextEditingController();
  Future<void> _saveRatingToDatabase(double rating) async {
    var apiUrl = 'http://192.168.31.206:3000/users/partenaires/${widget.id}'; // Remplacez cela par votre URL d'API
    var requestBody = {'rating': rating.toString()}; // Les données que vous voulez envoyer à la base de données

    try {
      var response = await http.post(
        apiUrl as Uri,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        // La requête a réussi
        print('Rating enregistré avec succès dans la base de données.');
      } else {
        // La requête a échoué avec une erreur
        print('Échec de l\'enregistrement du rating dans la base de données. Statut: ${response.statusCode}');
      }
    } catch (error) {
      // Une erreur s'est produite lors de l'envoi de la requête
      print('Erreur lors de l\'envoi de la requête: $error');
    }
  } //A décommenter


  // Le bonne méthode.
  Future<List<Commentaire>> fetchData1() async {
    String username = usernameController.text;
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('http://192.168.31.206:3000/comments'));
    request.body = json.encode({
      "comment": username,
      "author": UserData.id,
      "prestataire": widget.id
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var jsonString = await response.stream.bytesToString();
      print(jsonString);

      return commentaires;
    } else {
      // Gérez les erreurs ici, vous pouvez renvoyer une liste vide ou lancer une exception selon le cas
      throw Exception('Erreur lors de la création du commentaire');
    }
  }


  Future<List<Commentaire>> fetchData() async {
    setState(() {
      isLoading = true; // Afficher le chargement
    });

    // final response = await http.get(Uri.parse('http://192.168.31.206:3000/comments'));
    final response = await http.get(Uri.parse('http://192.168.31.206:3000/comments/commentaires/${widget.id}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      print("ouais tttttttttttttttttttttttttttttttttttt, ${data}");
      final fetchedCommentaires = data
        .map((item) => Commentaire(
              item['_id'] as String,
              item['comment'] as String,
              item['author'] as Map<String, dynamic>,
              
            ))
        .toList();


      setState(() {
        isLoading = false; // Cacher le chargement
        commentaires = fetchedCommentaires;
        // print("ouaissssssssssss, ${commentaires}");
      });

      return fetchedCommentaires;
  } else {
    throw Exception('Failed to fetch data from MongoDB');
  }
}


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        // Affichez une boîte de dialogue ou naviguez vers une nouvelle page pour laisser un commentaire ici
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Laisser un commentaire'),
              content: TextField(
                controller: usernameController,
                decoration: InputDecoration(hintText: 'Entrez votre commentaire ici'),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Ajoutez votre logique pour enregistrer le commentaire ici
                    fetchData1();
                    Navigator.of(context).pop();
                  },
                  child: Text('Envoyer'),
                ),
              ],
            );
          },
        );
      }
    });
  }


  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      }
    });
  }


  @override
  void initState() {
    super.initState();
    isPrestataire = widget.prestataire; // Initialiser la variable d'état locale
    _rating = _initialRating;
    publicitesFuture = fetchData();
    fetchData().then((fetchedCommentaires) {
      setState(() {
        commentaires = fetchedCommentaires;
      });
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SingleChildScrollView(
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(
              color: Colors.grey,
              border: Border.all(color: Colors.grey, width: 1.5),
              image: const DecorationImage(image: AssetImage('img/background.jpg'), fit: BoxFit.cover) // Changed Image.asset to AssetImage
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top : 25.0),
                  child: Row(
                    children: [
                      Expanded(child: Text(" ")),
                      // Icon(Icons.drive_file_rename_outline_rounded, color: Colors.white,)
                    ],
                  ),
                ),
                _profile(),
                const Divider(height: 0, indent: 20, endIndent: 20,),
                Expanded(
                  child: Container(
                    height: MediaQuery.sizeOf(context).height / 1,
                    width: MediaQuery.sizeOf(context).width,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(8.0),
                          // color: Colors.black54,
                          child: Text(
                            "Nom commercial : ${widget.nomcommercial}",
                            style: const TextStyle(
                              fontSize: 16,
                              // color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(8.0),
                          // color: Colors.black54,
                          child: Text(
                            "Numéro : ${widget.numero}",
                            style: const TextStyle(
                              fontSize: 16,
                              // color: Colors.white,
                            ),
                          ),
                        ),
                        // const Divider(height: 30,),
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Text("Disponible :", style: TextStyle(
                                fontSize: 16,
                                // color: Colors.white
                              ),),
                              const SizedBox(width: 5,),
                              Text(UserData.disponible == true ? "Oui" : "Non", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Text("Localiser le prestataire", style: TextStyle(
                                 fontSize: 16,
                                ),),
                              const SizedBox(width: 8,),
                              ElevatedButton(
                                onPressed: () {  
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CartePageMap(
                                        latitude: widget.latitude,
                                        longitude: widget.longitude,
                                      ),
                                    ),
                                  );
                                },
                                child: const Icon(Icons.map),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 30,),
                        _comment()
          
                      ],
                    ),
                  ),
                ),
                  ],
                ),
              ),
      ),

      bottomNavigationBar: SizedBox(
        height: 56, // Hauteur du BottomNavigationBar
        child: GestureDetector(
          onTap: () {
            _onItemTapped(1);
            // Gérez le clic sur l'élément ici
            // Mettez ici le code que vous souhaitez exécuter lorsque l'élément est cliqué
          },
          child: Container(
            color: Colors.blue, // Couleur de fond du bouton
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(
                  Icons.comment, // Icône de commentaire
                  color: Colors.white, // Couleur de l'icône
                ),
                SizedBox(width: 8), // Espacement entre l'icône et le texte
                Text(
                  'Appuyer pour laisser un commentaire',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),    
    );
  }

  Widget _profile() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _image != null ? FileImage(_image!) : null,
              child: _image == null
                  ? Image.asset(
                      "img/profile.png",
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8,),
          Column(
            children: [
              Text('${widget.nomcommercial}', style: const TextStyle(color: Colors.white, fontSize: 20),),
              Text('${widget.domaineactivite}', style: const TextStyle(color: Colors.white, fontSize: 20),),
              const SizedBox(height: 5,),
              // Text('Rating: $_rating'),
            ],
          ),
          const SizedBox(height: 8,),
        ],
      ),
    );
  }


  Widget _comment() {
    Random random = Random();

    // Liste des couleurs possibles : rouge, blanc et jaune
    List<Color> colors = [Colors.blue, Colors.blueGrey, Colors.white70];

    return SizedBox(
      child: SizedBox(
        // margin: const EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height * 0.20,
        width: MediaQuery.of(context).size.width * 0.90,
        child: FutureBuilder<List<Commentaire>>(
          future: publicitesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Erreur lors du chargement des publicités');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Il n'y a pas encore de commentaire. Soyez le premier à laisser un commentaire sur ce prestataire."));
            } else {
              return CarouselSlider.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index, realIndex) {
                  final commentaire = snapshot.data![index];
      
                  // Choisissez une couleur aléatoire parmi la liste des couleurs
                  Color randomColor = colors[random.nextInt(colors.length)];
                  return Container(
                    margin: const EdgeInsets.all(5),
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: MediaQuery.of(context).size.width * 0.75,
                    decoration: BoxDecoration(
                      // color: Colors.grey[200], // Couleur de fond pour le commentaire
                      color: randomColor, // Couleur de fond aléatoire pour le commentaire
                      borderRadius: BorderRadius.circular(10), // Coins arrondis
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                // Affichez la photo du client ici
                                radius: 30,
                                // backgroundImage: Icon(Icons.ac_unit_rounded), // Remplacez par l'URL de l'image du client
                                // backgroundImage: NetworkImage(commentaire.userImage), // Remplacez par l'URL de l'image du client
                                child: Icon(Icons.person, size: 40, color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      commentaire.comment, // Texte du commentaire
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(" "),
                              Expanded(
                                child: Text(
                                  textDirection : TextDirection.rtl,
                                  commentaire.nomprenom, 
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  autoPlay: true,
                ),
              );
            }
          },
        ),
      ),
    );
  }

}

  




// ::::

// // ignore_for_file: prefer_interpolation_to_compose_strings, unnecessary_string_interpolations

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:ocean/authentification/user_data.dart';

// class ModelePrestataire extends StatefulWidget {
//   final String id;
//   final String nomprenom;
//   final String email;
//   final bool prestataire;
//   final String domaineactivite;

  

//   const ModelePrestataire({super.key, 
//   required this.id,
//     required this.nomprenom,
//     required this.email,
//     required this.prestataire, required this.domaineactivite, 
    
//   });

//   @override
//   State<ModelePrestataire> createState() => _ModelePrestataireState();
// }

// class _ModelePrestataireState extends State<ModelePrestataire> {
//   File? _image;
//   final ImagePicker _picker = ImagePicker();
//   bool isPrestataire = false; // Utiliser une variable d'état locale

//   late double _rating;
//   double _initialRating = 0.0;
//   // IconData? _selectedIcon;
//   bool _isVertical = false;

//   final MaterialStateProperty<Icon?> thumbIcon =
//       MaterialStateProperty.resolveWith<Icon?>(
//     (Set<MaterialState> states) {
//       if (states.contains(MaterialState.selected)) {
//         return const Icon(Icons.check);
//       }
//       return const Icon(Icons.close);
//     },
//   );

//   // TextEditingController nomprenomController = TextEditingController();

//   Future<void> enregistrerUtilisateur() async {
//     String nomprenom = nomprenomController.text;

//     // Effectuer la requête HTTP vers l'API Node.js pour enregistrer l'utilisateur
//     try {
//       var response = await http.post(
//         Uri.parse('http://192.168.31.206:3000/users/sinscrire'),
//         body: {
//           'nomprenom': nomprenom,
//         },
//       );

//       // Vérifier la réponse du serveur
//       if (response.statusCode == 200) {
//         // Enregistrement réussi
//         String data = response.toString();
//         print("Ouaisssssssssssssss, ${data}");
//       } else {
//         // Erreur lors de l'enregistrement
        
//       }
//     } catch (error) {
//       print('Erreur : $error');
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return const AlertDialog(
//             title: Text('Erreur'),
//             content: Text("Une erreur est survenue lors du post de l'emodji."),
//           );
//         },
//       );
//     }
//   }


  

//   // Fonction pour mettre à jour l'état du partenaire
//   Future<void> updatePrestataireState(bool newState) async {
//     final String apiUrl = 'http://192.168.31.206:3000/users/partenaires/${widget.id}';
//     print("Donne moi l'url : " + apiUrl);
//     try {
//       final response = await http.put(
//         Uri.parse('${apiUrl}'),
//         body: {'prestataire': newState.toString()},
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           isPrestataire = newState;
//         });
//         print('État du partenaire mis à jour avec succès');
//       } else {
//         print('Erreur lors de la mise à jour de l\'état du partenaire');
//       }
//     } catch (error) {
//       print('Erreur lors de la requête HTTP : $error');
//     }
//   }

//   Future<void> _pickImage() async {
//     final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
//     setState(() {
//       if (pickedImage != null) {
//         _image = File(pickedImage.path);
//       }
//     });
//   }


//   @override
//   void initState() {
//     super.initState();
//     isPrestataire = widget.prestataire; // Initialiser la variable d'état locale
//     _rating = _initialRating;
//   }
  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body:Container(
//         width: MediaQuery.sizeOf(context).width,
//         height: MediaQuery.sizeOf(context).height,
//         decoration: BoxDecoration(
//             color: Colors.grey,
//             border: Border.all(color: Colors.grey, width: 1.5),
//             image: const DecorationImage(image: AssetImage('img/background.jpg'), fit: BoxFit.cover) // Changed Image.asset to AssetImage
//           ),
//           child: Column(
//             children: [
//               const Padding(
//                 padding: EdgeInsets.only(top : 25.0),
//                 child: Row(
//                   children: [
//                     Expanded(child: Text(" ")),
//                     // Icon(Icons.drive_file_rename_outline_rounded, color: Colors.white,)
//                   ],
//                 ),
//               ),
//               _profile(),
//               const Divider(height: 0, indent: 20, endIndent: 20,),
//               Expanded(
//                 child: Container(
//                   height: MediaQuery.sizeOf(context).height / 1,
//                   width: MediaQuery.sizeOf(context).width,
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                   ),
//                   child: Column(
//                     children: [
//                       Container(
//                         alignment: Alignment.bottomLeft,
//                         padding: const EdgeInsets.all(8.0),
//                         // color: Colors.black54,
//                         child: Text(
//                           "Nom : ${widget.nomprenom}",
//                           style: const TextStyle(
//                             fontSize: 16,
//                             // color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       Container(
//                         alignment: Alignment.bottomLeft,
//                         padding: const EdgeInsets.all(8.0),
//                         // color: Colors.black54,
//                         child: Text(
//                           "Email : ${widget.email}",
//                           style: const TextStyle(
//                             fontSize: 16,
//                             // color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       const Divider(height: 30,),
//                       Row(
//                         children: [
//                           const Text("Prestataire ? :", style: TextStyle(
//                             // color: Colors.white
//                           ),),
//                           const SizedBox(width: 5,),
//                           Switch(
//                             activeColor: Colors.green,
//                             thumbIcon: thumbIcon,
//                             value: isPrestataire,
//                             onChanged: (bool value) {
//                               setState(() {
//                                 // isPrestataire = value;
//                                 updatePrestataireState(value);
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                       _ratingBar()
//                     ],
//                   ),
//                 ),
//               ),
//                 ],
//               ),
//             ),
          
//     );
//   }

//   Widget _profile() {
//     return Container(
//       margin: const EdgeInsets.only(top: 5),
//       child: Column(
//         children: [
//           GestureDetector(
//             onTap: _pickImage,
//             child: CircleAvatar(
//               radius: 50,
//               backgroundImage: _image != null ? FileImage(_image!) : null,
//               child: _image == null
//                   ? Image.asset(
//                       "img/profile.png",
//                       height: 100,
//                       width: 100,
//                       fit: BoxFit.cover,
//                     )
//                   : null,
//             ),
//           ),
//           const SizedBox(height: 8,),
//           Column(
//             children: [
//               Text('${widget.nomprenom}', style: const TextStyle(color: Colors.white, fontSize: 20),),
//               Text('${widget.domaineactivite}', style: const TextStyle(color: Colors.white, fontSize: 20),),
//               const SizedBox(height: 5,)
//             ],
//           ),
//           const SizedBox(height: 8,),
//         ],
//       ),
//     );
//   }

//   Widget _ratingBar() {
//       return RatingBar.builder(
//             initialRating: _initialRating,
//             direction: _isVertical ? Axis.vertical : Axis.horizontal,
//             itemCount: 5,
//             itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
//             itemBuilder: (context, index) {
//               switch (index) {
//                 case 0:
//                   return const Icon(
//                     Icons.sentiment_very_dissatisfied,
//                     color: Colors.red,
//                     size: 2,
//                   );
//                 case 1:
//                   return const Icon(
//                     Icons.sentiment_dissatisfied,
//                     color: Colors.redAccent,
//                   );
//                 case 2:
//                   return const Icon(
//                     Icons.sentiment_neutral,
//                     color: Colors.amber,
//                   );
//                 case 3:
//                   return const Icon(
//                     Icons.sentiment_satisfied,
//                     color: Colors.lightGreen,
//                   );
//                 case 4:
//                   return const Icon(
//                     Icons.sentiment_very_satisfied,
//                     color: Colors.green,
//                   );
//                 default:
//                   return Container();
//               }
//             },
//             onRatingUpdate: (rating) {
//               setState(() {
//                 _rating = rating;
//               });
//             },
//             updateOnDrag: true,
//           );
//   }

// }




