// ignore_for_file: avoid_print, use_build_context_synchronously, depend_on_referenced_packages, unnecessary_brace_in_string_interps

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocean/authentification/confirmation.dart';
import 'package:ocean/authentification/connexion.dart';
import 'package:ocean/pages/qrcodeView.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


bool connecte = false;

class Partenaire extends StatefulWidget {
  const Partenaire({super.key});

  @override
  State<Partenaire> createState() => _PartenaireState();
}
class _PartenaireState extends State<Partenaire> {
  bool _obscureText = true; // définir l'état initial comme étant masqué
  String? _chosenValue;  // Variable pour stocker la valeur sélectionnée
  String? selectedFileName;

  TextEditingController nomprenomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController nomcommercialController = TextEditingController();
  TextEditingController domaineactiviteController = TextEditingController();

  // ::::::::::::
  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    if (await Permission.location.request().isGranted) {
      _getLocation();
    }
  }

  Future<void> _getLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _longitude = position.longitude;
        _latitude = position.latitude;
        print("Longitude: $_longitude");
        print("Latitude: $_latitude");
    });
    } catch (e) {
      print('Erreur lors de l\'obtention de la position : $e');
      // Gérer l'erreur de géolocalisation ici
    }
  }

// :::::::::::

  Future<void> enregistrerUtilisateur() async {
    String nomprenom = nomprenomController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String username = usernameController.text;
    String nomcommercial = nomcommercialController.text;
    String domaineactivite = domaineactiviteController.text;

    // Créez une requête multipart
    var uri = Uri.parse('http://192.168.0.61:3000/users/sinscrire');
    var request = http.MultipartRequest('POST', uri)
      ..fields['nomprenom'] = nomprenom
      ..fields['email'] = email
      ..fields['username'] = username
      ..fields['password'] = password
      ..fields['nomcommercial'] = nomcommercial
      ..fields['domaineactivite'] = domaineactivite
      ..fields['location'] = jsonEncode({
        'type': 'Point',
        'coordinates': [_longitude, _latitude]
      });

      print('Réponse du ppppppppppppppppppppppppppppp: ${request}');

    // Vérifiez si un fichier a été choisi
    if (selectedFileName != null && selectedFileName!.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'documentfournirId', // le nom du champ sur le serveur (assurez-vous qu'il correspond à ce que votre serveur attend)
        selectedFileName!, // chemin complet du fichier
        contentType: MediaType('application/json', 'pdf'), // définir le type de média pour PDF
      ));
    }

    try {
      print('Réponse du serveur: 111111111111111111111111111');
      var response = await request.send();
      print('Réponse du serveur: 2222222222222222222222222222');
      // Vérifier la réponse du serveur
      if (response.statusCode == 200) {
        print('Réponse du serveur: 3333333333333333333333333333');
        // Vous pouvez également convertir la réponse en texte pour obtenir des détails
        String responseBody = await response.stream.bytesToString();
        print('Réponse du serveur: 4444444444444444444444444444444444');
        print('Réponse du serveur: $responseBody');
        print('Réponse du serveur: 555555555555555555555555555555555');
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
                    Navigator.push(
                    context,
                    // MaterialPageRoute(
                    //     builder: (context) => const Connexion())
                    MaterialPageRoute(
                        builder: (context) => const ConfirmationScreen())
                  );
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Erreur lors de l'enregistrement
        print('Réponse du serveur: 6666666666666666666666666666666');
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


  Future<List<String>> fetchDomainesActivite() async {
    final response = await http.get(Uri.parse('http://192.168.0.61:3000/domaineActivite/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final fetchedDomaineActivites = data.map((item) => item['domaineactivite'] as String).toList();

      return fetchedDomaineActivites;
    } else {
      throw Exception('Failed to fetch data from MongoDB');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                  Padding(
                    padding: const EdgeInsets.only(top: 38),
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
                            Navigator.pushReplacementNamed(context, '/enregistrement');
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
                  SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                  _username(),
                  _vusername(),
                  SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                  _email(),
                  _vemail(),
                  SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                  // SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                  _motdepasse(),
                  _vmotdepasse(),
                  SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                  _nomCommercial(),
                  _vnomCommercial(),
                  SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                  _domaineActivite(),
                  _vdomaineActivite(),
                  SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                  _documentFournir(),
                  _vdocumentFournir(),
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
      margin: const EdgeInsets.all(10),
      child: CupertinoTextField(
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

  Widget _nomCommercial() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        "Nom commercial",
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

  Widget _vnomCommercial() {
    return Container(
      height: 58,
      margin: const EdgeInsets.all(10),
      child: CupertinoTextField(
        controller: nomcommercialController,
        placeholder: "Nom commercial",
        decoration: BoxDecoration(
          border: Border.all(color: Colors.greenAccent),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _domaineActivite() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        "Domaine d'activité",
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

  Widget _vdomaineActivite() {
    return Container(
      height: 58,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.greenAccent),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: FutureBuilder<List<String>>(
        future: fetchDomainesActivite(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('Aucun domaine trouvé.');
          } else {
            List<String> domaines = snapshot.data!;
            return DropdownButtonFormField<String>(
              decoration: const InputDecoration.collapsed(hintText: 'Exemple : Plombier'),
              isExpanded: true,
              value: _chosenValue,
              items: domaines.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _chosenValue = value;
                  domaineactiviteController.text = value!;
                });
              },
            );
          }
        },
      ),
    );
}

  Widget _documentFournir() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        "Documents à fournir",
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

  Widget _vdocumentFournir() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Material(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.greenAccent),
            borderRadius: BorderRadius.circular(5),
          ),
          child: InkWell(
            onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'], // Autorise uniquement les fichiers PDF
              );

              if (result != null) {
                PlatformFile file = result.files.first;
                // selectedFileName = file.name;
                selectedFileName = file.path;
                setState(() {}); // Cela déclenchera une reconstruction de l'interface utilisateur
                print("Nom du fichier : ${file.name}");
                print("Taille du fichier : ${file.size} bytes");
                print("Extension du fichier : ${file.extension}");
                print("Chemin d'accès complet : ${file.path}");
              }
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedFileName ?? "Exemple : Carte commercant",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                CupertinoButton(
                  
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    Icons.qr_code_scanner, // Icône de scanner
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QRViewExample()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
}
}



  // Widget _vdomaineActivite() {
  //   return Container(
  //     margin: const EdgeInsets.all(10),
  //     padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.greenAccent),
  //       borderRadius: BorderRadius.circular(5),
  //       color: Colors.white,
  //     ),
  //     child: DropdownButtonFormField<String>(
  //       decoration: const InputDecoration.collapsed(hintText: 'Exemple : Plombier'),
  //       isExpanded: true,  // Pour que le dropdown prenne toute la largeur du conteneur
  //       value: _chosenValue,
  //       items: <String>['plombier', 'mécanicien', 'vitrier', 'vulgarisateur'].map<DropdownMenuItem<String>>((String value) {
  //         return DropdownMenuItem<String>(
  //           value: value,
  //           child: Text(value),
  //         );
  //         }).toList(),
  //         onChanged: (String? value) {
  //           setState(() {
  //             _chosenValue = value;
  //           });
  //         },
  //       ),
  //     );
  // }



 // Future<void> enregistrerUtilisateur() async {
  //   String nomprenom = nomprenomController.text;
  //   String email = emailController.text;
  //   String password = passwordController.text;
  //   String username = usernameController.text;
  //   String nomcommercial = nomcommercialController.text;
  //   String domaineactivite = domaineactiviteController.text;


  //   // Effectuer la requête HTTP vers l'API Node.js pour enregistrer l'utilisateur
  //   try {
  //     var response = await http.post(
  //       Uri.parse('http://192.168.1.13:3000/users/sinscrire'),
  //       body: {
  //         'nomprenom': nomprenom,
  //         'email': email,
  //         'username': username,
  //         'password': password,
  //         'nomcommercial': nomcommercial,
  //         'domaineactivite': domaineactivite,
  //       },
  //     );

  //     // Vérifier la réponse du serveur
  //     if (response.statusCode == 200) {
  //       // Enregistrement réussi
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: const Text('Succès'),
  //             content: const Text('L\'utilisateur a été enregistré avec succès.'),
  //             actions: [
  //               TextButton(
  //                 child: const Text('OK'),
  //                 onPressed: () {
  //                   // Navigator.of(context).pop();
  //                   // setState(() {
  //                   //   nomController.text = "";
  //                   //   prenomController.text = "";
  //                   //   emailController.text = "";
  //                   //   passwordController.text = "";
  //                   //   usernameController.text = "";
  //                   //   confirmationController.text = "";
  //                   // });
  //                   Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                       builder: (context) => const Connexion()));
  //                 },
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     } else {
  //       // Erreur lors de l'enregistrement
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: const Text('Erreur'),
  //             content: const Text('Une erreur est survenue lors de l\'enregistrement de l\'utilisateur.'),
  //             actions: [
  //               TextButton(
  //                 child: const Text('OK'),
  //                 onPressed: () {
  //                   // setState(() {
  //                   //   nomController.text = "";
  //                   //   prenomController.text = "";
  //                   //   emailController.text = "";
  //                   //   passwordController.text = "";
  //                   //   usernameController.text = "";
  //                   //   confirmationController.text = "";
  //                   // });
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     }
  //   } catch (error) {
  //     print('Erreur : $error');
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Erreur'),
  //           content: const Text('Une erreur est survenue lors de la connexion au serveur.'),
  //           actions: [
  //             TextButton(
  //               child: const Text('OK'),
  //               onPressed: () {
  //                 // setState(() {
  //                 //   nomController.text = "";
  //                 //   prenomController.text = "";
  //                 //   emailController.text = "";
  //                 //   passwordController.text = "";
  //                 //   usernameController.text = "";
  //                 //   confirmationController.text = "";
  //                 // });
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

//   Widget _vdocumentFournir() {
//   return Container(
//     margin: const EdgeInsets.all(10),
//     child: GestureDetector(
//       onTap: () async {
//         FilePickerResult? result = await FilePicker.platform.pickFiles();

//         if (result != null) {
//           PlatformFile file = result.files.first;
//           selectedFileName = file.name;
//           setState(() {}); // Cela déclenchera une reconstruction de l'interface utilisateur
//         }
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.greenAccent),
//           borderRadius: BorderRadius.circular(5),
//           color: Colors.white,
//         ),
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 selectedFileName ?? "Exemple : Carte commercant",
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//             const Icon(
//               Icons.qr_code_scanner, // Icône de scanner
//               color: Colors.grey,
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }


//   Widget _vdocumentFournir() {
//     return Container(
//       margin: const EdgeInsets.all(10),
//       child: CupertinoTextField(
//         // controller: usernameController,
//         placeholder: selectedFileName ?? "Exemple : Carte commercant",
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.greenAccent),
//           borderRadius: BorderRadius.circular(5),
//           color: Colors.white,
//         ),
//         suffix: CupertinoButton(
//           padding: EdgeInsets.zero,
//           child: const Icon(
//             Icons.qr_code_scanner, // Icône de scanner
//             color: Colors.grey,
//           ),
//           onPressed: () async {
//             FilePickerResult? result = await FilePicker.platform.pickFiles();

