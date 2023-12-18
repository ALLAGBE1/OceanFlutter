// ignore_for_file: avoid_print, use_build_context_synchronously, depend_on_referenced_packages, unnecessary_brace_in_string_interps

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:ocean/authentification/confirmation.dart';
import 'package:ocean/authentification/connexion.dart';
import 'package:ocean/pages/qrcodeView.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


bool connecte = false;

class Partenaire extends StatefulWidget {
  const Partenaire({super.key});

  @override
  State<Partenaire> createState() => _PartenaireState();
}
class _PartenaireState extends State<Partenaire> {
  String usernameError = '';
  String passwordError = '';
  String nomprenomError = '';
  String emailError = '';
  String numeroError = '';
  String nomcommercialError = '';
  String domaineactiviteError = '';
  // String selectedFileNameError = '';

  bool isLoading = false;
  bool _obscureText = true; // définir l'état initial comme étant masqué
  String? _chosenValue;  // Variable pour stocker la valeur sélectionnée
  String? selectedFileName;

  TextEditingController nomprenomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numeroController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController nomcommercialController = TextEditingController();
  TextEditingController domaineactiviteController = TextEditingController();

  // ::::::::::::
  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    fetchDomainesActivite(); 
  }

  Future<void> _checkPermission() async {
    if (await Permission.location.request().isGranted) {
      _getLocation();
    }
  }

  Future<void> _getLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _longitude = position.longitude;
        _latitude = position.latitude;
        print("Longitude: $_longitude");
        print("Latitude: $_latitude");
    });
    } catch (e) {
      print('Erreur lors de l\'obtention de la position : $e');
      // Gérer l'erreur de géolocalisation ici
    }
  }

