// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  String usernameError = '';
  String passwordError = '';
  String nomprenomError = '';
  String emailError = '';
  String numeroError = '';


  bool isLoading = false;
  bool _obscureText = true; // définir l'état initial comme étant masqué

  TextEditingController nomprenomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController numeroController = TextEditingController();

  Future<void> enregistrerUtilisateur() async {
    // Réinitialise les messages d'erreur
    setState(() {
      nomprenomError = '';
      emailError = '';
      numeroError = '';
      usernameError = '';
      passwordError = '';
    });
    
    String nomprenom = nomprenomController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String username = usernameController.text;
    String numero = numeroController.text;
    // String numero = usernameController.text;
    // int numeroEntier = int.parse(numero);

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

    setState(() {
      isLoading = true;
    });


    // Effectuer la requête HTTP vers l'API Node.js pour enregistrer l'utilisateur
    try {
      var response = await http.post(
        // Uri.parse('https://10.50.12.85:3000/users/sinscrire'),
        Uri.parse('https://ocean-52xt.onrender.com/users/sinscrire'),
        body: {
          'nomprenom': nomprenom,
          'email': email,
          'username': username,
          'password': password,
          'numero': numero,
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
          SingleChildScrollView(
            dragStartBehavior: DragStartBehavior.down,
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
                      // Padding(
                      //   padding: const EdgeInsets.all(15.0),
                      //   child: Center(child: Image.asset("img/logo.png", 
                      //     // height: MediaQuery.sizeOf(context).height*0.30, 
                      //     width: MediaQuery.sizeOf(context).width*0.50,
                      //   ),),
                      // ),
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

  // Widget _vnomprenom() {
  //   return Container(
  //     // height: 58,
  //     margin: const EdgeInsets.all(10),
  //     child: Column(
  //       children: [
  //         CupertinoTextField(
  //           controller: nomprenomController,
  //           placeholder: "Nom et prénom",
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.greenAccent),
  //             borderRadius: BorderRadius.circular(5),
  //             color: Colors.white,
  //           ),
  //         ),
  //         Text(
  //           nomprenomError,
  //           style: const TextStyle(color: Colors.red),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

  // Widget _vusername() {
  //   return Container(
  //     // height: 58,
  //     margin: const EdgeInsets.all(10),
  //     child: Column(
  //       children: [
  //         CupertinoTextField(
  //           controller: usernameController,
  //           placeholder: "Username",
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.greenAccent),
  //             borderRadius: BorderRadius.circular(5),
  //             color: Colors.white,
  //           ),
  //         ),
  //         Text(
  //           usernameError,
  //           style: const TextStyle(color: Colors.red),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

  // Widget _vemail() {
  //   return Container(
  //     // height: 58,
  //     margin: const EdgeInsets.all(10),
  //     child: Column(
  //       children: [
  //         CupertinoTextField(
  //           controller: emailController,
  //           placeholder: "Numéro de téléphone ou Email",
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.greenAccent),
  //             borderRadius: BorderRadius.circular(5),
  //             color: Colors.white,
  //           ),
  //         ),
  //         Text(
  //           emailError,
  //           style: const TextStyle(color: Colors.red),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

  // Widget _vnumero() {
  //   return Container(
  //     // height: 58,
  //     margin: const EdgeInsets.all(10),
  //     child: Column(
  //       children: [
  //         CupertinoTextField(
  //           controller: numeroController,
  //           placeholder: "Numéro de téléphone",
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.greenAccent),
  //             borderRadius: BorderRadius.circular(5),
  //             color: Colors.white,
  //           ),
  //         ),
  //         Text(
  //           numeroError,
  //           style: const TextStyle(color: Colors.red),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

//  Widget _vmotdepasse() {
//     return Container(
//       // height: 58,
//       margin: const EdgeInsets.all(10),
//       child: Column(
//         children: [
//           CupertinoTextField(
//             // Radius cursorRadius = const Radius.circular(2.0),
//             // bool cursorOpacityAnimates = true,
//             // Color? cursorColor,
//             controller: passwordController,
//             obscureText: _obscureText,
//             placeholder: "Créer un mot de passe",
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.greenAccent),
//               borderRadius: BorderRadius.circular(5),
//               color: Colors.white,
//             ),
//             suffix: CupertinoButton(
//               padding: EdgeInsets.zero,
//               child: Icon(
//                 _obscureText ? Icons.visibility : Icons.visibility_off,
//                 color: Colors.grey,
//               ),
//               onPressed: () {
//                 setState(() {
//                   _obscureText = !_obscureText;
//                 });
//               },
//             ),
//           ),
//           Text(
//             passwordError,
//             style: const TextStyle(color: Colors.red),
//           ),
//         ],
//       ),
//     );
//   }

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

}