//             if (result != null) {
//               PlatformFile file = result.files.first;
//               selectedFileName = file.name;
//               setState((){}); // Cela déclenchera une reconstruction de l'interface utilisateur
//               print("Nom du fichier : ${file.name}");
//               print("Taille du fichier : ${file.size} bytes");
//               print("Extension du fichier : ${file.extension}");
//               print("Chemin d'accès complet : ${file.path}");

//               // Vous pouvez ajouter des actions supplémentaires ici pour gérer le fichier sélectionné
//             } else {
//               // L'utilisateur a annulé la sélection
//             }
//           },
//         ),
//       ),
//     );
// }


  // Widget _vdocumentFournir() {
  //   return Container(
  //     margin: const EdgeInsets.all(10),
  //     child: CupertinoTextField(
  //       // controller: usernameController,
  //       placeholder: "Exemple : Carte commercant",
  //       decoration: BoxDecoration(
  //         border: Border.all(color: Colors.greenAccent),
  //         borderRadius: BorderRadius.circular(5),
  //         color: Colors.white,
  //       ),
  //       suffix: CupertinoButton(
  //         padding: EdgeInsets.zero,
  //         child: const Icon(
  //           Icons.qr_code_scanner,  // Icône de scanner
  //           color: Colors.grey,
  //         ),
  //         onPressed: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const QRViewExample()),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }


  // :::::::::::

