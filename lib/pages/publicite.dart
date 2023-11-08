// ignore_for_file: avoid_print, use_build_context_synchronously, depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/cupertino.dart'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocean/pages/qrcodeView.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';


bool connecte = false;

class Publicite extends StatefulWidget {
  const Publicite({super.key});

  @override
  State<Publicite> createState() => _PubliciteState();
}
class _PubliciteState extends State<Publicite> {
//  Variable pour stocker la valeur sélectionnée
  String? selectedFileName;


  Future<void> enregistrerUtilisateur() async {

    // Créez une requête multipart
    var uri = Uri.parse('https://ocean-52xt.onrender.com/publier');
    var request = http.MultipartRequest('POST', uri);

    // Vérifiez si un fichier a été choisi
    if (selectedFileName != null && selectedFileName!.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'imagepublier', // le nom du champ sur le serveur (assurez-vous qu'il correspond à ce que votre serveur attend)
        selectedFileName!, // chemin complet du fichier
        contentType: MediaType('application/json', 'jpg'), // définir le type de média pour PDF
      ));
    }

    try {
        var response = await request.send();

        if (response.statusCode == 200) {
          String responseBody = await response.stream.bytesToString();
          print('Réponse du serveur: $responseBody');
          // Votre traitement en cas de succès
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => '/home'));
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Votre traitement en cas d'erreur
          print('Erreur : ');
        }
    } catch (error) {
      print('Erreur : $error');
      // Votre traitement en cas d'erreur
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => const Enregistrement()));
                            Navigator.pushReplacementNamed(context, '/enregistrement');
                          },
                          icon: const Icon(Icons.bolt_outlined), color: Colors.yellowAccent,),
            
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                      'Publier',
                      style: GoogleFonts.acme(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                  )))),  
                  SizedBox(height: MediaQuery.sizeOf(context).height*0.030,),
                  // TextButton(onPressed: (){},
                  //   child: Text(
                  //     "Conditions générales d'utilisation",
                  //     style: GoogleFonts.acme(
                  //       color: Colors.white,
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),)
                    
                ],
              )   
            ],
          ),
        ),
      ),
    );
  }


  Widget _documentFournir() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        "Post",
        // textAlign: TextAlign.start,
        // textDirection: TextDirection.ltr,
        style: GoogleFonts.acme(
          color: Colors.white,
          fontSize: 25,
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
                allowedExtensions: ['pdf', 'jpg'], // Autorise uniquement les fichiers PDF
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
            child: Container(
              // height: 100,
              margin: const EdgeInsets.all(15),
              child: Text(
                selectedFileName ?? "           Choisir le post                ",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
}

}

