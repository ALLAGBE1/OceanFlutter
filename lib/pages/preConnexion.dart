// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocean/authentification/connexion.dart';
// import 'package:ocean/authentification/connexion.dart';
import 'package:ocean/authentification/partenaire.dart';
import 'package:ocean/authentification/user_data.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:ocean/pages/preInscription.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreConnexion extends StatefulWidget {
  const PreConnexion({super.key});

  @override
  State<PreConnexion> createState() => _PreConnexionState();
}

class _PreConnexionState extends State<PreConnexion> {

  Future<void> _checkPermission() async {
    if (await Permission.location.request().isGranted) {
      // _getLocation();
    }
  }


  @override
  void initState() {
    super.initState();
    _checkPermission();
    _verifierConnexion();
  }

  Future<void> _verifierConnexion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Vérifiez si l'utilisateur est déjà connecté
    String? id = prefs.getString('id');
    print("111111111111111111111111111111111111111111 ${id}");
    String? token = prefs.getString('token');
    print("tokennnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn ${token}");
    String? username= prefs.getString('username');
    print("zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz ${username}");
    String? photoProfil= prefs.getString('photoProfil');
    print("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr ${photoProfil}");
    String? nomprenom = prefs.getString('nomprenom');
    print("222222222222222222222222222222222222222222 ${nomprenom}");
    String? email = prefs.getString('email');
    print("333333333333333333333333333333333333333333 ${email}");
    int? numero = prefs.getInt('numero');
    print("333333333333333333333333333333333333333333 ${numero}");
    String? documentfournirId = prefs.getString('documentfournirId');
    print("4444444444444444444444444444444444444444444 ${documentfournirId}");
    String? domaineactivite = prefs.getString('domaineactivite');
    print("55555555555555555555555555555555555555555555 ${domaineactivite}");
    String? nomcommercial = prefs.getString('nomcommercial');
    print("66666666666666666666666666666666666666666666 ${nomcommercial}");
    String? latitude = prefs.getString('latitude');
    print("77777777777777777777777777777777777777777777 ${latitude}");
    String? longitude = prefs.getString('longitude');
    print("88888888888888888888888888888888888888888888 ${longitude}");
    String? nomDuLieu = prefs.getString('nomDuLieu');
    print("99999999999999999999999999999999999999999999999 ${nomDuLieu}");
    bool? disponible = prefs.getBool('disponible');
    print("1111111112222222222222222222222222222222222222 ${disponible}");
    bool? confirmation = prefs.getBool('confirmation');
    print("1111111112222222222222222222222222222222222222 ${confirmation}");
    bool? isAdmin= prefs.getBool('isAdmin');
    print("isAdminnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn ${isAdmin}");

    // if (id != null && nomprenom != null && email != null && documentfournirId != null && disponible != null  && domaineactivite != null 
    //   && nomcommercial != null && latitude != null && longitude != null && nomDuLieu != null) {
      if (token != null && id != null && username != null && photoProfil != null && nomprenom != null && email != null && documentfournirId != null && disponible != null && confirmation != null
        && domaineactivite != null && nomcommercial != null && latitude != null && longitude != null && isAdmin != null) {
      // Mettez à jour les données de l'utilisateur en mémoire
        UserData.id = id;
        UserData.token = token;
        UserData.username = username;
        UserData.photoProfil = photoProfil;
        UserData.nomprenom = nomprenom;
        UserData.email = email;
        UserData.numero = numero?? UserData.numero; //Je dois revoir si possible cette ligne;
        UserData.documentfournirId = documentfournirId;
        UserData.domaineactivite = domaineactivite;
        UserData.nomcommercial = nomcommercial;
        UserData.latitude = latitude;
        UserData.longitude = longitude;
        UserData.nomDuLieu = nomDuLieu?? UserData.nomDuLieu; //Je dois revoir si possible cette ligne
        UserData.disponible = disponible;
        UserData.confirmation = confirmation;
        UserData.isAdmin = isAdmin;
        // Redirigez vers la page d'accueil
        Navigator.pushReplacementNamed(context, '/home');  
        // Navigator.pushReplacementNamed(context, '/confirmation');  
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
                const Text(
                  'Bienvenue',
                  style: TextStyle(
                    fontSize: 40.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Text(
                //   'Bienvenue',
                //   style: GoogleFonts.acme(
                //     fontSize: 40.0,
                //     color: Colors.white,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
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
                    // child: const Text(
                    //   'Naviguez en tant que visiteur',
                    //   style: TextStyle(
                    //     fontSize: 17.0,
                    //     color: Colors.blue,
                    //     fontWeight: FontWeight.bold,
                    // )),
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
                    child: const Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                    )),
                    // child: Text(
                    //   'Connexion',
                    //   style: GoogleFonts.acme(
                    //     fontSize: 17.0,
                    //     color: Colors.blue,
                    //     fontWeight: FontWeight.bold,
                    // )),
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

                  }, 
                  child: const Text(
                    'Devenir un partenaire',
                    style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                  )))), 
                  // child: Text(
                  //   'Devenir un partenaire',
                  //   style: GoogleFonts.acme(
                  //     fontSize: 17.0,
                  //     color: Colors.blue,
                  //     fontWeight: FontWeight.bold,
                  // )))),  
              ],
            )

          ],
        ),
      ),
    );
  }
}