//   // ignore_for_file: avoid_print, use_build_context_synchronously

// import 'dart:convert';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ocean/authentification/connexion.dart';
// import 'package:ocean/authentification/enregistrement.dart';
// import 'package:ocean/pages/qrcodeView.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';

// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';


// bool connecte = false;

// class Partenaire extends StatefulWidget {
//   const Partenaire({super.key});

//   @override
//   State<Partenaire> createState() => _PartenaireState();
// }
// class _PartenaireState extends State<Partenaire> {
//   bool _obscureText = true; // définir l'état initial comme étant masqué
//   String? _chosenValue;  // Variable pour stocker la valeur sélectionnée
//   String? selectedFileName;

//   // // ::::::::::::: Géolocalisation
//   // String _locationMessage1 = '';
//   // String _locationMessage2 = '';

//   // @override
//   // void initState() {
//   //     super.initState();
//   //     _checkPermission();
//   // }

//   // Future<void> _checkPermission() async {
//   //   if (await Permission.location.request().isGranted) {
//   //       _getLocation();
//   //   }
//   // }

//   // Future<void> _getLocation() async {
//   //   final position = await Geolocator.getCurrentPosition(
//   //                           desiredAccuracy: LocationAccuracy.best);
//   //   final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
//   //   setState(() {
//   //       _locationMessage1 = placemarks.first.street ?? ''; 
//   //       _locationMessage2 = placemarks.last.name ?? ''; 
//   //   });
//   // }

