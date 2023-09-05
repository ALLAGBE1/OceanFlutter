import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ocean/pages/preConnexion.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Utilisation de Future.delayed pour simuler le clic automatique après 3 secondes
    Future.delayed(const Duration(seconds: 005), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const PreConnexion(),
          ),
        );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
            color: Colors.grey,
            border: Border.all(color: Colors.grey, width: 1.5),
            image: const DecorationImage(image: AssetImage('img/background.jpg'), fit: BoxFit.cover) // Changed Image.asset to AssetImage
          ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(child: Image.asset("img/logo.png", 
              // height: MediaQuery.sizeOf(context).height*0.30, 
              width: MediaQuery.sizeOf(context).width*0.50,
            ))
          ],
        ),
      ),
    );
  }
}







// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:ocean/authentification/connexion.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Utilisation de Future.delayed pour simuler le clic automatique après 3 secondes
//     Future.delayed(const Duration(seconds: 3), () {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) => const Connexion(),
//           ),
//         );
//     });
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//             color: Colors.grey,
//             border: Border.all(color: Colors.grey, width: 1.5),
//             image: DecorationImage(image: Image.asset('img/background.jpg'))
//           ),
//       ),
//     );
//   }
// }