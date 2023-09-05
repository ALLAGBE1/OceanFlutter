// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Future<void> connecterUtilisateur() async {
    String password = passwordController.text;
    String username = usernameController.text;

    try {
      var response = await http.post(
        Uri.parse('http://192.168.1.13:3000/users/connexion/'),
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
          print("Document Fourni : " + data['user']['documentfournirId']);
          documentFourni = data['user']['documentfournirId'];
          print("valeur ::::: " + documentFourni);
        }
        // if(data.containsKey('user')) {
        //   bool isAdmin = data['user']['admin'];
        //   print("Admin : " + isAdmin.toString());
        // }
        var cordonnees = data['user'];
        String nomprenom = cordonnees["nomprenom"];
        String email = cordonnees["email"];
        bool isAdmin = cordonnees["admin"];
        String documentfournirId = cordonnees["documentfournirId"];

        UserData.nomprenom = nomprenom;
        UserData.email = email;
        UserData.isAdmin = isAdmin;
        UserData.documentfournirId = documentfournirId;
        

        if (data['success']) {
          // Stockez les informations dans SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('nomprenom', UserData.nomprenom);
          prefs.setString('email', UserData.email);
          prefs.setBool('isAdmin', UserData.isAdmin);
          prefs.setString('documentfournirId', UserData.documentfournirId);
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
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const BottomNavBar()),
                      // );
                      // Navigator.pushReplacementNamed(context, '/home');
                      Navigator.pushAndRemoveUntil(
                        context, 
                        MaterialPageRoute(builder: (context) => BottomNavBar(documentFourni: documentFourni)), 
                        (route) => false
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
        "Email ou numéro de téléphone",
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
        placeholder: "Adresse mail",
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