// :::::::::::

  Future<void> enregistrerUtilisateur() async {
    // Réinitialise les messages d'erreur
    setState(() {
      nomprenomError = '';
      emailError = '';
      numeroError = '';
      nomcommercialError = '';
      usernameError = '';
      passwordError = '';
      domaineactiviteError = '';
      // selectedFileNameError = '';
    });

    String nomprenom = nomprenomController.text;
    String email = emailController.text;
    String numero = numeroController.text;
    String password = passwordController.text;
    String username = usernameController.text;
    String nomcommercial = nomcommercialController.text;
    String domaineactivite = domaineactiviteController.text;

    // Vérifie si le champ username est vide
    if (nomprenom.isEmpty) {
      setState(() {
        nomprenomError = 'Veuillez renseigner votre nom et prénom';
      });
      return;
    }

    // Vérifie si le champ password est vide
    if (username.isEmpty) {
      setState(() {
        usernameError = 'Veuillez renseigner votre nom d\'utilisateur';
      });
      return;
    }

    // Vérifie si le champ password est vide
    if (email.isEmpty) {
      setState(() {
        emailError = 'Veuillez renseigner votre email';
      });
      return;
    }

    // Vérifie si le champ password est vide
    if (numero.isEmpty) {
      setState(() {
        numeroError = 'Veuillez renseigner votre numéro';
      });
      return;
    }

    // Vérifie si le champ password est vide
    if (password.isEmpty) {
      setState(() {
        passwordError = 'Veuillez renseigner votre mot de passe';
      });
      return;
    }

    // Vérifie si le champ password est vide
    if (nomcommercial.isEmpty) {
      setState(() {
        nomcommercialError = 'Veuillez renseigner votre nom commercial';
      });
      return;
    }

    // Vérifie si le champ password est vide
    if (domaineactivite.isEmpty) {
      setState(() {
        domaineactiviteError = 'Veuillez renseigner votre domaine d\'activité';
      });
      return;
    }

    // Vérifie si le champ password est vide
    // if (selectedFileName!.isEmpty) {
    //   setState(() {
    //     selectedFileNameError = 'Veuillez renseigner votre pièce';
    //   });
    //   return;
    // }

    // Créez une requête multipart
    // var uri = Uri.parse('https://10.50.12.85:3000/users/sinscrire');
    var uri = Uri.parse('https://ocean-52xt.onrender.com/users/sinscrire');
    var request = http.MultipartRequest('POST', uri)
      ..fields['nomprenom'] = nomprenom
      ..fields['email'] = email
      ..fields['numero'] = numero
      ..fields['username'] = username
      ..fields['password'] = password
      ..fields['nomcommercial'] = nomcommercial
      ..fields['domaineactivite'] = domaineactivite
      ..fields['location'] = jsonEncode({
        'type': 'Point',
        'coordinates': [_longitude, _latitude]
      });

      print('Réponse du ppppppppppppppppppppppppppppp: ${request}');

    // Vérifiez si un fichier a été choisi
    if (selectedFileName != null && selectedFileName!.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'documentfournirId', // le nom du champ sur le serveur (assurez-vous qu'il correspond à ce que votre serveur attend)
        selectedFileName!, // chemin complet du fichier
        contentType: MediaType('application/json', 'pdf'), // définir le type de média pour PDF
      ));
    }

    setState(() {
      isLoading = true;
    });

    String responseBody;
    String errMessage;

    try {
      print('Réponse du serveur: 111111111111111111111111111');
      var response = await request.send();
      print('Réponse du serveur: 2222222222222222222222222222');
      // Vérifier la réponse du serveur
      if (response.statusCode == 200) {
        print('Réponse du serveur: 3333333333333333333333333333');
        // Vous pouvez également convertir la réponse en texte pour obtenir des détails
        responseBody = await response.stream.bytesToString();
        // String responseBody = await response.stream.bytesToString();
        print('Réponse du serveur: 4444444444444444444444444444444444');
        print('Réponse du serveur: $responseBody');
        print('Réponse du serveur: 555555555555555555555555555555555');
        // Enregistrement réussi
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Succès'),
              content: const Text('L\'utilisateur a été enregistré avec succès.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    // Navigator.of(context).pop();
                    // setState(() {
                    //   nomController.text = "";
                    //   prenomController.text = "";
                    //   emailController.text = "";
                    //   passwordController.text = "";
                    //   usernameController.text = "";
                    //   confirmationController.text = "";
                    // });
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Connexion())
                    // MaterialPageRoute(
                    //     builder: (context) => const ConfirmationScreen())
                  );
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Erreur lors de l'enregistrement
        responseBody = await response.stream.bytesToString();
        print('Réponse du serveur (erreur serveur): 6666666666666666666666666666666');
        print('Réponse du serveur: $responseBody');

        // Parse la réponse JSON
        Map<String, dynamic> jsonResponse = json.decode(responseBody);

        // Récupère la valeur de la clé "err" s'il existe
        // errMessage = jsonResponse.containsKey("err") ? jsonResponse["err"] : jsonResponse["err"];
        errMessage = jsonResponse.containsKey("status") ? jsonResponse["status"] : jsonResponse["status"];
        // String errMessage = jsonResponse.containsKey("err") ? jsonResponse["err"] : "Erreur inconnue";

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erreur'),
              content: Text('$errMessage'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Erreur : $error');
      // String errMessage = jsonResponse.containsKey("err") ? jsonResponse["err"] : "Erreur inconnue";
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur'),
            // content: const Text('Une erreur est survenue lors de la connexion au serveur.'),
            // content: Text('$errMessage'),
            content: Text('$error'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
              ),
            ],
          );
        },
      );
    }

    setState(() {
      isLoading = false;
    });
  }


  Future<List<String>> fetchDomainesActivite() async {
    // final response = await http.get(Uri.parse('http://10.50.12.85:3000/domaineActivite/'));
    final response = await http.get(Uri.parse('https://ocean-52xt.onrender.com/domaineActivite/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final fetchedDomaineActivites = data.map((item) => item['domaineactivite'] as String).toList();

      return fetchedDomaineActivites;
    } else {
      throw Exception('Failed to fetch data from MongoDB');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              // height: MediaQuery.sizeOf(context).height,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(color: Colors.grey, width: 1.5),
                  image: const DecorationImage(image: AssetImage('img/background.jpg'), fit: BoxFit.cover) // Changed Image.asset to AssetImage
                ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 38),
                        child: Center(child: Image.asset("img/logo.png", 
                          // height: MediaQuery.sizeOf(context).height*0.30, 
                          width: MediaQuery.sizeOf(context).width*0.50,
                        ),),
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/enregistrement');
                              },
                              icon: const Icon(Icons.bolt_outlined), color: Colors.yellowAccent,),
                          _entetetext(),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _nomprenom(),
                      _vnomprenom(),
                      SizedBox(height: MediaQuery.sizeOf(context).height*0.010,),
                      _username(),
                      _vusername(),
                      SizedBox(height: MediaQuery.sizeOf(context).height*0.010,),
                      _email(),
                      _vemail(),
                      SizedBox(height: MediaQuery.sizeOf(context).height*0.010,),
                      _numero(),
                      _vnumero(),
                      SizedBox(height: MediaQuery.sizeOf(context).height*0.010,),
                      _motdepasse(),
                      _vmotdepasse(),
                      SizedBox(height: MediaQuery.sizeOf(context).height*0.010,),
                      _nomCommercial(),
                      _vnomCommercial(),
                      SizedBox(height: MediaQuery.sizeOf(context).height*0.010,),
                      _domaineActivite(),
                      _vdomaineActivite(),
                      SizedBox(height: MediaQuery.sizeOf(context).height*0.010,),
                      _documentFournir(),
                      _vdocumentFournir(),
                      // _connect()
                    ],
                  ),
                  // if (isLoading) _spinner(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 180,
                        decoration: BoxDecoration(
                          // color: Colors.blue,
                          border: Border.all(style: BorderStyle.solid, color: Colors.white),
                          borderRadius: const BorderRadius.all(Radius.circular(0.1))
                        ),
                        child: TextButton(
                        onPressed: isLoading ? null : () => enregistrerUtilisateur(),
                        child: Text(
                          'Continuer',
                          style: GoogleFonts.acme(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                      )))),  
                      SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                      TextButton(onPressed: (){
                        _showConditionsDialog(context);
                      },
                        child: Text(
                          "Conditions générales d'utilisation",
                          style: GoogleFonts.acme(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),)
                        
                    ],
                  )   
                ],
              ),
            ),
          ),
          if (isLoading)
          Positioned(
            child: _spinner(),
          ),
        ],
      ),
    );
  }

  void _showConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conditions Générales d\'Utilisation'),
          content: const SingleChildScrollView(
            child: Text(
              '''
              Date d'entrée en vigueur : 1er janvier 2024
              Bienvenue sur OCEAN, une plateforme qui vous connecte aux prestataires de services locaux disponibles 24h/24, 7j/7. Avant d'utiliser notre service, veuillez lire attentivement les conditions générales d'utilisation suivantes.

              1. Acceptation des Conditions
              En utilisant notre application, vous acceptez de vous conformer à ces conditions générales. Si vous n'êtes pas d'accord avec ces conditions, veuillez ne pas utiliser l'application.

              2. Description du Service
              Notre plate-forme constitue un vaste réseau de prestataires de services. Elle permet à nos utilisateurs de rentrer en contact avec les prestataires disponibles et les plus proches de leur lieu d'emplacement. Les prestataires sont classés par catégorie, les utilisateurs peuvent par contre effectuer une recherche avec des mots clés comme "soudeur", "plombier" ou encore "livreur". Les utilisateurs peuvent laisser des avis sur les prestataires et leur noter également. Le service est gratuit et disponible 24h sur 24, 7 jours sur 7.

              3. Inscription et Comptes
              Pour utiliser pleinement notre service, vous devez vous inscrire et créer un compte. Vous devez fournir des informations exactes et complètes lors de l'inscription.

              4. Règles d'Utilisation
              - Vous acceptez de ne pas utiliser l'application à des fins illégales, frauduleuses ou nuisibles.
              - Vous ne pouvez pas publier de contenu offensant, diffamatoire ou inapproprié.
              - Vous êtes responsable de maintenir la sécurité de votre compte.

              5. Contenu Généré par l'Utilisateur
              Les commentaires, évaluations et autres contenus générés par les utilisateurs peuvent être modérés. Nous nous réservons le droit de supprimer tout contenu.
              ''',
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Widget _spinner() {
    return const SpinKitFadingCircle(
      color: Colors.blueAccent,
      duration: Duration(milliseconds: 1200),
      size: 100.0,
    );
  }
  
  Widget _entetetext() {
    return SizedBox(
      child: Text(
        "Créer un compte",
        style: GoogleFonts.acme(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _nomprenom() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        "Nom et prénom",
        style: GoogleFonts.acme(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _vnomprenom() {
    return Container(
      // height: 58,
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          CupertinoTextField(
            controller: nomprenomController,
            placeholder: "Nom et prénom",
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            suffix: CupertinoButton(
              child: const Text(" "),
              onPressed: () {
                // setState(() {
                //   _obscureText = !_obscureText;
                // });
              },
            ),
          ),
          Text(
            nomprenomError,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _username() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        "Username",
        style: GoogleFonts.acme(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _vusername() {
    return Container(
      // height: 58,
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          CupertinoTextField(
            controller: usernameController,
            placeholder: "Username",
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            suffix: CupertinoButton(
              child: const Text(" "),
              onPressed: () {
                // setState(() {
                //   _obscureText = !_obscureText;
                // });
              },
            ),
          ),
          Text(
            usernameError,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _email() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        "Email",
        style: GoogleFonts.acme(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _vemail() {
    return Container(
      // height: 58,
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          CupertinoTextField(
            controller: emailController,
            placeholder: "Email",
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            suffix: CupertinoButton(
              child: const Text(" "),
              onPressed: () {
                // setState(() {
                //   _obscureText = !_obscureText;
                // });
              },
            ),
          ),
          Text(
            emailError,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _numero() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        "Numéro de téléphone",
        style: GoogleFonts.acme(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _vnumero() {
    return Container(
      // height: 58,
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          CupertinoTextField(
            controller: numeroController,
            placeholder: "Numéro de téléphone",
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            suffix: CupertinoButton(
              child: const Text(" "),
              onPressed: () {
                // setState(() {
                //   _obscureText = !_obscureText;
                // });
              },
            ),
          ),
          Text(
            numeroError,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _motdepasse() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        "Créer un mot de passe",
        style: GoogleFonts.acme(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _vmotdepasse() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          CupertinoTextField(
            controller: passwordController,
            obscureText: _obscureText,
            placeholder: "Créer un mot de passe",
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            suffix: CupertinoButton(
              // padding: EdgeInsets.zero,
              child: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
          Text(
            passwordError,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _nomCommercial() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        "Nom commercial",
        // textAlign: TextAlign.start,
        // textDirection: TextDirection.ltr,
        style: GoogleFonts.acme(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _vnomCommercial() {
    return Container(
      // height: 58,
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          CupertinoTextField(
            controller: nomcommercialController,
            placeholder: "Nom commercial",
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            suffix: CupertinoButton(
              child: const Text(" "),
              onPressed: () {
                // setState(() {
                //   _obscureText = !_obscureText;
                // });
              },
            ),
          ),
          Text(
            nomcommercialError,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _domaineActivite() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        "Domaine d'activité",
        // textAlign: TextAlign.start,
        // textDirection: TextDirection.ltr,
        style: GoogleFonts.acme(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _vdomaineActivite() {
    return Container(
      // height: 58,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.greenAccent),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: Column(
        children: [
          FutureBuilder<List<String>>(
            future: fetchDomainesActivite(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erreur: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Aucun domaine trouvé.');
              } else {
                List<String> domaines = snapshot.data!;
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration.collapsed(hintText: 'Exemple : Plombier'),
                  isExpanded: true,
                  value: _chosenValue,
                  items: domaines.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _chosenValue = value;
                      domaineactiviteController.text = value!;
                    });
                  },
                );
              }
            },
          ),
          Text(
            domaineactiviteError,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
}

  Widget _documentFournir() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        "Documents à fournir",
        // textAlign: TextAlign.start,
        // textDirection: TextDirection.ltr,
        style: GoogleFonts.acme(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _vdocumentFournir() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Material(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent),
                borderRadius: BorderRadius.circular(5),
              ),
              child: InkWell(
             
                onTap: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'], // Autorise uniquement les fichiers PDF
                  );

                  if (result != null) {
                    PlatformFile file = result.files.first;

                    // Utilisez directement le chemin d'accès complet avec l'extension
                    selectedFileName = file.path!;

                    // Récupérez le nom du fichier à partir du chemin d'accès
                    String fileName = selectedFileName!.split('/').last;

                    // Si le fichier n'a pas d'extension, ajoutez ".pdf"
                    if (!fileName.toLowerCase().endsWith('.pdf')) {
                      fileName += '.pdf';
                      selectedFileName = selectedFileName!.replaceAll(selectedFileName!.split('/').last, fileName);
                    }

                    setState(() {}); // Cela déclenchera une reconstruction de l'interface utilisateur
                    print("Nom du fichier : $fileName");
                    print("Taille du fichier : ${file.size} bytes");
                    print("Extension du fichier : ${file.extension}");
                    print("Chemin d'accès complet : $selectedFileName");
                  }
                },


                // onTap: () async {
                //   FilePickerResult? result = await FilePicker.platform.pickFiles(
                //     type: FileType.custom,
                //     allowedExtensions: ['pdf'], // Autorise uniquement les fichiers PDF
                //   );

                //   if (result != null) {
                //     PlatformFile file = result.files.first;
                //     // selectedFileName = file.name;
                //     selectedFileName = file.path;
                //     setState(() {}); // Cela déclenchera une reconstruction de l'interface utilisateur
                //     print("Nom du fichier : ${file.name}");
                //     print("Taille du fichier : ${file.size} bytes");
                //     print("Extension du fichier : ${file.extension}");
                //     print("Chemin d'accès complet : ${file.path}");
                //   }
                // },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedFileName ?? "Exemple : Carte commercant",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    CupertinoButton(
                      
                      padding: EdgeInsets.zero,
                      // child: const Icon(
                      //   Icons.qr_code_scanner, // Icône de scanner
                      //   color: Colors.grey,
                      // ),
                      child: Container(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const QRViewExample()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
}
}

