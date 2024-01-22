// ignore_for_file: prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, avoid_print, prefer_const_constructors, use_build_context_synchronously

// import 'dart:ffi';
import 'dart:math';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
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

class Average {
  // final String id;
  final double average;
  final Map<String, dynamic> prestataire; // Champ 'prestataire' est de type Map<String, dynamic>

  Average(this.average, this.prestataire);
  
  // String get nomprenom => prestataire['nomprenom']; // Accès à nomprenom à l'intérieur de l'objet author
}

class Rating {
  final String id;
  final Map<String, dynamic> author;
  final String prestataire;
  final dynamic rating; // Utiliser le type dynamic ici

  Rating(this.id, this.author, this.prestataire, this.rating);

  String get nomprenom => author['nomprenom'];
}

// class Rating {
//   final String id;
//   final String rating;
//   final Map<String, dynamic> author;
//   final String prestataire;
//   // final int rating; // Nouvelle propriété pour stocker la notation du prestataire


//   Rating(this.id, this.author, this.prestataire, this.rating
//   //  this.rating
//   );
//   String get nomprenom => author['nomprenom'];
// }


class ModelePrestataire extends StatefulWidget {
  final String id;
  final String nomprenom;
  final String email;
  final bool prestataire;
  final String domaineactivite;
  final String photoProfil;
  final int numero;
  
  final String nomcommercial;
  final double longitude;
  final double latitude;

  

  const ModelePrestataire({super.key, 
  required this.id,
    required this.nomprenom,
    required this.email,
    required this.nomcommercial,
    required this.prestataire, required this.domaineactivite, required this.longitude, required this.latitude, required this.numero, required this.photoProfil, 
    
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
  // double average = 0.0; // Ajoutez cette variable d'état

  double? average; // Déclarez la variable au niveau de la classe State

  List<Commentaire> commentaires = [];
  List<Average> averages = [];

  List<Rating> ratings = [];

  // late String ratingId = " ";
  late String ratingId;
  late String ratingNumber;

  _ModelePrestataireState() {
    ratingId = ""; // Initialisez ratingId avec une valeur non-constante dans le constructeur
    ratingNumber = "";
  }

  TextEditingController usernameController = TextEditingController();

  late double _rating;
  final double _initialRating = 0.0;
  IconData? _selectedIcon;
  int _ratingBarMode = 1;
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


  // Le bonne méthode.
  Future<List<Commentaire>> fetchData1() async {
    String username = usernameController.text;
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://ocean-52xt.onrender.com/comments'));
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

  Future<List<Rating>> fetchRating() async {
  setState(() {
    isLoading = true; // Afficher le chargement
  });

  final String apiUrl = 'https://ocean-52xt.onrender.com/myrating/ratings/${widget.id}?author=${UserData.id}';
  print("Jésusssssssssssssssssssssssssssssssssssssssssssssssssssssssss" + apiUrl);
  final Map<String, String> headers = {
    // 'Authorization':
    //     'Bearer ${UserData.token}',
    };

  try {
    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      final dataRating = jsonDecode(response.body) as List<dynamic>;
      print("ouais ratingggggggggggggggggggggggggggggggggggggg, ${dataRating}");

      if (dataRating.isNotEmpty) {
        print("888888888888888888888888888888888888");
        // ratingNumber = dataRating[0]['rating'];
        // print("ouais 11111111111111111111111111111111111111, ${ratingNumber}");
        // _rating = double.parse(ratingNumber);
        _rating = dataRating[0]['rating'].toDouble();
        print("ouais 22222222222222222222222222222222222222222, ${_rating}");

        // String ratingId = dataRating[0]['_id'];
        ratingId = dataRating[0]['_id'];
        print("ouais ID du rating : $ratingId");
      } else {
        _rating = 0.0;
      }

      final fetchedRating = dataRating
          .map((item) => Rating(
                item['_id'] as String,
                item['author'] as Map<String, dynamic>,
                item['prestataire'] as String,
                // item['rating'] as String,
                // item['rating'].toString(),
                item['rating'], // Utiliser le type dynamic ici
              ))
          .toList();

      setState(() {
        isLoading = false; // Cacher le chargement
        ratings = fetchedRating;
      });

      return fetchedRating;
    } else {
      // Gérer le cas d'erreur ici
      throw Exception('Failed to fetch data from MongoDB. fetchRating()');
    }
  } catch (error) {
    // Gérer les erreurs liées à la requête ici
    print('Error: $error');
    
    // Renvoyer une liste vide en cas d'erreur
    return [];
  }
}




  // Poster un rating
  Future<List<Rating>> postRating() async {
    double username = _rating;
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://ocean-52xt.onrender.com/myrating'));
    request.body = json.encode({
      "rating": username,
      "author": UserData.id,
      "prestataire": widget.id
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var jsonString = await response.stream.bytesToString();
      print("Bonjours je suis postRating() ${jsonString}");

      return ratings;
    } else {
      // Gérez les erreurs ici, vous pouvez renvoyer une liste vide ou lancer une exception selon le cas
      // throw Exception('Erreur lors de la création du rating');
      return [];
    }
  }

  //Poster un rating
  Future<List<Rating>> updateRating() async {
    double username = _rating;
    var headers = {
      'Content-Type': 'application/json'
    };
    // var urlRating = "http://192.168.137.1:3000/rating/$ratingId"; 
    var urlRating = "https://ocean-52xt.onrender.com/myrating/$ratingId"; 
    print("Okkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk" + urlRating);
    var request = http.Request('PUT', Uri.parse(urlRating));
    request.body = json.encode({
      "rating": username,
      // "author": UserData.id,
      // "prestataire": widget.id
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var jsonString = await response.stream.bytesToString();
      print("Bonsoir je suis updateRating() ${jsonString}");

      return ratings;
    } else {
      // Gérez les erreurs ici, vous pouvez renvoyer une liste vide ou lancer une exception selon le cas
      throw Exception('Erreur lors de la mise à jour du rating. updateRating()');
    }
  }

  Future<List<Commentaire>> fetchData() async {
  setState(() {
    isLoading = true; // Afficher le chargement
  });

  final String apiUrl = 'https://ocean-52xt.onrender.com/comments/commentaires/${widget.id}';
  final Map<String, String> headers = {
    'Authorization': 'Bearer ${UserData.token}',
  };

  try {
    final response = await http.get(Uri.parse(apiUrl), headers: headers);

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
      });

      return fetchedCommentaires;
    } else {
      // Gérer le cas d'erreur ici
      throw Exception('Failed to fetch data from MongoDB');
    }
  } catch (error) {
    
    // Renvoyer une liste vide en cas d'erreur
    return [];
  }
}



Future<double> fetchRatingAverage() async {
  try {
    final String apiUrl = 'https://ocean-52xt.onrender.com/myrating/ratings/allusers/${widget.id}';
    final Map<String, String> headers = {
      // 'Authorization': 'Bearer ${UserData.token}',
    };

    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Vérifiez si 'average' existe et n'est pas null
      if (data.containsKey('average') && data['average'] != null) {
        // Utilisez directement la valeur comme un double
        var average = data['average'] as num;
        print("objectjjjjjjjj + ${average}");

        // Retournez la valeur moyenne
        return average.toDouble();
      } else {
        // Si 'average' est null, retournez une valeur par défaut de 0.0
        return 0.0;
      }
    } else {
      // En cas d'échec de la requête, vous pouvez lancer une exception ou retourner une valeur par défaut
      throw Exception('Failed to fetch data');
    }
  } catch (e) {
    // Gérez l'erreur et retournez une valeur par défaut
    print('Error: $e');
    return 0.0;
  }
}


