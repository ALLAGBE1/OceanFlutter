// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ModelePartenaire extends StatefulWidget {
  final String id;
  final String nomprenom;
  final String email;
  final bool prestataire;
  final String domaineactivite;
  

  const ModelePartenaire({super.key, 
  required this.id,
    required this.nomprenom,
    required this.email,
    required this.prestataire, required this.domaineactivite,
    
  });

  @override
  State<ModelePartenaire> createState() => _ModelePartenaireState();
}

class _ModelePartenaireState extends State<ModelePartenaire> {
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
    final String apiUrl = 'https://ocean-52xt.onrender.com/users/partenaires/${widget.id}';
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
      // Renvoyer une liste vide en cas d'erreur
      // return [];
    }
  }

  @override
  void initState() {
    super.initState();
    isPrestataire = widget.prestataire; // Initialiser la variable d'état locale
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Detail d'un partenaire"),
      ),
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
              Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(8.0),
                // color: Colors.black54,
                child: Text(
                  "Nom : ${widget.nomprenom}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
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
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(8.0),
                // color: Colors.black54,
                child: Text(
                  "Domaine d'activité : ${widget.domaineactivite}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const Divider(height: 30,),
              // _sedeconnecter(),
              const Divider(height: 30,),
              Row(
                children: [
                  const Text("Prestataire ? :", style: TextStyle(color: Colors.white),),
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
          
    );
  }

  Widget _sedeconnecter() {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(style: BorderStyle.solid),
        borderRadius: const BorderRadius.all(Radius.circular(0.1))
      ),
      child: TextButton(onPressed: (){
        // handleLogout(context);
      }, child: Center(
        child: Text(
          'Accepter',
          style: GoogleFonts.acme(
            fontSize: 20.0,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
        )),    
      )
    ));
  }
}




