// ignore_for_file: dead_code, unnecessary_cast, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:ocean/authentification/client.dart';
import 'package:ocean/authentification/confirmation.dart';
import 'package:ocean/authentification/connexion.dart';
import 'package:ocean/authentification/enregistrement.dart';
import 'package:ocean/pages/bottomNavBar.dart';
import 'package:ocean/pages/preInscription.dart';
import 'package:ocean/pages/splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true); // debug: true est optionnel
  FlutterDownloader.registerCallback(downloadCallback as DownloadCallback);
  runApp(const MyApp(documentFourni: '',));
}

int previousProgress = 0;

void downloadCallback(String id, int status, int progress) {
  if (progress - previousProgress >= 10 || progress == 100) {
    print('Téléchargement ID: $id, Statut: $status, Progression: $progress');
    previousProgress = progress;
  }
}




class MyApp extends StatelessWidget {
  // const MyApp({super.key});
  final String documentFourni; // Ajoutez cette ligne
  const MyApp({Key? key, required this.documentFourni}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // bool isLoading = true;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => BottomNavBar(documentFourni: documentFourni,),
        '/confirmation': (context) => const ConfirmationScreen(),
        '/connexion': (context) => const Connexion(),
        '/enregistrement': (context) => const Enregistrement(),
        '/preinscription': (context) => const PreInscription(),
        '/client': (context) => const LeClient(),
        // ... autres routes
        
      },
      debugShowCheckedModeBanner: false,
      
    );
  }
}










// void downloadCallback(String id, DownloadTaskStatus status, int progress) {
//   // Mettez votre logique de callback ici.
//   print('Téléchargement ID: $id, Statut: $status, Progression: $progress');
// }

// void downloadCallback(String id, int status, int progress) {
//   // Mettez votre logique de callback ici.
//   print('Téléchargement ID: $id, Statut: $status, Progression: $progress');
// }

// void downloadCallback(String id, int status, int progress) {
//   if (status == DownloadTaskStatus.complete.index) {
//     print('Téléchargement terminé!');
//   } else {
//     print('Téléchargement ID: $id, Statut: $status, Progression: $progress');
//   }
// }

// void downloadCallback(String id, int status, int progress) {
//   if (status == DownloadTaskStatus.complete.index) {
//     print('Téléchargement terminé!');
//   } else if (status == DownloadTaskStatus.failed.index) {
//     print('Téléchargement échoué');
//   } else {
//     print('Téléchargement ID: $id, Statut: $status, Progression: $progress');
//   }
// }