  void lancerAppel(String numero) async {
    String url = "tel:$numero";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible de lancer l\'appel au $numero';
    }
  }

void _onItemTapped(int index) async {
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
                onPressed: () async {
                  // Ajoutez votre logique pour enregistrer le commentaire ici
                  print("postttttttttttttttttttttt");
                  await fetchData1(); // Attendre la fin de la requête POST
                  print("Attente de 2 secondes...");
                  setState(() {
                    fetchData();
                  });
                  // await Future.delayed(Duration(seconds: 5)); // Attendre 2 secondes
                  print("gettttttttttttttttttttttttt");
                  // await fetchData(); // Attendre la fin de la requête GET
                  Navigator.of(context).pop();
                  setState(() {});
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
    // ratingId = ""; // Initialisez ratingId avec une valeur non-constante
    isPrestataire = widget.prestataire; // Initialiser la variable d'état locale
    _rating = _initialRating;
    publicitesFuture = fetchData();
    fetchData().then((fetchedCommentaires) {
      setState(() {
        commentaires = fetchedCommentaires;
      });
    });
    fetchRatingAverage();
    // fetchData().then((fetchedRatingAverage) {
    //   setState(() {
    //     averages = fetchedRatingAverage;
    //   });
    // });
    fetchRating().then((fetchedRating) {
      setState(() {
        ratings = fetchedRating;
      });
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.all(8.0),
                              // color: Colors.black54,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      // border: Border.all(color: Colors.grey, width: 1.5),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: GestureDetector(
                                      onTap: (){
                                        lancerAppel("${widget.numero}");
                                      },
                                      child: const Icon(Icons.call, color: Colors.white,),
                                      // Text(
                                      //   "Numéro : ${widget.numero}",
                                      //   style: const TextStyle(
                                      //     fontSize: 16,
                                      //     // color: Colors.white,
                                      //   ),
                                      // ),
                                    ),
                                  ),
                                  Text("Appel")
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.all(8.0),
                              // color: Colors.black54,
                              child: Column(
                                children: [
                                  Text(
                                    "Nom commercial",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      // color: Colors.white,
                                    ),
                                  ),
                                  Text("${widget.nomcommercial}", style: TextStyle(fontWeight: FontWeight.bold),)
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.all(8.0),
                              // color: Colors.black54,
                              child: Column(
                                children: [
                                  Text(
                                    "Disponible",
                                    style: TextStyle(
                                      fontSize: 16,
                                      // color: Colors.white,
                                    ),
                                  ),
                                  Text(UserData.disponible == true ? "Oui" : "Non", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.all(8.0),
                              // color: Colors.black54,
                              child: Column(
                                children: [
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
                                  Container(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text("Localiser le prestataire", style: TextStyle(
                                      fontSize: 16,
                                    ),),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1,),
                        _ratingBar(_ratingBarMode),
                        // Text(
                        //   'Rating: $_rating',
                        //   style: const TextStyle(fontWeight: FontWeight.bold),
                        // ),
                        Center(child: const Divider(height: 80,)),
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


    Widget _ratingBar(int mode) {
  switch (mode) {
    case 1:
      return RatingBar.builder(
        initialRating: _rating,
        minRating: 1,
        direction: _isVertical ? Axis.vertical : Axis.horizontal,
        allowHalfRating: true,
        unratedColor: Colors.amber.withAlpha(50),
        itemCount: 5,
        itemSize: 50.0,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(
          _selectedIcon ?? Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {
          setState(() {
            _rating = rating;
          });
          ratings.isEmpty ? postRating() : updateRating();
        },
        updateOnDrag: true,
      );
    case 2:
      return RatingBar(
        initialRating: _rating,
        direction: _isVertical ? Axis.vertical : Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        ratingWidget: RatingWidget(
          full: Icon(Icons.abc),
          half: Icon(Icons.abc),
          empty: Icon(Icons.abc),
        ),
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        onRatingUpdate: (rating) {
          setState(() {
            _rating = rating;
          });
          ratings.isEmpty ? postRating() : updateRating();
        },
        updateOnDrag: true,
      );
    case 3:
      return RatingBar.builder(
        initialRating: _rating,
        direction: _isVertical ? Axis.vertical : Axis.horizontal,
        itemCount: 5,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return const Icon(
                Icons.sentiment_very_dissatisfied,
                color: Colors.red,
              );
            case 1:
              return const Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.redAccent,
              );
            case 2:
              return const Icon(
                Icons.sentiment_neutral,
                color: Colors.amber,
              );
            case 3:
              return const Icon(
                Icons.sentiment_satisfied,
                color: Colors.lightGreen,
              );
            case 4:
              return const Icon(
                Icons.sentiment_very_satisfied,
                color: Colors.green,
              );
            default:
              return Container();
          }
        },
        onRatingUpdate: (rating) {
          setState(() {
            _rating = rating;
          });
          ratings.isEmpty ? postRating() : updateRating();
        },
        updateOnDrag: true,
      );
    default:
      return Container();
  }
}

  Widget _profile() {
  return Container(
    margin: const EdgeInsets.only(top: 5),
    child: Column(
      children: [
        CachedNetworkImage(
          imageUrl: widget.photoProfil ?? '',
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          height: 100,
          width: MediaQuery.of(context).size.width * 0.350,
          fit: BoxFit.cover,
        ),
        // GestureDetector(
        //   onTap: _pickImage,
        //   child: CircleAvatar(
        //     radius: 50,
        //     backgroundImage: _image != null ? FileImage(_image!) : null,
        //     child: _image == null
        //         ? Image.asset(
        //             "img/profile.png",
        //             height: 100,
        //             width: 100,
        //             fit: BoxFit.cover,
        //           )
        //         : null,
        //   ),
        // ),
        const SizedBox(height: 8,),
        Column(
          children: [
            Text('${widget.nomcommercial}', style: const TextStyle(color: Colors.white, fontSize: 20),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${widget.domaineactivite}', style: const TextStyle(color: Colors.white, fontSize: 20),),
                // SizedBox(width: MediaQuery.sizeOf(context).width * 0.05,),
                // SizedBox(width: 10,),
                // Utilisation du nouveau widget pour afficher la moyenne
                // A revoir pour décommenter
                // Padding(
                //   padding: const EdgeInsets.only(left: 80.0),
                //   child: _buildAverageWidget(),
                // ),
              ],
            ),
            const SizedBox(height: 5,),
          ],
        ),
        const SizedBox(height: 8,),
      ],
    ),
  );
}



Widget _buildAverageWidget() {
  return FutureBuilder<double?>(
    future: fetchRatingAverage(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Afficher un indicateur de chargement si les données ne sont pas encore disponibles
        return CircularProgressIndicator(color: Colors.white,);
      } else if (snapshot.hasError) {
        // Gérer les erreurs de récupération des données
        return Text("Erreur: ${snapshot.error}");
      } else {
        // Les données ont été récupérées avec succès
        return Container(
          alignment: Alignment.bottomLeft,
          child: Text(
            '${snapshot.data}',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        );
      }
    },
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







