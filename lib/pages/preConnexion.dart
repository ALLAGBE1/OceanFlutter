// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocean/authentification/connexion.dart';
// import 'package:ocean/authentification/connexion.dart';
import 'package:ocean/authentification/partenaire.dart';
import 'package:ocean/authentification/user_data.dart';
// import 'package:ocean/pages/preInscription.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreConnexion extends StatefulWidget {
  const PreConnexion({super.key});

  @override
  State<PreConnexion> createState() => _PreConnexionState();
}

class _PreConnexionState extends State<PreConnexion> {

  @override
  void initState() {
    super.initState();
    _verifierConnexion();
  }

  Future<void> _verifierConnexion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Vérifiez si l'utilisateur est déjà connecté
    String? nomprenom = prefs.getString('nomprenom');
    String? email = prefs.getString('email');
    String? documentfournirId = prefs.getString('documentfournirId');

    if (nomprenom != null && email != null && documentfournirId != null) {
      // Mettez à jour les données de l'utilisateur en mémoire
      UserData.nomprenom = nomprenom;
      UserData.email = email;
      UserData.documentfournirId = documentfournirId;
      // Redirigez vers la page d'accueil
      Navigator.pushReplacementNamed(context, '/home');  
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
            image: const DecorationImage(
              image: AssetImage('img/background.jpg'), 
              fit: BoxFit.cover,
            ) // Changed Image.asset to AssetImage
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
                SizedBox(height: MediaQuery.sizeOf(context).height*0.10,),
                Text(
                  'Bienvenue',
                  style: GoogleFonts.acme(
                    fontSize: 40.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 230,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(style: BorderStyle.solid, color: Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(25))
                  ),
                  child: TextButton(onPressed: (){
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const Connexion()), 1
                    // );
                    // Navigator.pushReplacementNamed(context, '/connexion'); 2
                    Navigator.pushReplacementNamed(context, '/home');
                  }, child: Container(
                    // padding: EdgeInsets.all(5),
                    child: Text(
                      'Naviguez en tant que visiteur',
                      style: GoogleFonts.acme(
                        fontSize: 17.0,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                    )),
                  ))),  
                SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                Container(
                  width: 230,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(style: BorderStyle.solid, color: Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(25))
                  ),
                  child: TextButton(onPressed: (){
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const Connexion()), 1
                    // );
                    // Navigator.pushReplacementNamed(context, '/connexion'); 2
                    // Navigator.pushReplacementNamed(context, '/connexion');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Connexion()),
                    );
                  }, child: Container(
                    // padding: EdgeInsets.all(5),
                    child: Text(
                      'Connexion',
                      style: GoogleFonts.acme(
                        fontSize: 17.0,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                    )),
                  ))),  
                SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                Container(
                  width: 230,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(style: BorderStyle.solid, color: Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(25))
                  ),
                  child: TextButton(onPressed: (){
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => const PreInscription()));
                    // Navigator.pushReplacementNamed(context, '/preinscription');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Partenaire()),
                    );

                  }, child: Text(
                    'Devenir un partenaire',
                    style: GoogleFonts.acme(
                      fontSize: 17.0,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                  )))),  
              ],
            )

          ],
        ),
      ),
    );
  }
}


