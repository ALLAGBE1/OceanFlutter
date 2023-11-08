// ignore_for_file: unnecessary_string_interpolations, use_build_context_synchronously, depend_on_referenced_packages, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocean/authentification/user_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocean/modeles/detailEntreprise.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';


class CompteClient extends StatefulWidget {
  final String documentFourni;
  // print(documentFourni);
  const CompteClient({Key? key, required this.documentFourni}) : super(key: key);
  

  @override
  State<CompteClient> createState() => _CompteClientState();
}

class _CompteClientState extends State<CompteClient> {
  // bool isPrestataire = true; // Utiliser une variable d'état locale
  // bool isPrestataire = UserData.disponible; // Utiliser une variable d'état locale
  // bool isPrestataire ? UserData.disponible : newState; // Utiliser une variable d'état locale
  bool isPrestataire = true; // Utiliser une variable d'état locale
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // ::::::::::::::
  bool isDisponible = false; // Utiliser une variable d'état locale

  @override
  void initState() {
    super.initState();
    // isPrestataire = UserData.disponible;
    
    // Appel de la fonction pour obtenir la photo de profil de l'utilisateur
    // getProfilePhoto(UserData.id);
  }

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );


  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
        // Appeler la fonction pour télécharger l'image ici
        // postPhotoProfil();
      }
    });
  }


  // Fonction pour mettre à jour l'état du partenaire
  Future<void> updatePrestataireState(bool newState) async {
    final String apiUrl = 'https://ocean-52xt.onrender.com/users/prestataires/${UserData.id}';
    print("Donne moi l'url : " + apiUrl);
    try {
      final response = await http.put(
        Uri.parse('${apiUrl}'),
        body: {'disponible': newState.toString()},
      );

      if (response.statusCode == 200) {
        setState(() {
          isPrestataire = newState;
        });
        print('État de la disponibilité du prestataire mis à jour avec succès');
      } else {
        print('Erreur lors de la mise à jour de l\'état de la disponibilité');
      }
    } catch (error) {
      print('Erreur lors de la requête HTTP : $error');
    }
  }

//   Future<void> getProfilePhoto(String userId) async {
//   try {
//     final response = await http.get(Uri.parse('https://ocean-52xt.onrender.com/photoProfils/profilUser/${UserData.id}'));
//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       if (data.isNotEmpty) {
//         Map<String, dynamic> photoData = data.first;
//         String photoUrl = photoData['photoProfil'];
//         setState(() {
//           _image = File(photoUrl);
//         });
//       } else {
//         print('Aucune photo de profil trouvée pour l\'utilisateur');
//       }
//     } else {
//       print('Erreur: ${response.reasonPhrase}');
//     }
//   } catch (error) {
//     print('Erreur: $error');
//   }
// }


  Future<void> postPhotoProfil() async {
  if (_image != null) {
    print('UserID: ${UserData.id}'); // Vérifier la valeur de l'ID de l'utilisateur
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.MultipartRequest('POST', Uri.parse('https://ocean-52xt.onrender.com/photoProfils'));
    request.fields.addAll({
      'userId': UserData.id
    });
    request.files.add(await http.MultipartFile.fromPath('photoProfil', _image!.path));

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
  } else {
    print('Image not selected');
  }
}


  void handleLogout(BuildContext context) async {
    bool success = await logoutUser();
    if (success) {
      // Redirigez vers la page de connexion
      Navigator.pushReplacementNamed(context, '/connexion');
      
    } else {
      // Gérez l'erreur ici, par exemple en affichant un message
    }
  }

  Future<bool> logoutUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('id');
      await prefs.remove('nomprenom');
      await prefs.remove('email');
      await prefs.remove('isAdmin');
      await prefs.remove('documentfournirId');
      await prefs.remove('disponible');
      await prefs.remove('nomcommercial');
      await prefs.remove('domaineactivite');
      await prefs.remove('latitude');
      await prefs.remove('longitude');
      await prefs.remove('nomDuLieu');
     
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
                  // const Divider(height: 25,),
                  // _langue(),
                  const Divider(height: 25,),
                  // if (widget.documentFourni.isNotEmpty) _disponibilite() else _inviter(),
                  if (UserData.documentfournirId.isNotEmpty) _disponibilite() else _inviter(),
                  // const Divider(height: 30,),
                  const Divider(height: 70,),
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
            child: _image != null
                ? Image.file(
                    _image!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : (UserData.photoProfil != null && UserData.photoProfil.isNotEmpty)
                    ? ClipOval(
                        child: Image.network(
                          UserData.photoProfil,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                      Icons.person,
                      size: 80,
                      ),
          ),
        ),
        const SizedBox(height: 8,),
        Column(
          children: [
            // Text('${UserData.nomprenom}, ${UserData.id}', style: const TextStyle(color: Colors.white),),
            Text('${UserData.nomprenom}', style: const TextStyle(color: Colors.white),),
            // Text('${UserData.email}, ${UserData.isAdmin}', style: const TextStyle(color: Colors.white),),
            Text('${UserData.email}', style: const TextStyle(color: Colors.white),),
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
          print("qsqs 111111");
          
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
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DetailEntreprise(),
              ),
          );
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


  Widget _inviter() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: InkWell(
        onTap: () {
          print("Bonjour");
          _inviteFriends();
        },
        child: const Row(
          children: [
            Expanded(
              child: Text("Inviter des amis", style: TextStyle(fontSize: 16,)),
            ),
            Icon(Icons.arrow_forward_ios_rounded,),
          ],
        ),
      ),
    );
  }

  void _inviteFriends() {
    // Définissez le message que vous souhaitez partager
    String message = "Téléchargez notre application depuis ce lien : https://play.google.com/store/apps/details?id=com.yourcompany.yourapp";

    // Utilisez la méthode `share` pour partager le message
    Share.share(message);
  }

  Widget _disponibilite() {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          const Expanded(child: Text("Disponibilité ?", style: TextStyle(fontSize: 16,),)),
          // Icon(Icons.arrow_forward_ios_rounded,),
          Switch(
            activeColor: Colors.green,
            thumbIcon: thumbIcon,
            value: isPrestataire,
            onChanged: (bool value) {
              setState(() {
                // isPrestataire = value;
                updatePrestataireState(value);
              });
            },
          ),
          // Switch(
          //   activeColor: Colors.green,
          //   thumbIcon: thumbIcon,
          //   // value: isDisponible,
          //   value: UserData.disponible,
          //   onChanged: (bool value) {
          //     setState(() {
          //       // isDisponible = value;
          //       // updatePrestataireState(value);
          //       UserData.disponible;
          //     });
          //   },
          // ),
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