// ignore_for_file: unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Parametres extends StatefulWidget {
  const Parametres({super.key});

  @override
  State<Parametres> createState() => _ParametresState();
}

class _ParametresState extends State<Parametres> {

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
                Text(" ")
              ],
            ),
          ),
          _profile(),
          Expanded(
            child: Container(
              height: MediaQuery.sizeOf(context).height/1,
              width: MediaQuery.sizeOf(context).width,
              decoration: const BoxDecoration(
                color: Colors.white
              ),
              child: Column(
                children: [
                  _cardInfo(),
                  _confidentialites(),
                  const Divider(height: 25,),
                  _termesConditions(context),
                  const Divider(height: 25,),
                  _aproposdeNous(context),
                  const Divider(height: 25,),
                  _faq(),
                  const Divider(height: 30,),
                  _contactezNous(context)
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
          Container(
            decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white
          ), child: const Icon(Icons.settings , color: Colors.blue, size: 95,)
          ),
          const SizedBox(height: 8,),
          const Column(
            children: [
              Text(' ', style: TextStyle(color: Colors.white),),
              Text(' ', style: TextStyle(color: Colors.white),),
              SizedBox(height: 25,)
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
                "Paramètres géréraux",
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

  // Widget _confidentialites() {
  //   return Container(
  //     padding: const EdgeInsets.all(15),
  //     child: InkWell(
  //       onTap: () {
  //         print("qsqs");
  //       },
  //       child: const Row(
  //         children: [
  //           Expanded(child: Text("Confidentialités", style: TextStyle(fontSize: 16,),)),
  //           Icon(Icons.arrow_forward_ios_rounded,),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _confidentialites() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: InkWell(
        onTap: () {
          _showConditionsDialog(context);
        },
        child: const Row(
          children: [
            Expanded(child: Text("Confidentialités", style: TextStyle(fontSize: 16,),)),
            Icon(Icons.arrow_forward_ios_rounded,),
          ],
        ),
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
}

  // Widget _termesConditions() {
  //   return Container(
  //     padding: const EdgeInsets.all(15),
  //     child: const Row(
  //       children: [
  //         Expanded(child: Text("Termes et conditions", style: TextStyle(fontSize: 16,),)),
  //         Icon(Icons.arrow_forward_ios_rounded,),
  //       ],
  //     ),
  //   );
  // }

//   Widget _termesConditions() {
//   return Container(
//     padding: const EdgeInsets.all(15),
//     child: InkWell(
//       onTap: () {
//         _showTermesConditionsDialog(context);
//       },
//       child: const Row(
//         children: [
//           Expanded(child: Text("Termes et conditions", style: TextStyle(fontSize: 16,),)),
//           Icon(Icons.arrow_forward_ios_rounded,),
//         ],
//       ),
//     ),
//   );
// }

Widget _termesConditions(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(15),
    child: InkWell(
      onTap: () {
        _showTermesConditionsDialog(context);
      },
      child: const Row(
        children: [
          Expanded(child: Text("Termes et conditions", style: TextStyle(fontSize: 16,),)),
          Icon(Icons.arrow_forward_ios_rounded,),
        ],
      ),
    ),
  );
}

  void _showTermesConditionsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Termes et conditions'),
        content: const SingleChildScrollView(
          child: Text(
            '''
            6. Politique de Confidentialité
            Dernière mise à jour : 1er janvier 2024
            Cette politique de confidentialité vous informe sur la manière dont nous collectons, utilisons et protégeons vos informations personnelles lorsque vous utilisez notre Application.

            A. Informations que nous collectons
            Lorsque vous utilisez l'Application, nous pouvons collecter les types d'informations suivants:
            - Informations d'identification : telles que votre nom, adresse e-mail, numéro de téléphone, et d'autres informations nécessaires pour créer votre compte.
            - Informations de localisation : si vous autorisez l'accès à la localisation, nous pouvons collecter des données de localisation pour vous fournir des services basés sur la localisation.
            - Données de communication : nous pouvons collecter des informations sur vos interactions avec d'autres utilisateurs de l'Application, y compris les messages et les évaluations.
            - Informations sur l'appareil : nous pouvons collecter des informations sur le type d'appareil que vous utilisez, votre système d'exploitation, l'identifiant de l'appareil, et d'autres données techniques.

            B. Comment nous utilisons vos informations
            Nous utilisons les informations collectées dans l'Application pour les finalités suivantes:
            - Fournir les services de mise en relation entre utilisateurs et prestataires de services.
            - Améliorer et personnaliser l'expérience utilisateur.
            - Communiquer avec vous, y compris pour vous informer sur les mises à jour, les promotions et les offres spéciales.

            ... (continuer le texte)
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

  // Widget _aproposdenous() {
  //   return Container(
  //     padding: const EdgeInsets.all(15),
  //     child: const Row(
  //       children: [
  //         Expanded(child: Text("A propos de nous", style: TextStyle(fontSize: 16,),)),
  //         Icon(Icons.arrow_forward_ios_rounded,),
  //       ],
  //     ),
  //   );
  // }

  Widget _aproposdeNous(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(15),
    child: InkWell(
      onTap: () {
        _showAproposdeNousDialog(context);
      },
      child: const Row(
        children: [
          Expanded(child: Text("A propos de nous", style: TextStyle(fontSize: 16,),)),
          Icon(Icons.arrow_forward_ios_rounded,),
        ],
      ),
    ),
  );
}

  void _showAproposdeNousDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Coordonnées de Contact'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pour toute question ou préoccupation, contactez-nous au :',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                'Whatsapp : +22673335093',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'Mail : Laboitesarl@gmail.com',
                style: TextStyle(fontSize: 14),
              ),
            ],
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


  Widget _faq() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: const Row(
        children: [
          Expanded(child: Text("FAQ", style: TextStyle(fontSize: 16,),)),
          Icon(Icons.arrow_forward_ios_rounded,),
        ],
      ),
    );
  }

  // Widget _contacteznous() {
  //   return Container(
  //     padding: const EdgeInsets.all(15),
  //     child: const Row(
  //       children: [
  //         Expanded(child: Text("Contactez nous", style: TextStyle(fontSize: 16,),)),
  //         Icon(Icons.arrow_forward_ios_rounded,),
  //       ],
  //     ),
  //   );
  // }

  Widget _contactezNous(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(15),
    child: InkWell(
      onTap: () {
        _showContactezNousDialog(context);
      },
      child: const Row(
        children: [
          Expanded(child: Text("Contactez nous", style: TextStyle(fontSize: 16,),)),
          Icon(Icons.arrow_forward_ios_rounded,),
        ],
      ),
    ),
  );
}


  void _showContactezNousDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Coordonnées de Contact'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pour toute question ou préoccupation, contactez-nous au :',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                'Whatsapp : +22673335093',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'Mail : Laboitesarl@gmail.com',
                style: TextStyle(fontSize: 14),
              ),
            ],
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


