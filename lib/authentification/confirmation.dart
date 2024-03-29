// ignore_for_file: use_build_context_synchronously, sort_child_properties_last

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocean/authentification/connexion.dart';
import 'package:ocean/authentification/enregistrement.dart';
import 'package:ocean/authentification/user_data.dart';
// import 'package:ocean/pages/accueil.dart';
import 'package:ocean/pages/bottomNavBar.dart';
import 'package:http/http.dart' as http;
// import 'package:ocean/pages/preInscription.dart';

bool connecte = false;

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool isLoading = false;
  String documentFourni = ""; // Déclarer la variable en dehors du bloc if
  TextEditingController usernameController = TextEditingController();
  
  Future<void> postVerification() async {
  String username = usernameController.text;

  setState(() {
    isLoading = true;
  });

  try {
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://ocean-52xt.onrender.com/users/verification'));
    request.body = json.encode({
      "username": UserData.username,
      "verificationCode": username,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var jsonString = await response.stream.bytesToString();
      print(jsonString);
      
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => BottomNavBar(documentFourni: documentFourni)), 
        (route) => false
      );
      // return commentaires;
    } else {
      // Gérez les erreurs ici, vous pouvez renvoyer une liste vide ou lancer une exception selon le cas
      throw Exception('Erreur lors de la création du commentaire');
    }
  } catch (error) {
    // Gérez l'erreur ici (imprimez-la ou effectuez d'autres actions nécessaires)
    print('Erreur lors de la requête HTTP : $error');
    // Vous pouvez également afficher un message d'erreur à l'utilisateur si nécessaire
  }

  setState(() {
    isLoading = false;
  });
} 

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmation de l'inscription"),
      ),
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
            child: Center(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Center(
                    child: Text(
                      'Veuillez confirmer votre inscription en renseignant le code de vérification que nous vous avons envoyé par mail.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17
                      ),
                    ),
                  ),
                  const SizedBox(height: 15,),
                  _vemail(),
                  // ElevatedButton(
                  //   child: const Text('Renvoyer l\'email de confirmation'),
                  //   onPressed: () {
                  //     // Appeler une fonction pour renvoyer l'email de confirmation
                  //   },
                  // ),
                  const SizedBox(height: 15,),
                  ElevatedButton(
                    child: const Text('Envoyer'),
                    // onPressed: () {
                    //   postVerification();
                    // },
                    onPressed: isLoading ? null : () => postVerification(),
                  ),
                  const SizedBox(height:25,),
                  _connect()
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

  Widget _spinner() {
    return const SpinKitFadingCircle(
      color: Colors.blueAccent,
      duration: Duration(milliseconds: 1200),
      size: 100.0,
    );
  }

  Widget _vemail() {
    return Container(
      height: 58,
      margin: const EdgeInsets.all(10),
      child: CupertinoTextField(
        controller: usernameController,
        placeholder: "Veuillez entrer le code composé de 6 caractères.",
        decoration: BoxDecoration(
          border: Border.all(color: Colors.greenAccent),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
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
            " ",
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
                "J'ai un compe.",
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
                            builder: (context) => const Connexion()));
                  },
                  icon: const Icon(Icons.login)),
            ],
          )
        ],
      ),
    );
  }
}


