// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocean/authentification/confirmation.dart';
import 'package:ocean/authentification/connexion.dart';
import 'package:ocean/authentification/enregistrement.dart';
import 'package:ocean/authentification/user_data.dart';
import 'package:ocean/pages/bottomNavBar.dart';
import 'package:ocean/pages/compteClient.dart';
import 'package:ocean/pages/preInscription.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


bool connecte = false;

class MiseAJour extends StatefulWidget {
  const MiseAJour({super.key});

  @override
  State<MiseAJour> createState() => _MiseAJourState();
}

class _MiseAJourState extends State<MiseAJour> {
  String nomprenomError = '';
  String numeroError = '';

  bool isLoading = false;
  bool _obscureText = true;
  TextEditingController nomprenomController = TextEditingController();
  TextEditingController numeroController = TextEditingController();
  String documentFourni = "";
  
  // late String data; // Déclarer la variable en dehors du bloc if

  Future<String> obtenirNomDuLieu(double latitude, double longitude) async {
    final apiKey = 'AIzaSyAGztnpiNaYe1Jsa7HMsmaq2kRMdRRTEdY'; // Remplacez ceci par votre clé d'API Google Maps Geocoding
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          // Obtenez le nom du lieu à partir des résultats de géocodage
          var results = data['results'];
          if (results.isNotEmpty) {
            return results[0]['formatted_address'];
          } else {
            return 'Lieu inconnu';
          }
        } else {
          return 'Erreur de géocodage';
        }
      } else {
        throw Exception('Échec de la requête de géocodage');
      }
    } catch (error) {
      print('Erreur de géocodage : $error');
      return 'Erreur de géocodage';
    }
  }

  Future<void> connecterUtilisateur() async {
    // Réinitialise les messages d'erreur
    setState(() {
      nomprenomError = '';
      numeroError = '';
    });

    String nomprenom = nomprenomController.text;
    String numero = numeroController.text;

    // Vérifie si le champ numero est vide
    if (numero.isEmpty) {
      setState(() {
        nomprenomError = 'Veuillez renseigner votre nom d\'utilisateur';
      });
      return;
    }

    // Vérifie si le champ nomprenom est vide
    if (nomprenom.isEmpty) {
      setState(() {
        numeroError = 'Veuillez renseigner votre mot de passe';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    var data; // Déclaration de la variable data en dehors du bloc try

    try {
      var response = await http.put(
        Uri.parse('https://ocean-52xt.onrender.com/users/update/${UserData.id}'),
        body: {
          'nomprenom': nomprenom,
          'numero': numero,
        },
      );

      if (response.statusCode == 200) {
        data = json.decode(response.body);
        print("premier data : " + data.toString());
        print("JOSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS");
        
        
                

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Succès'),
              content: const Text("Mise à jour bien effectuée."),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Connexion())
                      // MaterialPageRoute(builder: (context) => CompteClient(documentFourni: documentFourni))
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Erreur de connexion
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erreur'),
              // content: Text('Une erreur est survenue lors de la connexion.'),
              content: const Text('Une erreur est survenue lors de la connexion au serveur.'),
              // content: const Text('Une erreur est survenue lors de la connexion.'),
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content: const Text('Une erreur est survenue lors de la connexion au serveur.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
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
                    Center(child: Image.asset("img/logo.png", 
                      // height: MediaQuery.sizeOf(context).height*0.30, 
                      width: MediaQuery.sizeOf(context).width*0.50,
                    ),),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _entetetext(),
                    SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                    Column(
                      children: [
                        _nomprenom(),
                        _vnomprenom(),
                        _numero(),
                        _vnumero(),
                      ],
                    ),
                    // if (isLoading) _spinner(),
                    // _connect()
                  ],
                ),
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
                        onPressed: isLoading ? null : () => connecterUtilisateur(), 
                        child: Text(
                          'Continuer',
                          style: GoogleFonts.acme(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                        )))),  
                  ],
                )   
              ],
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
  

  Widget _spinner() {
    return const SpinKitFadingCircle(
      color: Colors.blueAccent,
      duration: Duration(milliseconds: 1200),
      size: 100.0,
    );
  }

  Widget _entetetext() {
    return Text(
      "Mise à jour",
      style: GoogleFonts.acme(
        color: Colors.white,
        fontSize: 35,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _nomprenom() {
    return Container(
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
      // padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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


  Widget _numero() {
    return Container(
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
      // padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

}