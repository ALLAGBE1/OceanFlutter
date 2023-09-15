// ignore_for_file: unnecessary_string_interpolations, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:ocean/authentification/connexion.dart';
import 'package:ocean/authentification/user_data.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CompteClient extends StatefulWidget {
  final String documentFourni;
  // print(documentFourni);
  const CompteClient({Key? key, required this.documentFourni}) : super(key: key);
  

  @override
  State<CompteClient> createState() => _CompteClientState();
}

class _CompteClientState extends State<CompteClient> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      }
    });
  }

  void handleLogout(BuildContext context) async {
    bool success = await logoutUser();
    if (success) {
      // Redirigez vers la page de connexion
      Navigator.pushReplacementNamed(context, '/connexion');
      // Navigator.of(context).pushNamedAndRemoveUntil('/connexion', (route) => true);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => const Connexion()),
      // );
    } else {
      // Gérez l'erreur ici, par exemple en affichant un message
    }
  }

  Future<bool> logoutUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('nomprenom');
      await prefs.remove('email');
      await prefs.remove('isAdmin');
      await prefs.remove('documentfournirId');
      // await prefs.remove('token');  // Si vous stockez le token dans SharedPreferences
      // ... supprimez toute autre donnée utilisateur stockée ...
      return true;
    } catch (e) {
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Padding(
            padding: EdgeInsets.only(top : 25.0),
            child: Row(
              children: [
                Expanded(child: Text(" ")),
                Icon(Icons.drive_file_rename_outline_rounded, color: Colors.white,)
              ],
            ),
          ),
          _profile(),
          Expanded(
  child: Container(
    height: MediaQuery.sizeOf(context).height / 1,
    width: MediaQuery.sizeOf(context).width,
    decoration: const BoxDecoration(
      color: Colors.white,
    ),
    child: Column(
      children: [
        _cardInfo(),
        // if (widget.documentFourni.isNotEmpty) _entreprise() else _personnel(),
        if (UserData.documentfournirId.isNotEmpty) _entreprise() else _personnel(),
        const Divider(height: 25,),
        _motdepasse(),
        const Divider(height: 25,),
        _langue(),
        const Divider(height: 25,),
        // if (widget.documentFourni.isNotEmpty) _disponibilite() else _inviter(),
        if (UserData.documentfournirId.isNotEmpty) _disponibilite() else _inviter(),
        const Divider(height: 30,),
        _sedeconnecter(),
      ],
    ),
  ),
),

          
        ],
      ),
    );
  }

  Widget _profile() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _image != null ? FileImage(_image!) : null,
              child: _image == null
                  ? Image.asset(
                      "img/profile.png",
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8,),
          Column(
            children: [
              Text('${UserData.nomprenom}', style: const TextStyle(color: Colors.white),),
              Text('${UserData.email}, ${UserData.isAdmin}', style: const TextStyle(color: Colors.white),),
              const SizedBox(height: 25,)
            ],
          ),
          const SizedBox(height: 8,),
        ],
      ),
    );
  }

  Widget _cardInfo() {
    return SizedBox(
      child: Transform.translate(
        offset: const Offset(0.0, -25.0),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.06,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(25),),
              border: Border.all(width: 0.9, color: Colors.blue)
            ),
            width: MediaQuery.of(context).size.width / 1.6,
            // width: 210,
            child: Container(
              
             alignment: Alignment.center,
              child: Text(
                "Paramètres personnels",
                style: GoogleFonts.acme(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1
                  // wordSpacing: 20
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _personnel() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: InkWell(
        onTap: () {
          print("qsqs");
        },
        child: const Row(
          children: [
            Expanded(child: Text("Détails personnels", style: TextStyle(fontSize: 16,),)),
            Icon(Icons.arrow_forward_ios_rounded,),
          ],
        ),
      ),
    );
  }

  Widget _entreprise() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: InkWell(
        onTap: () {
          print("qsqs");
        },
        child: const Row(
          children: [
            Expanded(child: Text("Détails de l'entreprise", style: TextStyle(fontSize: 16,),)),
            Icon(Icons.arrow_forward_ios_rounded,),
          ],
        ),
      ),
    );
  }

  Widget _motdepasse() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: const Row(
        children: [
          Expanded(child: Text("Changer de mot de passe", style: TextStyle(fontSize: 16,),)),
          Icon(Icons.arrow_forward_ios_rounded,),
        ],
      ),
    );
  }

  Widget _langue() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: const Row(
        children: [
          Expanded(child: Text("Changer de langue", style: TextStyle(fontSize: 16,),)),
          Icon(Icons.arrow_forward_ios_rounded,),
        ],
      ),
    );
  }

  Widget _inviter() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: const Row(
        children: [
          Expanded(child: Text("Inviter des amis", style: TextStyle(fontSize: 16,),)),
          Icon(Icons.arrow_forward_ios_rounded,),
        ],
      ),
    );
  }

  Widget _disponibilite() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: const Row(
        children: [
          Expanded(child: Text("Disponibilité", style: TextStyle(fontSize: 16,),)),
          Icon(Icons.arrow_forward_ios_rounded,),
        ],
      ),
    );
  }

  Widget _sedeconnecter() {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        // color: Colors.blue,
        border: Border.all(style: BorderStyle.solid),
        borderRadius: const BorderRadius.all(Radius.circular(0.1))
      ),
      child: TextButton(onPressed: (){
        handleLogout(context);
      }, child: Row(
          children: [
            const Icon(Icons.album_rounded, color: Colors.yellow,),
            const SizedBox(width: 6,),
            Text(
              'Se déconnecter',
              style: GoogleFonts.acme(
                fontSize: 20.0,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
            )),
          ],
        )
    ));
  }
}




  // Future<void> deconnecterUtilisateur() async {
  //   try {
  //     final response = await http.get(Uri.parse('http://192.168.0.61:3000/users/logout'));

  //     if (response.statusCode == 200) {
  //       // La déconnexion a réussi
  //       print('Déconnexion réussie');
  //       // Redirigez l'utilisateur vers la page de connexion ou de bienvenue.
  //       Navigator.pushReplacementNamed(context, '/connexion');
  //     } else {
  //       // Gérer l'erreur
  //       print('Erreur lors de la déconnexion');
  //     }
  //   } catch (error) {
  //     print('Erreur lors de la déconnexion : $error');
  //   }
  // }
