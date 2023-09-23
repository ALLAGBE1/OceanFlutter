// ignore_for_file: prefer_interpolation_to_compose_strings, unnecessary_string_interpolations

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ocean/authentification/user_data.dart';

class ModelePrestataire extends StatefulWidget {
  final String id;
  final String nomprenom;
  final String email;
  final bool prestataire;
  final String domaineactivite;

  

  const ModelePrestataire({super.key, 
  required this.id,
    required this.nomprenom,
    required this.email,
    required this.prestataire, required this.domaineactivite, 
    
  });

  @override
  State<ModelePrestataire> createState() => _ModelePrestataireState();
}

class _ModelePrestataireState extends State<ModelePrestataire> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isPrestataire = false; // Utiliser une variable d'état locale

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  

  // Fonction pour mettre à jour l'état du partenaire
  Future<void> updatePrestataireState(bool newState) async {
    final String apiUrl = 'http://192.168.0.61:3000/users/partenaires/${widget.id}';
    print("Donne moi l'url : " + apiUrl);
    try {
      final response = await http.put(
        Uri.parse('${apiUrl}'),
        body: {'prestataire': newState.toString()},
      );

      if (response.statusCode == 200) {
        setState(() {
          isPrestataire = newState;
        });
        print('État du partenaire mis à jour avec succès');
      } else {
        print('Erreur lors de la mise à jour de l\'état du partenaire');
      }
    } catch (error) {
      print('Erreur lors de la requête HTTP : $error');
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      }
    });
  }


  @override
  void initState() {
    super.initState();
    isPrestataire = widget.prestataire; // Initialiser la variable d'état locale
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        decoration: BoxDecoration(
            color: Colors.grey,
            border: Border.all(color: Colors.grey, width: 1.5),
            image: const DecorationImage(image: AssetImage('img/background.jpg'), fit: BoxFit.cover) // Changed Image.asset to AssetImage
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top : 25.0),
                child: Row(
                  children: [
                    Expanded(child: Text(" ")),
                    // Icon(Icons.drive_file_rename_outline_rounded, color: Colors.white,)
                  ],
                ),
              ),
              _profile(),
              const Divider(height: 0, indent: 20, endIndent: 20,),
              Expanded(
                child: Container(
                  height: MediaQuery.sizeOf(context).height / 1,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(8.0),
                        // color: Colors.black54,
                        child: Text(
                          "Nom : ${widget.nomprenom}",
                          style: const TextStyle(
                            fontSize: 16,
                            // color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(8.0),
                        // color: Colors.black54,
                        child: Text(
                          "Email : ${widget.email}",
                          style: const TextStyle(
                            fontSize: 16,
                            // color: Colors.white,
                          ),
                        ),
                      ),
                      const Divider(height: 30,),
                      Row(
                        children: [
                          const Text("Prestataire ? :", style: TextStyle(
                            // color: Colors.white
                          ),),
                          const SizedBox(width: 5,),
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
                ],
              ),
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
              Text('${widget.nomprenom}', style: const TextStyle(color: Colors.white, fontSize: 20),),
              Text('${widget.domaineactivite}', style: const TextStyle(color: Colors.white, fontSize: 20),),
              const SizedBox(height: 5,)
            ],
          ),
          const SizedBox(height: 8,),
        ],
      ),
    );
  }

}




