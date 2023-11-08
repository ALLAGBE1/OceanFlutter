// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_interpolation_to_compose_strings, prefer_const_declarations
// AIzaSyAsNXk9Lonwzza_cKPSRKlcQmpNZIXNh_U
// AIzaSyCr1RuzlktW07p-DPaQylXgtuVdWGmFd1A
// Pour moi
// AIzaSyAGztnpiNaYe1Jsa7HMsmaq2kRMdRRTEdY

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocean/authentification/confirmation.dart';
import 'package:ocean/authentification/enregistrement.dart';
import 'package:ocean/authentification/user_data.dart';
import 'package:ocean/pages/bottomNavBar.dart';
import 'package:ocean/pages/preInscription.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


bool connecte = false;

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  bool _obscureText = true;
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  String documentFourni = ""; // Déclarer la variable en dehors du bloc if

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
    String password = passwordController.text;
    String username = usernameController.text;

    try {
      var response = await http.post(
        Uri.parse('https://ocean-52xt.onrender.com/users/connexion/'),
        body: {
          'password': password,
          'username': username,
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print("premier data : " + data.toString());
        print("JOSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS");
        if(data.containsKey('user')) {
          print("deuxième data : " + data['user'].toString());
        }
        if(data.containsKey('user')) {
          print("Nom et prénom : " + data['user']['nomprenom']);
        }
        if(data.containsKey('user')) { 
          // print("Document Fourni : " + data['user']['documentfournirId']);
          // documentFourni = data['user']['documentfournirId'];
          // print("valeur ::::: " + documentFourni);

          var cordonnees = data['user'];
          String id = cordonnees["_id"];
          print("Ouaissssssssssssssssssssss ${id}");
          String nomprenom = cordonnees["nomprenom"];
          String email = cordonnees["email"];
          int numero = cordonnees["numero"];
          String photoProfil = cordonnees["photoProfil"];
          bool confirmation = cordonnees["confirmation"];
          String nomcommercial = cordonnees["nomcommercial"];
          String domaineactivite = cordonnees["domaineactivite"];
          bool isAdmin = cordonnees["admin"];
          bool disponible = cordonnees["disponible"];
          String documentfournirId = cordonnees["documentfournirId"];
          print("Document FourniId ${documentfournirId}");
          
          UserData.username = username;
          UserData.nomprenom = nomprenom;
          UserData.email = email;
          UserData.numero = numero;
          UserData.photoProfil = photoProfil;
          UserData.confirmation = confirmation;
          UserData.nomcommercial = nomcommercial;
          UserData.domaineactivite = domaineactivite;
          UserData.isAdmin = isAdmin;
          UserData.disponible = disponible;
          UserData.documentfournirId = documentfournirId;
          UserData.id = id;

          String latitude = '';
          String longitude = '';

          if (data['user']['location'] != null) {
            latitude = data['user']['location']['coordinates'][1].toString();
            longitude = data['user']['location']['coordinates'][0].toString();
          }
          UserData.latitude = latitude;
          UserData.longitude = longitude;

          String nomDuLieu = await obtenirNomDuLieu(double.parse(latitude), double.parse(longitude));
          if (nomDuLieu != 'Erreur de géocodage') {
            UserData.nomDuLieu = nomDuLieu;
          } else {
            // Gestion de l'erreur de géocodage
            UserData.nomDuLieu = 'Lieu inconnu';
          }
        }
                

        if (data['success']) {
          // Stockez les informations dans SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('username', UserData.username);
          prefs.setString('nomprenom', UserData.nomprenom);
          prefs.setString('email', UserData.email);
          prefs.setInt('numero', UserData.numero);
          prefs.setString('photoProfil', UserData.photoProfil);
          prefs.setBool('confirmation', UserData.confirmation);
          prefs.setString('nomcommercial', UserData.nomcommercial);
          prefs.setString('domaineactivite', UserData.domaineactivite);
          prefs.setBool('isAdmin', UserData.isAdmin);
          prefs.setBool('disponible', UserData.disponible);
          prefs.setString('documentfournirId', UserData.documentfournirId);
          prefs.setString('latitude', UserData.latitude);
          prefs.setString('longitude', UserData.longitude);
          // prefs.setString('id', UserData.id) as String;
          bool success = await prefs.setString('id', UserData.id);
          String rrr = success ? 'Id enregistré avec succès' : "Échec de l'enregistrement de l\'Id";
          print("ppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp ${rrr}");


          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Succès'),
                content: Text(data['status']),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      if(UserData.confirmation) {
                        Navigator.pushAndRemoveUntil(
                          context, 
                          MaterialPageRoute(builder: (context) => BottomNavBar(documentFourni: documentFourni)), 
                          (route) => false
                        );
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context, 
                          MaterialPageRoute(builder: (context) => const ConfirmationScreen() ), 
                          (route) => false
                        );
                      }
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
                content: Text(data['status']),
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
      } else {
        // Erreur de connexion
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erreur'),
              // content: Text('Une erreur est survenue lors de la connexion.'),
              content: const Text('Une erreur est survenue lors de la connexion.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => const Enregistrement()));
                          Navigator.pushReplacementNamed(context, '/enregistrement');

                        },
                        icon: const Icon(Icons.bolt_outlined), color: Colors.yellowAccent,),
                    _entetetext(),
                  ],
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                _email(),
                _vemail(),
                SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                _motdepasse(),
                _vmotdepasse(),
                _connect()
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
                  child: TextButton(onPressed: (){
                    connecterUtilisateur();
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const BottomNavBar()),
                    // );
                  }, child: Text(
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
    );
  }

  Widget _entetetext() {
    return Container(
      child: Text(
        "Connexion",
        style: GoogleFonts.acme(
          color: Colors.white,
          fontSize: 35,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _email() {
    return Container(
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

  Widget _vemail() {
    return Container(
      height: 58,
      margin: const EdgeInsets.all(10),
      child: CupertinoTextField(
        controller: usernameController,
        placeholder: "Username",
        decoration: BoxDecoration(
          border: Border.all(color: Colors.greenAccent),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _motdepasse() {
    return Container(
      child: Text(
        "Mot de passe",
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
      child: CupertinoTextField(
        // Radius cursorRadius = const Radius.circular(2.0),
        // bool cursorOpacityAnimates = true,
        // Color? cursorColor,
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
    );
  }

  Widget _connect() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(onPressed: (){},
           child: Text(
            "Mot de passe oublié",
            style: GoogleFonts.acme(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          ),
          Row(
            children: [
              Text(
                "J'ai pas un compe.",
                style: GoogleFonts.acme(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                  onPressed: () {
                    connecte ? const Enregistrement() : null;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PreInscription()));
                  },
                  icon: const Icon(Icons.login)),
            ],
          )
        ],
      ),
    );
  }
}