//   // // :::::::::::::::::::::

//   TextEditingController nomprenomController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController usernameController = TextEditingController();
//   TextEditingController nomcommercialController = TextEditingController();
//   TextEditingController domaineactiviteController = TextEditingController();

// // ::::::::::::
//   String _locationMessage1 = '';
//   String _locationMessage2 = '';

//   @override
//   void initState() {
//     super.initState();
//     _checkPermission();
//   }

//   Future<void> _checkPermission() async {
//     if (await Permission.location.request().isGranted) {
//       _getLocation();
//     }
//   }

//   Future<void> _getLocation() async {
//     try {
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.best,
//       );
//       // final placemarks = await placemarkFromCoordinates(
//       //   position.latitude,
//       //   position.longitude,
//       // );
//       // setState(() {
//       //   _locationMessage1 = placemarks.first.street ?? '';
//       //   _locationMessage2 = placemarks.first.name ?? '';
//       // });
//       setState(() {
//         _locationMessage1 = '${position.latitude}';
//         _locationMessage2 = '${position.longitude}';
//       });
//     } catch (e) {
//       print('Erreur lors de l\'obtention de la position : $e');
//       // Gérer l'erreur de géolocalisation ici
//     }
//   }

// // :::::::::::

//   Future<void> enregistrerUtilisateur() async {
//     String nomprenom = nomprenomController.text;
//     String email = emailController.text;
//     String password = passwordController.text;
//     String username = usernameController.text;
//     String nomcommercial = nomcommercialController.text;
//     String domaineactivite = domaineactiviteController.text;

//     // Créez une requête multipart
//     var uri = Uri.parse('http://192.168.0.61:3000/users/sinscrire');
//     var request = http.MultipartRequest('POST', uri)
//       ..fields['nomprenom'] = nomprenom
//       ..fields['email'] = email
//       ..fields['username'] = username
//       ..fields['password'] = password
//       ..fields['nomcommercial'] = nomcommercial
//       ..fields['domaineactivite'] = domaineactivite;
//       // ..fields['latitude'] = _locationMessage1
//       // ..fields['longitude'] = _locationMessage2;
//       // ..fields['location'] = jsonEncode({
//       //     'type': 'Point',
//       //     'coordinates': [_locationMessage1, _locationMessage2]
//       //   });
//       // ..fields['location'] = jsonEncode({
//       //   'type': 'Point',
//       //   'coordinates': [_locationMessage1, _locationMessage2]
//       // });

