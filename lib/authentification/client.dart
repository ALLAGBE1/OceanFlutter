// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:ocean/authentification/connexion.dart';
import 'package:ocean/authentification/enregistrement.dart';
import 'package:http/http.dart' as http;

bool connecte = false;

class LeClient extends StatefulWidget {
  const LeClient({super.key});

  @override
  State<LeClient> createState() => _LeClientState();
}
class _LeClientState extends State<LeClient> {
  bool _obscureText = true; // définir l'état initial comme étant masqué

  TextEditingController nomprenomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  Future<void> enregistrerUtilisateur() async {
    String nomprenom = nomprenomController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String username = usernameController.text;


    // Effectuer la requête HTTP vers l'API Node.js pour enregistrer l'utilisateur
    try {
      var response = await http.post(
        Uri.parse('http://192.168.1.13:3000/users/sinscrire'),
        body: {
          'nomprenom': nomprenom,
          'email': email,
          'username': username,
          'password': password,
        },
      );

      // Vérifier la réponse du serveur
      if (response.statusCode == 200) {
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
                    // Navigator.push(
                    // context,
                    // MaterialPageRoute(
                    //     builder: (context) => const Connexion()));
                    Navigator.pushReplacementNamed(context, '/connexion');
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Erreur lors de l'enregistrement
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erreur'),
              content: const Text('Une erreur est survenue lors de l\'enregistrement de l\'utilisateur.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    // setState(() {
                    //   nomController.text = "";
                    //   prenomController.text = "";
                    //   emailController.text = "";
                    //   passwordController.text = "";
                    //   usernameController.text = "";
                    //   confirmationController.text = "";
                    // });
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
                  // setState(() {
                  //   nomController.text = "";
                  //   prenomController.text = "";
                  //   emailController.text = "";
                  //   passwordController.text = "";
                  //   usernameController.text = "";
                  //   confirmationController.text = "";
                  // });
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
      body: SingleChildScrollView(
        dragStartBehavior: DragStartBehavior.down,
        child: Container(
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
                  Padding(
                    padding: const EdgeInsets.all(15.0),
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Enregistrement()));
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
                  SizedBox(height: MediaQuery.sizeOf(context).height*0.020,),
                  _username(),
                  _vusername(),
                  SizedBox(height: MediaQuery.sizeOf(context).height*0.020,),
                  _email(),
                  _vemail(),
                  SizedBox(height: MediaQuery.sizeOf(context).height*0.020,),
                  _motdepasse(),
                  _vmotdepasse(),
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
                    child: TextButton(onPressed: (){
                      enregistrerUtilisateur();
                    }, child: Text(
                      'Continuer',
                      style: GoogleFonts.acme(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                    )))),  
                    SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                    TextButton(onPressed: (){},
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
    );
  }

  Widget _entetetext() {
    return Container(
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

  Widget _vnomprenom() {
    return Container(
      height: 58,
      margin: const EdgeInsets.all(10),
      child: CupertinoTextField(
        controller: nomprenomController,
        placeholder: "Nom et prénom",
        decoration: BoxDecoration(
          border: Border.all(color: Colors.greenAccent),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _username() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        "Username",
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

  Widget _vusername() {
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

  Widget _email() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        "Numéro de téléphone ou Email",
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
        controller: emailController,
        placeholder: "Numéro de téléphone ou Email",
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
      height: 58,
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
          padding: EdgeInsets.zero,
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

}