//     // Vérifiez si un fichier a été choisi
//     if (selectedFileName != null && selectedFileName!.isNotEmpty) {
//       request.files.add(await http.MultipartFile.fromPath(
//         'documentfournirId', // le nom du champ sur le serveur (assurez-vous qu'il correspond à ce que votre serveur attend)
//         selectedFileName!, // chemin complet du fichier
//         contentType: MediaType('application/json', 'pdf'), // définir le type de média pour PDF
//       ));
//     }

//     try {
//       var response = await request.send();

//       // Vérifier la réponse du serveur
//       if (response.statusCode == 200) {
//         // Vous pouvez également convertir la réponse en texte pour obtenir des détails
//         String responseBody = await response.stream.bytesToString();
        
//         print('Réponse du serveur: $responseBody');
//         // Enregistrement réussi
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Succès'),
//               content: const Text('L\'utilisateur a été enregistré avec succès.'),
//               actions: [
//                 TextButton(
//                   child: const Text('OK'),
//                   onPressed: () {
//                     // Navigator.of(context).pop();
//                     // setState(() {
//                     //   nomController.text = "";
//                     //   prenomController.text = "";
//                     //   emailController.text = "";
//                     //   passwordController.text = "";
//                     //   usernameController.text = "";
//                     //   confirmationController.text = "";
//                     // });
//                     Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const Connexion()));
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       } else {
//         // Erreur lors de l'enregistrement
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Erreur'),
//               content: const Text('Une erreur est survenue lors de l\'enregistrement de l\'utilisateur.'),
//               actions: [
//                 TextButton(
//                   child: const Text('OK'),
//                   onPressed: () {
//                     // setState(() {
//                     //   nomController.text = "";
//                     //   prenomController.text = "";
//                     //   emailController.text = "";
//                     //   passwordController.text = "";
//                     //   usernameController.text = "";
//                     //   confirmationController.text = "";
//                     // });
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     } catch (error) {
//       print('Erreur : $error');
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Erreur'),
//             content: const Text('Une erreur est survenue lors de la connexion au serveur.'),
//             actions: [
//               TextButton(
//                 child: const Text('OK'),
//                 onPressed: () {
//                   // setState(() {
//                   //   nomController.text = "";
//                   //   prenomController.text = "";
//                   //   emailController.text = "";
//                   //   passwordController.text = "";
//                   //   usernameController.text = "";
//                   //   confirmationController.text = "";
//                   // });
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }


//   Future<List<String>> fetchDomainesActivite() async {
//     final response = await http.get(Uri.parse('http://192.168.0.61:3000/domaineActivite/'));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body) as List<dynamic>;
//       final fetchedDomaineActivites = data.map((item) => item['domaineactivite'] as String).toList();

//       return fetchedDomaineActivites;
//     } else {
//       throw Exception('Failed to fetch data from MongoDB');
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//           width: MediaQuery.sizeOf(context).width,
//           // height: MediaQuery.sizeOf(context).height,
//           decoration: BoxDecoration(
//               color: Colors.grey,
//               border: Border.all(color: Colors.grey, width: 1.5),
//               image: const DecorationImage(image: AssetImage('img/background.jpg'), fit: BoxFit.cover) // Changed Image.asset to AssetImage
//             ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(top: 38),
//                     child: Center(child: Image.asset("img/logo.png", 
//                       // height: MediaQuery.sizeOf(context).height*0.30, 
//                       width: MediaQuery.sizeOf(context).width*0.50,
//                     ),),
//                   ),
//                   SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                           onPressed: () {
//                             // Navigator.push(
//                             //     context,
//                             //     MaterialPageRoute(
//                             //         builder: (context) => const Enregistrement()));
//                             Navigator.pushReplacementNamed(context, '/enregistrement');
//                           },
//                           icon: const Icon(Icons.bolt_outlined), color: Colors.yellowAccent,),
//                       _entetetext(),
//                     ],
//                   ),
//                 ],
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _nomprenom(),
//                   _vnomprenom(),
//                   SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
//                   _username(),
//                   _vusername(),
//                   SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
//                   _email(),
//                   _vemail(),
//                   SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
//                   // SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
//                   _motdepasse(),
//                   _vmotdepasse(),
//                   SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
//                   _nomCommercial(),
//                   _vnomCommercial(),
//                   SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
//                   _domaineActivite(),
//                   _vdomaineActivite(),
//                   SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
//                   _documentFournir(),
//                   _vdocumentFournir(),
//                   // _connect()
//                 ],
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     width: 180,
//                     decoration: BoxDecoration(
//                       // color: Colors.blue,
//                       border: Border.all(style: BorderStyle.solid, color: Colors.white),
//                       borderRadius: const BorderRadius.all(Radius.circular(0.1))
//                     ),
//                     child: TextButton(onPressed: (){
//                       enregistrerUtilisateur();
//                     }, child: Text(
//                       'Continuer',
//                       style: GoogleFonts.acme(
//                         fontSize: 20.0,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                   )))),  
//                   SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
//                   TextButton(onPressed: (){},
//                     child: Text(
//                       "Conditions générales d'utilisation",
//                       style: GoogleFonts.acme(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),)
                    
//                 ],
//               )   
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _entetetext() {
//     return Container(
//       child: Text(
//         "Créer un compte",
//         style: GoogleFonts.acme(
//           color: Colors.white,
//           fontSize: 28,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _nomprenom() {
//     return Container(
//       alignment: Alignment.bottomLeft,
//       padding: const EdgeInsets.only(left: 10.0),
//       child: Text(
//         "Nom et prénom",
//         // textAlign: TextAlign.start,
//         // textDirection: TextDirection.ltr,
//         style: GoogleFonts.acme(
//           color: Colors.white,
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _vnomprenom() {
//     return Container(
//       height: 58,
//       margin: const EdgeInsets.all(10),
//       child: CupertinoTextField(
//         controller: nomprenomController,
//         placeholder: "Nom et prénom",
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.greenAccent),
//           borderRadius: BorderRadius.circular(5),
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _username() {
//     return Container(
//       alignment: Alignment.bottomLeft,
//       padding: const EdgeInsets.only(left: 10.0),
//       child: Text(
//         "Username",
//         // textAlign: TextAlign.start,
//         // textDirection: TextDirection.ltr,
//         style: GoogleFonts.acme(
//           color: Colors.white,
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _vusername() {
//     return Container(
//       height: 58,
//       margin: const EdgeInsets.all(10),
//       child: CupertinoTextField(
//         controller: usernameController,
//         placeholder: "Username",
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.greenAccent),
//           borderRadius: BorderRadius.circular(5),
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _email() {
//     return Container(
//       alignment: Alignment.bottomLeft,
//       padding: const EdgeInsets.only(left: 10.0),
//       child: Text(
//         "Numéro de téléphone ou Email",
//         style: GoogleFonts.acme(
//           color: Colors.white,
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _vemail() {
//     return Container(
//       height: 58,
//       margin: const EdgeInsets.all(10),
//       child: CupertinoTextField(
//         controller: emailController,
//         placeholder: "Numéro de téléphone ou Email",
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.greenAccent),
//           borderRadius: BorderRadius.circular(5),
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _motdepasse() {
//     return Container(
//       alignment: Alignment.bottomLeft,
//       padding: const EdgeInsets.only(left: 10.0),
//       child: Text(
//         "Créer un mot de passe",
//         style: GoogleFonts.acme(
//           color: Colors.white,
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _vmotdepasse() {
//     return Container(
//       margin: const EdgeInsets.all(10),
//       child: CupertinoTextField(
//         // Radius cursorRadius = const Radius.circular(2.0),
//         // bool cursorOpacityAnimates = true,
//         // Color? cursorColor,
//         controller: passwordController,
//         obscureText: _obscureText,
//         placeholder: "Créer un mot de passe",
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.greenAccent),
//           borderRadius: BorderRadius.circular(5),
//           color: Colors.white,
//         ),
//         suffix: CupertinoButton(
//           // padding: EdgeInsets.zero,
//           child: Icon(
//             _obscureText ? Icons.visibility : Icons.visibility_off,
//             color: Colors.grey,
//           ),
//           onPressed: () {
//             setState(() {
//               _obscureText = !_obscureText;
//             });
//           },
//         ),
//       ),
//     );
//   }

//   Widget _nomCommercial() {
//     return Container(
//       alignment: Alignment.bottomLeft,
//       padding: const EdgeInsets.only(left: 10.0),
//       child: Text(
//         "Nom commercial",
//         // textAlign: TextAlign.start,
//         // textDirection: TextDirection.ltr,
//         style: GoogleFonts.acme(
//           color: Colors.white,
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _vnomCommercial() {
//     return Container(
//       height: 58,
//       margin: const EdgeInsets.all(10),
//       child: CupertinoTextField(
//         controller: nomcommercialController,
//         placeholder: "Nom commercial",
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.greenAccent),
//           borderRadius: BorderRadius.circular(5),
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _domaineActivite() {
//     return Container(
//       alignment: Alignment.bottomLeft,
//       padding: const EdgeInsets.only(left: 10.0),
//       child: Text(
//         "Domaine d'activité",
//         // textAlign: TextAlign.start,
//         // textDirection: TextDirection.ltr,
//         style: GoogleFonts.acme(
//           color: Colors.white,
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _vdomaineActivite() {
//     return Container(
//       height: 58,
//       margin: const EdgeInsets.all(10),
//       padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.greenAccent),
//         borderRadius: BorderRadius.circular(5),
//         color: Colors.white,
//       ),
//       child: FutureBuilder<List<String>>(
//         future: fetchDomainesActivite(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const CircularProgressIndicator();
//           } else if (snapshot.hasError) {
//             return Text('Erreur: ${snapshot.error}');
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Text('Aucun domaine trouvé.');
//           } else {
//             List<String> domaines = snapshot.data!;
//             return DropdownButtonFormField<String>(
//               decoration: const InputDecoration.collapsed(hintText: 'Exemple : Plombier'),
//               isExpanded: true,
//               value: _chosenValue,
//               items: domaines.map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               onChanged: (String? value) {
//                 setState(() {
//                   _chosenValue = value;
//                   domaineactiviteController.text = value!;
//                 });
//               },
//             );
//           }
//         },
//       ),
//     );
// }

//   Widget _documentFournir() {
//     return Container(
//       alignment: Alignment.bottomLeft,
//       padding: const EdgeInsets.only(left: 10.0),
//       child: Text(
//         "Documents à fournir",
//         // textAlign: TextAlign.start,
//         // textDirection: TextDirection.ltr,
//         style: GoogleFonts.acme(
//           color: Colors.white,
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _vdocumentFournir() {
//     return Container(
//       margin: const EdgeInsets.all(10),
//       child: Material(
//         borderRadius: BorderRadius.circular(5),
//         color: Colors.white,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.greenAccent),
//             borderRadius: BorderRadius.circular(5),
//           ),
//           child: InkWell(
//             onTap: () async {
//               FilePickerResult? result = await FilePicker.platform.pickFiles(
//                 type: FileType.custom,
//                 allowedExtensions: ['pdf'], // Autorise uniquement les fichiers PDF
//               );

//               if (result != null) {
//                 PlatformFile file = result.files.first;
//                 // selectedFileName = file.name;
//                 selectedFileName = file.path;
//                 setState(() {}); // Cela déclenchera une reconstruction de l'interface utilisateur
//                 print("Nom du fichier : ${file.name}");
//                 print("Taille du fichier : ${file.size} bytes");
//                 print("Extension du fichier : ${file.extension}");
//                 print("Chemin d'accès complet : ${file.path}");
//               }
//             },
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     selectedFileName ?? "Exemple : Carte commercant",
//                     style: const TextStyle(color: Colors.grey),
//                   ),
//                 ),
//                 CupertinoButton(
                  
//                   padding: EdgeInsets.zero,
//                   child: const Icon(
//                     Icons.qr_code_scanner, // Icône de scanner
//                     color: Colors.grey,
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const QRViewExample()),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
// }

// }
