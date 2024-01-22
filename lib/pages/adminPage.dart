// :::::::::::::::

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ocean/authentification/user_data.dart';
import 'package:ocean/modeles/modelePartenaire.dart';
import 'package:ocean/pages/publicite.dart';
import 'package:ocean/publicites/publicites.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';


Image? decodeBase64ToImage(String base64String) {
  try {
    Uint8List bytes = base64.decode(base64String);
    return Image.memory(bytes);
  } catch (e) {
    print('Erreur lors du décodage de l\'image : $e');
    return null;
  }
}

class Partenaire {
  final String id;
  final String nomprenom;
  final String email;
  final String domaineactivite;
  final String downloadUrl;
  final bool prestataire; 

  Partenaire(this.id, this.nomprenom, this.email, this.domaineactivite, this.downloadUrl, this.prestataire);
}

class AdminPage extends StatefulWidget {

  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  static const _actionTitles = ['Create Post', 'Upload Photo', 'Upload Video'];
  
  List<Partenaire> partenaires = [];
  late final List<DownloadController> _downloadControllers;
  bool isLoading = true;

  Future<List<Partenaire>> fetchData() async {
  try {
    setState(() {
      isLoading = true; // Afficher le chargement
    });

    const String apiUrl = 'https://ocean-52xt.onrender.com/users/partenaires';
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${UserData.token}',
    };

    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final fetchedPartenaires = data
        .map((item) => Partenaire(
              item['_id'] as String,
              item['nomprenom'] as String,
              item['email'] as String,
              item['domaineactivite'] as String,
              item['downloadUrl'] as String,  // Ajoutez ceci
              item['prestataire'] as bool,
            ))
        .toList();

      setState(() {
        isLoading = false; // Cacher le chargement
        partenaires = fetchedPartenaires;
      });

      return fetchedPartenaires;
    } else {
      throw Exception('Failed to fetch data from MongoDB');
    }
  } catch (e) {
    print('Une exception s\'est produite lors de la récupération des données: $e');
    // Gérer l'exception ici, par exemple, afficher un message d'erreur à l'utilisateur.
    return []; // Retourner une liste vide ou une valeur par défaut en cas d'erreur.
  }
}

  // Future<List<Partenaire>> fetchData() async {
  //   setState(() {
  //     isLoading = true; // Afficher le chargement
  //   });

  //   const String apiUrl = 'https://ocean-52xt.onrender.com/users/partenaires';
  //   final Map<String, String> headers = {
  //     'Authorization':
  //         'Bearer ${UserData.token}',
  //   };

  //   final response = await http.get(Uri.parse(apiUrl), headers: headers);

  //   // final response = await http.get(Uri.parse('https://ocean-52xt.onrender.com/users/partenaires'));

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body) as List<dynamic>;
  //     final fetchedPartenaires = data
  //       .map((item) => Partenaire(
  //             item['_id'] as String,
  //             item['nomprenom'] as String,
  //             item['email'] as String,
  //             item['domaineactivite'] as String,
  //             item['downloadUrl'] as String,  // Ajoutez ceci
  //             item['prestataire'] as bool,
              
  //           ))
  //       .toList();


  //     setState(() {
  //       isLoading = false; // Cacher le chargement
  //       partenaires = fetchedPartenaires;
  //     });

  //     return fetchedPartenaires;
  //   } else {
  //     throw Exception('Failed to fetch data from MongoDB');
  //   }
  // }

  void _showAction(BuildContext context, int index) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(_actionTitles[index]),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   fetchData().then((data) {
  //     setState(() {
  //       partenaires = data;
  //       _downloadControllers = List<DownloadController>.generate(
  //         partenaires.length,
  //         (index) => SimulatedDownloadController(onOpenDownload: () {
  //           _openDownload(index);
  //         }),
  //       );
  //     });
  //   });
  // }

    @override
  void initState() {
    super.initState();
    fetchData().then((data) {
      if (mounted) {
      setState(() {
        partenaires = data;
        _downloadControllers = List<DownloadController>.generate(
          partenaires.length,
          (index) => SimulatedDownloadController(onOpenDownload: () {
            _openDownload(index);
          }),
        );
      });
    }
    });
  }

  void _openDownload(int index) {
    final partenaire = partenaires[index];
    
    // Remplacez les barres obliques inverses par des barres obliques normales
    String correctedDownloadUrl = partenaire.downloadUrl.replaceAll("\\", "/");
    
    // Ici, nous ajoutons le préfixe à l'URL relative
    String fullDownloadUrl = 'https://ocean-52xt.onrender.com/users$correctedDownloadUrl';

    print("Téléchargement depuis l'URL: $fullDownloadUrl"); 

    Uri fileUri = Uri.parse(fullDownloadUrl);
    String fileName = fileUri.pathSegments.last; // Ceci extrait le nom du fichier de l'URL

    // _downloadFile(fullDownloadUrl, fileName); // Utiliser l'URL complète pour le téléchargement
    if (mounted) {
      _downloadFile(fullDownloadUrl, fileName);
    }
}

  Future<void> _downloadFile(String downloadUrl, String filename) async {
    try {
      final saveDir = await getExternalStorageDirectory();
      final filePath = "${saveDir?.path}/$filename"; // Chemin local complet du fichier téléchargé

      final response = await http.get(Uri.parse(downloadUrl));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      print("Téléchargement terminé: $filename");

      // Ouvrir le fichier téléchargé
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        // Gérer les erreurs d'ouverture de fichier ici
        print("Erreur lors de l'ouverture du fichier: ${result.message}");
      }
    } catch (error) {
      print("Erreur lors du téléchargement: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Administrateur"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
            children: [
              Row(
                children: [
                  ElevatedButton(onPressed: (){
                    Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Publicite() ),
                            );
                  }, child: const Text("Publier")),
                  ElevatedButton(onPressed: (){
                    Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MesPublicites() ),
                            );
                  }, child: const Text("Mes Publier")),
                ],
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: partenaires.length,
                    itemBuilder: (context, index) {
                      final e = partenaires[index];
                      // final downloadController = _downloadControllers[index];
                      return InkWell(
                        onTap: () {
                          // print("Bonjour");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ModelePartenaire(nomprenom: e.nomprenom, email: e.email, prestataire: e.prestataire, id: e.id, domaineactivite: e.domaineactivite,),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: const DemoAppIcon(),
                          title: Text(e.nomprenom),
                          subtitle: Text(e.domaineactivite),
                          trailing: IconButton(
                            icon: const Icon(Icons.file_download),
                            onPressed: () => _openDownload(index),
                          ),
                        ),
                      );
                    },
                  ),
              ),
            ],
          ),
      // floatingActionButton: ExpandableFab(
      //   distance: 112,
      //   children: [
      //     ActionButton(
      //       onPressed: () => _showAction(context, 0),
      //       icon: const Icon(Icons.publish_outlined),
      //     ),
      //     ActionButton(
      //       onPressed: () => _showAction(context, 1),
      //       icon: const Icon(Icons.insert_photo),
      //     ),
      //     ActionButton(
      //       onPressed: () => _showAction(context, 2),
      //       icon: const Icon(Icons.videocam),
      //     ),
      //   ],
      // ),
    );
  }
}

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: const Icon(Icons.create),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.secondary,
      elevation: 4,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.onSecondary,
      ),
    );
  }
}

@immutable
class FakeItem extends StatelessWidget {
  const FakeItem({
    super.key,
    required this.isBig,
  });

  final bool isBig;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      height: isBig ? 128 : 36,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Colors.grey.shade300,
      ),
    );
  }
}




// !:::::::

// // :::::::::::::::

// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:path_provider/path_provider.dart';
// // import 'package:dio/dio.dart';
// import 'package:open_file/open_file.dart';


// class Partenaire {
//   final String nomprenom;
//   final String email;
//   final String downloadUrl;

//   Partenaire(this.nomprenom, this.email, this.downloadUrl);
// }

// class AdminPage extends StatefulWidget {
//   const AdminPage({super.key});

//   @override
//   State<AdminPage> createState() => _AdminPageState();
// }

// class _AdminPageState extends State<AdminPage> {
//   List<Partenaire> partenaires = [];
//   late final List<DownloadController> _downloadControllers;
//   bool isLoading = true;

//   Future<List<Partenaire>> fetchData() async {
//     setState(() {
//       isLoading = true; // Afficher le chargement
//     });

//     final response = await http.get(Uri.parse('https://ocean-52xt.onrender.com/users/partenaires'));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body) as List<dynamic>;
//       final fetchedPartenaires = data
//         .map((item) => Partenaire(
//               item['nomprenom'] as String,
//               item['email'] as String,
//               item['downloadUrl'] as String,  // Ajoutez ceci
//             ))
//         .toList();


//       setState(() {
//         isLoading = false; // Cacher le chargement
//         partenaires = fetchedPartenaires;
//       });

//       return fetchedPartenaires;
//     } else {
//       throw Exception('Failed to fetch data from MongoDB');
//     }
//   }


//   @override
//   void initState() {
//     super.initState();
//     fetchData().then((data) {
//       setState(() {
//         partenaires = data;
//         _downloadControllers = List<DownloadController>.generate(
//           partenaires.length,
//           (index) => SimulatedDownloadController(onOpenDownload: () {
//             _openDownload(index);
//           }),
//         );
//       });
//     });
//   }

//   void _openDownload(int index) {
//     final partenaire = partenaires[index];
    
//     // Remplacez les barres obliques inverses par des barres obliques normales
//     String correctedDownloadUrl = partenaire.downloadUrl.replaceAll("\\", "/");
    
//     // Ici, nous ajoutons le préfixe à l'URL relative
//     String fullDownloadUrl = 'https://ocean-52xt.onrender.com/users$correctedDownloadUrl';

//     print("Téléchargement depuis l'URL: $fullDownloadUrl"); 

//     Uri fileUri = Uri.parse(fullDownloadUrl);
//     String fileName = fileUri.pathSegments.last; // Ceci extrait le nom du fichier de l'URL

//     _downloadFile(fullDownloadUrl, fileName); // Utiliser l'URL complète pour le téléchargement
// }

//   Future<void> _downloadFile(String downloadUrl, String filename) async {
//     try {
//       final saveDir = await getExternalStorageDirectory();
//       final filePath = "${saveDir?.path}/$filename"; // Chemin local complet du fichier téléchargé

//       final response = await http.get(Uri.parse(downloadUrl));
//       final file = File(filePath);
//       await file.writeAsBytes(response.bodyBytes);

//       print("Téléchargement terminé: $filename");

//       // Ouvrir le fichier téléchargé
//       final result = await OpenFile.open(filePath);
//       if (result.type != ResultType.done) {
//         // Gérer les erreurs d'ouverture de fichier ici
//         print("Erreur lors de l'ouverture du fichier: ${result.message}");
//       }
//     } catch (error) {
//       print("Erreur lors du téléchargement: $error");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: const Text("Administrateur"),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: partenaires.length,
//               itemBuilder: (context, index) {
//                 final e = partenaires[index];
//                 // final downloadController = _downloadControllers[index];
//                 return ListTile(
//                   leading: const DemoAppIcon(),
//                   title: Text(e.nomprenom),
//                   subtitle: Text(e.email),
//                   trailing: IconButton(
//                     icon: Icon(Icons.file_download),
//                     onPressed: () => _openDownload(index),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }


// :::::::::::::::::::::::


// trailing: SizedBox(
                  //   width: 96,
                  //   child: AnimatedBuilder(
                  //     animation: downloadController,
                  //     builder: (context, child) {
                  //       return DownloadButton(
                  //         status: downloadController.downloadStatus,
                  //         downloadProgress: downloadController.progress,
                  //         onDownload: downloadController.startDownload,
                  //         onCancel: downloadController.stopDownload,
                  //         onOpen: downloadController.openDownload,
                  //       );
                  //     },
                  //   ),
                  // ),

  // void _downloadFile(String downloadUrl, String filename) async {
  //   try {
  //     final saveDir = await getExternalStorageDirectory();
  //     final taskId = await FlutterDownloader.enqueue(
  //       url: downloadUrl,
  //       savedDir: saveDir?.path ?? "",
  //       fileName: filename,
  //       showNotification: true,
  //       openFileFromNotification: true,
  //     );
  //     print("Tâche de téléchargement ID: $taskId");
  //   } catch (error) {
  //     print("Erreur lors du téléchargement: $error");
  //   }
  // }
   

  // Future<void> _downloadFile(String downloadUrl, String filename) async {
  //   try {
  //     final saveDir = await getExternalStorageDirectory();
  //     final filePath = "${saveDir?.path}/$filename"; // Chemin local complet du fichier téléchargé

  //     await _dio.download(downloadUrl, filePath,
  //       onReceiveProgress: (received, total) {
  //         if (total != -1) {
  //           print((received / total * 100).toStringAsFixed(0) + "%");
  //         }
  //       }
  //     );
  //     print("Téléchargement terminé: $filename");

  //     // Ouvrir le fichier téléchargé
  //     final result = await OpenFile.open(filePath);
  //     if (result.type != ResultType.done) {
  //       // Gérer les erreurs d'ouverture de fichier ici
  //       print("Erreur lors de l'ouverture du fichier: ${result.message}");
  //     }
  //   } catch (error) {
  //     print("Erreur lors du téléchargement: $error");
  //   }
  // }





// import 'dart:convert';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart'; // <-- Importez Dio ici
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;

// class Partenaire {
//   final String nomprenom;
//   final String email;
//   final String downloadUrl;

//   Partenaire(this.nomprenom, this.email, this.downloadUrl);
// }

// class AdminPage extends StatefulWidget {
//   const AdminPage({super.key});

//   @override
//   State<AdminPage> createState() => _AdminPageState();
// }

// class _AdminPageState extends State<AdminPage> {
//   List<Partenaire> partenaires = [];
//   bool isLoading = true;

//   // Créez une instance de Dio
//   final Dio _dio = Dio();

//   Future<List<Partenaire>> fetchData() async {
//     setState(() {
//       isLoading = true; // Afficher le chargement
//     });

//     final response = await http.get(Uri.parse('https://ocean-52xt.onrender.com/users/partenaires'));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body) as List<dynamic>;
//       final fetchedPartenaires = data
//         .map((item) => Partenaire(
//               item['nomprenom'] as String,
//               item['email'] as String,
//               item['downloadUrl'] as String,  // Ajoutez ceci
//             ))
//         .toList();

//       setState(() {
//         isLoading = false; // Cacher le chargement
//         partenaires = fetchedPartenaires;
//       });

//       return fetchedPartenaires;
//     } else {
//       throw Exception('Failed to fetch data from MongoDB');
//     }
//   }

//   void _openDownload(int index) {
//     final partenaire = partenaires[index];
//     String correctedDownloadUrl = partenaire.downloadUrl.replaceAll("\\", "/");
//     String fullDownloadUrl = 'https://ocean-52xt.onrender.com/users$correctedDownloadUrl';

//     print("Téléchargement depuis l'URL: $fullDownloadUrl"); 

//     Uri fileUri = Uri.parse(fullDownloadUrl);
//     String fileName = fileUri.pathSegments.last;

//     _downloadFile(fullDownloadUrl, fileName);
//   }

//   void _downloadFile(String downloadUrl, String filename) async {
//     try {
//       final saveDir = await getExternalStorageDirectory();
//       await _dio.download(downloadUrl, "${saveDir?.path}/$filename",
//         onReceiveProgress: (received, total) {
//           if (total != -1) {
//             print((received / total * 100).toStringAsFixed(0) + "%");
//           }
//         }
//       );
//       print("Téléchargement terminé: $filename");
//     } catch (error) {
//       print("Erreur lors du téléchargement: $error");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: const Text("Administrateur"),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: partenaires.length,
//               itemBuilder: (context, index) {
//                 final e = partenaires[index];
//                 return ListTile(
//                   leading: const DemoAppIcon(),
//                   title: Text(e.nomprenom),
//                   subtitle: Text(e.email),
//                   trailing: IconButton(
//                     icon: Icon(Icons.file_download),
//                     onPressed: () => _openDownload(index),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr





  // void _downloadFile(String downloadUrl, String filename) async {
  //   final saveDir = await getExternalStorageDirectory();
  //   await FlutterDownloader.enqueue(
  //     url: downloadUrl,
  //     savedDir: saveDir?.path ?? "",
  //     fileName: filename,
  //     showNotification: true,
  //     openFileFromNotification: true,
  //   );
  // }

@immutable
class DemoAppIcon extends StatelessWidget {
  const DemoAppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 1,
      child: FittedBox(
        child: SizedBox(
          width: 80,
          height: 80,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.blue],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Center(
              child: Icon(
                Icons.ac_unit,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum DownloadStatus {
  notDownloaded,
  fetchingDownload,
  downloading,
  downloaded,
}

abstract class DownloadController implements ChangeNotifier {
  DownloadStatus get downloadStatus;
  double get progress;

  void startDownload();
  void stopDownload();
  void openDownload();
}

class SimulatedDownloadController extends DownloadController
    with ChangeNotifier {
  SimulatedDownloadController({
    DownloadStatus downloadStatus = DownloadStatus.notDownloaded,
    double progress = 0.0,
    required VoidCallback onOpenDownload,
  })  : _downloadStatus = downloadStatus,
        _progress = progress,
        _onOpenDownload = onOpenDownload;

  DownloadStatus _downloadStatus;
  @override
  DownloadStatus get downloadStatus => _downloadStatus;

  double _progress;
  @override
  double get progress => _progress;

  final VoidCallback _onOpenDownload;

  bool _isDownloading = false;

  @override
  void startDownload() {
    if (downloadStatus == DownloadStatus.notDownloaded) {
      _doSimulatedDownload();
    }
  }

  @override
  void stopDownload() {
    if (_isDownloading) {
      _isDownloading = false;
      _downloadStatus = DownloadStatus.notDownloaded;
      _progress = 0.0;
      notifyListeners();
    }
  }

  @override
  void openDownload() {
    if (downloadStatus == DownloadStatus.downloaded) {
      _onOpenDownload();
    }
  }

  Future<void> _doSimulatedDownload() async {
    _isDownloading = true;
    _downloadStatus = DownloadStatus.fetchingDownload;
    notifyListeners();

    // Wait a second to simulate fetch time.
    await Future<void>.delayed(const Duration(seconds: 1));

    // If the user chose to cancel the download, stop the simulation.
    if (!_isDownloading) {
      return;
    }

    // Shift to the downloading phase.
    _downloadStatus = DownloadStatus.downloading;
    notifyListeners();

    const downloadProgressStops = [0.0, 0.15, 0.45, 0.8, 1.0];
    for (final stop in downloadProgressStops) {
      // Wait a second to simulate varying download speeds.
      await Future<void>.delayed(const Duration(seconds: 1));

      // If the user chose to cancel the download, stop the simulation.
      if (!_isDownloading) {
        return;
      }

      // Update the download progress.
      _progress = stop;
      notifyListeners();
    }

    // Wait a second to simulate a final delay.
    await Future<void>.delayed(const Duration(seconds: 1));

    // If the user chose to cancel the download, stop the simulation.
    if (!_isDownloading) {
      return;
    }

    // Shift to the downloaded state, completing the simulation.
    _downloadStatus = DownloadStatus.downloaded;
    _isDownloading = false;
    notifyListeners();
  }
}

@immutable
class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.status,
    this.downloadProgress = 0.0,
    required this.onDownload,
    required this.onCancel,
    required this.onOpen,
    this.transitionDuration = const Duration(milliseconds: 500),
  });

  final DownloadStatus status;
  final double downloadProgress;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onOpen;
  final Duration transitionDuration;

  bool get _isDownloading => status == DownloadStatus.downloading;

  bool get _isFetching => status == DownloadStatus.fetchingDownload;

  bool get _isDownloaded => status == DownloadStatus.downloaded;

  void _onPressed() {
    switch (status) {
      case DownloadStatus.notDownloaded:
        onDownload();
        break;
      case DownloadStatus.fetchingDownload:
        // do nothing.
        break;
      case DownloadStatus.downloading:
        onCancel();
        break;
      case DownloadStatus.downloaded:
        onOpen();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: Stack(
        children: [
          ButtonShapeWidget(
            transitionDuration: transitionDuration,
            isDownloaded: _isDownloaded,
            isDownloading: _isDownloading,
            isFetching: _isFetching,
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              duration: transitionDuration,
              opacity: _isDownloading || _isFetching ? 1.0 : 0.0,
              curve: Curves.ease,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ProgressIndicatorWidget(
                    downloadProgress: downloadProgress,
                    isDownloading: _isDownloading,
                    isFetching: _isFetching,
                  ),
                  if (_isDownloading)
                    const Icon(
                      Icons.stop,
                      size: 14,
                      color: CupertinoColors.activeBlue,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class ButtonShapeWidget extends StatelessWidget {
  const ButtonShapeWidget({
    super.key,
    required this.isDownloading,
    required this.isDownloaded,
    required this.isFetching,
    required this.transitionDuration,
  });

  final bool isDownloading;
  final bool isDownloaded;
  final bool isFetching;
  final Duration transitionDuration;

  @override
  Widget build(BuildContext context) {
    var shape = const ShapeDecoration(
      shape: StadiumBorder(),
      color: CupertinoColors.lightBackgroundGray,
    );

    if (isDownloading || isFetching) {
      shape = ShapeDecoration(
        shape: const CircleBorder(),
        color: Colors.white.withOpacity(0),
      );
    }

    return AnimatedContainer(
      duration: transitionDuration,
      curve: Curves.ease,
      width: double.infinity,
      decoration: shape,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AnimatedOpacity(
          duration: transitionDuration,
          opacity: isDownloading || isFetching ? 0.0 : 1.0,
          curve: Curves.ease,
          child: Text(
            isDownloaded ? 'OPEN' : 'GET',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeBlue,
                ),
          ),
        ),
      ),
    );
  }
}

@immutable
class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    super.key,
    required this.downloadProgress,
    required this.isDownloading,
    required this.isFetching,
  });

  final double downloadProgress;
  final bool isDownloading;
  final bool isFetching;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: downloadProgress),
        duration: const Duration(milliseconds: 200),
        builder: (context, progress, child) {
          return CircularProgressIndicator(
            backgroundColor: isDownloading
                ? CupertinoColors.lightBackgroundGray
                : Colors.white.withOpacity(0),
            valueColor: AlwaysStoppedAnimation(isFetching
                ? CupertinoColors.lightBackgroundGray
                : CupertinoColors.activeBlue),
            strokeWidth: 2,
            value: isFetching ? null : progress,
          );
        },
      ),
    );
  }
}



// ::::::::::::::::::::::


  // @override
  // void initState() {
  //   super.initState();
  //   _downloadControllers = List<DownloadController>.generate(
  //     20,
  //     (index) => SimulatedDownloadController(onOpenDownload: () {
  //       _openDownload(index);
  //     }),
  //   );
  //   fetchData().then((data) {
  //     setState(() {
  //       partenaires = data;
  //     });
  //   });
  // }

  // void _openDownload(int index) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Open App ${index + 1}'),
  //     ),
  //   );
  // }


// // ignore_for_file: file_names

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class AdminPage extends StatefulWidget {
//   const AdminPage({super.key});

//   @override
//   State<AdminPage> createState() => _AdminPageState();
// }

// class _AdminPageState extends State<AdminPage> {
//   late final List<DownloadController> _downloadControllers;

//   @override
//   void initState() {
//     super.initState();
//     _downloadControllers = List<DownloadController>.generate(
//       20,
//       (index) => SimulatedDownloadController(onOpenDownload: () {
//         _openDownload(index);
//       }),
//     );
//   }

//   void _openDownload(int index) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Open App ${index + 1}'),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: const Text("Administrateur"),
//       ),
//       body: ListView.separated(
//         itemCount: _downloadControllers.length,
//         separatorBuilder: (_, __) => const Divider(),
//         itemBuilder: _buildListItem,
//       ),
//     );
//   }
  

//   Widget _buildListItem(BuildContext context, int index) {
//     final theme = Theme.of(context);
//     final downloadController = _downloadControllers[index];

//     return ListTile(
//       leading: const DemoAppIcon(),
//       title: Text(
//         'App ${index + 1}',
//         overflow: TextOverflow.ellipsis,
//         style: theme.textTheme.titleLarge,
//       ),
//       subtitle: Text(
//         'Lorem ipsum dolor #${index + 1}',
//         overflow: TextOverflow.ellipsis,
//         style: theme.textTheme.bodySmall,
//       ),
//       trailing: SizedBox(
//         width: 96,
//         child: AnimatedBuilder(
//           animation: downloadController,
//           builder: (context, child) {
//             return DownloadButton(
//               status: downloadController.downloadStatus,
//               downloadProgress: downloadController.progress,
//               onDownload: downloadController.startDownload,
//               onCancel: downloadController.stopDownload,
//               onOpen: downloadController.openDownload,
//             );
//           },
//         ),
//       ),
//     );
//   }  
// }

// @immutable
// class DemoAppIcon extends StatelessWidget {
//   const DemoAppIcon({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const AspectRatio(
//       aspectRatio: 1,
//       child: FittedBox(
//         child: SizedBox(
//           width: 80,
//           height: 80,
//           child: DecoratedBox(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.red, Colors.blue],
//               ),
//               borderRadius: BorderRadius.all(Radius.circular(20)),
//             ),
//             child: Center(
//               child: Icon(
//                 Icons.ac_unit,
//                 color: Colors.white,
//                 size: 40,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// enum DownloadStatus {
//   notDownloaded,
//   fetchingDownload,
//   downloading,
//   downloaded,
// }

// abstract class DownloadController implements ChangeNotifier {
//   DownloadStatus get downloadStatus;
//   double get progress;

//   void startDownload();
//   void stopDownload();
//   void openDownload();
// }

// class SimulatedDownloadController extends DownloadController
//     with ChangeNotifier {
//   SimulatedDownloadController({
//     DownloadStatus downloadStatus = DownloadStatus.notDownloaded,
//     double progress = 0.0,
//     required VoidCallback onOpenDownload,
//   })  : _downloadStatus = downloadStatus,
//         _progress = progress,
//         _onOpenDownload = onOpenDownload;

//   DownloadStatus _downloadStatus;
//   @override
//   DownloadStatus get downloadStatus => _downloadStatus;

//   double _progress;
//   @override
//   double get progress => _progress;

//   final VoidCallback _onOpenDownload;

//   bool _isDownloading = false;

//   @override
//   void startDownload() {
//     if (downloadStatus == DownloadStatus.notDownloaded) {
//       _doSimulatedDownload();
//     }
//   }

//   @override
//   void stopDownload() {
//     if (_isDownloading) {
//       _isDownloading = false;
//       _downloadStatus = DownloadStatus.notDownloaded;
//       _progress = 0.0;
//       notifyListeners();
//     }
//   }

//   @override
//   void openDownload() {
//     if (downloadStatus == DownloadStatus.downloaded) {
//       _onOpenDownload();
//     }
//   }

//   Future<void> _doSimulatedDownload() async {
//     _isDownloading = true;
//     _downloadStatus = DownloadStatus.fetchingDownload;
//     notifyListeners();

//     // Wait a second to simulate fetch time.
//     await Future<void>.delayed(const Duration(seconds: 1));

//     // If the user chose to cancel the download, stop the simulation.
//     if (!_isDownloading) {
//       return;
//     }

//     // Shift to the downloading phase.
//     _downloadStatus = DownloadStatus.downloading;
//     notifyListeners();

//     const downloadProgressStops = [0.0, 0.15, 0.45, 0.8, 1.0];
//     for (final stop in downloadProgressStops) {
//       // Wait a second to simulate varying download speeds.
//       await Future<void>.delayed(const Duration(seconds: 1));

//       // If the user chose to cancel the download, stop the simulation.
//       if (!_isDownloading) {
//         return;
//       }

//       // Update the download progress.
//       _progress = stop;
//       notifyListeners();
//     }

//     // Wait a second to simulate a final delay.
//     await Future<void>.delayed(const Duration(seconds: 1));

//     // If the user chose to cancel the download, stop the simulation.
//     if (!_isDownloading) {
//       return;
//     }

//     // Shift to the downloaded state, completing the simulation.
//     _downloadStatus = DownloadStatus.downloaded;
//     _isDownloading = false;
//     notifyListeners();
//   }
// }

// @immutable
// class DownloadButton extends StatelessWidget {
//   const DownloadButton({
//     super.key,
//     required this.status,
//     this.downloadProgress = 0.0,
//     required this.onDownload,
//     required this.onCancel,
//     required this.onOpen,
//     this.transitionDuration = const Duration(milliseconds: 500),
//   });

//   final DownloadStatus status;
//   final double downloadProgress;
//   final VoidCallback onDownload;
//   final VoidCallback onCancel;
//   final VoidCallback onOpen;
//   final Duration transitionDuration;

//   bool get _isDownloading => status == DownloadStatus.downloading;

//   bool get _isFetching => status == DownloadStatus.fetchingDownload;

//   bool get _isDownloaded => status == DownloadStatus.downloaded;

//   void _onPressed() {
//     switch (status) {
//       case DownloadStatus.notDownloaded:
//         onDownload();
//         break;
//       case DownloadStatus.fetchingDownload:
//         // do nothing.
//         break;
//       case DownloadStatus.downloading:
//         onCancel();
//         break;
//       case DownloadStatus.downloaded:
//         onOpen();
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _onPressed,
//       child: Stack(
//         children: [
//           ButtonShapeWidget(
//             transitionDuration: transitionDuration,
//             isDownloaded: _isDownloaded,
//             isDownloading: _isDownloading,
//             isFetching: _isFetching,
//           ),
//           Positioned.fill(
//             child: AnimatedOpacity(
//               duration: transitionDuration,
//               opacity: _isDownloading || _isFetching ? 1.0 : 0.0,
//               curve: Curves.ease,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   ProgressIndicatorWidget(
//                     downloadProgress: downloadProgress,
//                     isDownloading: _isDownloading,
//                     isFetching: _isFetching,
//                   ),
//                   if (_isDownloading)
//                     const Icon(
//                       Icons.stop,
//                       size: 14,
//                       color: CupertinoColors.activeBlue,
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// @immutable
// class ButtonShapeWidget extends StatelessWidget {
//   const ButtonShapeWidget({
//     super.key,
//     required this.isDownloading,
//     required this.isDownloaded,
//     required this.isFetching,
//     required this.transitionDuration,
//   });

//   final bool isDownloading;
//   final bool isDownloaded;
//   final bool isFetching;
//   final Duration transitionDuration;

//   @override
//   Widget build(BuildContext context) {
//     var shape = const ShapeDecoration(
//       shape: StadiumBorder(),
//       color: CupertinoColors.lightBackgroundGray,
//     );

//     if (isDownloading || isFetching) {
//       shape = ShapeDecoration(
//         shape: const CircleBorder(),
//         color: Colors.white.withOpacity(0),
//       );
//     }

//     return AnimatedContainer(
//       duration: transitionDuration,
//       curve: Curves.ease,
//       width: double.infinity,
//       decoration: shape,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 6),
//         child: AnimatedOpacity(
//           duration: transitionDuration,
//           opacity: isDownloading || isFetching ? 0.0 : 1.0,
//           curve: Curves.ease,
//           child: Text(
//             isDownloaded ? 'OPEN' : 'GET',
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: CupertinoColors.activeBlue,
//                 ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// @immutable
// class ProgressIndicatorWidget extends StatelessWidget {
//   const ProgressIndicatorWidget({
//     super.key,
//     required this.downloadProgress,
//     required this.isDownloading,
//     required this.isFetching,
//   });

//   final double downloadProgress;
//   final bool isDownloading;
//   final bool isFetching;

//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 1,
//       child: TweenAnimationBuilder<double>(
//         tween: Tween(begin: 0, end: downloadProgress),
//         duration: const Duration(milliseconds: 200),
//         builder: (context, progress, child) {
//           return CircularProgressIndicator(
//             backgroundColor: isDownloading
//                 ? CupertinoColors.lightBackgroundGray
//                 : Colors.white.withOpacity(0),
//             valueColor: AlwaysStoppedAnimation(isFetching
//                 ? CupertinoColors.lightBackgroundGray
//                 : CupertinoColors.activeBlue),
//             strokeWidth: 2,
//             value: isFetching ? null : progress,
//           );
//         },
//       ),
//     );
//   }
// }


// :::::::::::::::::::::

// ignore_for_file: file_names

// import 'dart:convert';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class Partenaire {
//   final String nomprenom; // Ajoute la propriété id
//   final String email;
//   // final String image;

//   Partenaire(this.nomprenom, this.email);
// }

// class AdminPage extends StatefulWidget {
//   const AdminPage({super.key});

//   @override
//   State<AdminPage> createState() => _AdminPageState();
// }

// class _AdminPageState extends State<AdminPage> {
//   List<Partenaire> partenaires = [];
//   late final List<DownloadController> _downloadControllers;

//   Future<List<Partenaire>> fetchData() async {
//     // setState(() {
//     //   isLoading = true; // Afficher le chargement
//     // });

//     // final response = await http.get(Uri.parse('http://192.168.0.24:3000/categories'));
//     final response = await http.get(Uri.parse('https://ocean-52xt.onrender.com/users'));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body) as List<dynamic>;
//       final fetchedPartenaires = data
//           .map((item) => Partenaire(
//                 item['nomprenom'] as String, // Utilise l'ID de l'objet JSON comme valeur de l'ID
//                 item['email'] as String,
//                 // item['image'] as String,
//               ))
//           .toList();

//       // setState(() {
//       //   isLoading = false; // Cacher le chargement
//       //   categories = fetchedPartenaires;
//       // });

//       return fetchedPartenaires;
//     } else {
//       throw Exception('Failed to fetch data from MongoDB');
//     }
//   }
  

//   @override
//   void initState() {
//     super.initState();
//     _downloadControllers = List<DownloadController>.generate(
//       20,
//       (index) => SimulatedDownloadController(onOpenDownload: () {
//         _openDownload(index);
//       }),
//     );
//     fetchData().then((data) {
//       setState(() {
//         // categories = data;
//         data;
//       });
//     });
//   }

//   void _openDownload(int index) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Open App ${index + 1}'),
//       ),
//     );
//   }
  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: const Text("Administrateur"),
//       ),
      
//     body: ListView.builder(
      
//       itemCount: partenaires.length,
//       itemBuilder: (context, index) {
//         final e = partenaires[index];
//         final downloadController = _downloadControllers[index];
//         final theme = Theme.of(context);
//         return ListTile(
          
//           leading: const DemoAppIcon(),
//           title: Text(
//             e.nomprenom,
//             overflow: TextOverflow.ellipsis,
//             style: theme.textTheme.titleLarge, // Assuming you have titleLarge in your theme.
//           ),
//           subtitle: Text(
//             e.email,
//             overflow: TextOverflow.ellipsis,
//             style: theme.textTheme.bodySmall, // Assuming you have bodySmall in your theme.
//           ),
//           trailing: SizedBox(
//             width: 96,
//             child: AnimatedBuilder(
//               animation: downloadController,
//               builder: (context, child) {
//                 return DownloadButton(
//                   status: downloadController.downloadStatus,
//                   downloadProgress: downloadController.progress,
//                   onDownload: downloadController.startDownload,
//                   onCancel: downloadController.stopDownload,
//                   onOpen: downloadController.openDownload,
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     ),
//   );
//   }

   
// }

// @immutable
// class DemoAppIcon extends StatelessWidget {
//   const DemoAppIcon({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const AspectRatio(
//       aspectRatio: 1,
//       child: FittedBox(
//         child: SizedBox(
//           width: 80,
//           height: 80,
//           child: DecoratedBox(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.red, Colors.blue],
//               ),
//               borderRadius: BorderRadius.all(Radius.circular(20)),
//             ),
//             child: Center(
//               child: Icon(
//                 Icons.ac_unit,
//                 color: Colors.white,
//                 size: 40,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// enum DownloadStatus {
//   notDownloaded,
//   fetchingDownload,
//   downloading,
//   downloaded,
// }

// abstract class DownloadController implements ChangeNotifier {
//   DownloadStatus get downloadStatus;
//   double get progress;

//   void startDownload();
//   void stopDownload();
//   void openDownload();
// }

// class SimulatedDownloadController extends DownloadController
//     with ChangeNotifier {
//   SimulatedDownloadController({
//     DownloadStatus downloadStatus = DownloadStatus.notDownloaded,
//     double progress = 0.0,
//     required VoidCallback onOpenDownload,
//   })  : _downloadStatus = downloadStatus,
//         _progress = progress,
//         _onOpenDownload = onOpenDownload;

//   DownloadStatus _downloadStatus;
//   @override
//   DownloadStatus get downloadStatus => _downloadStatus;

//   double _progress;
//   @override
//   double get progress => _progress;

//   final VoidCallback _onOpenDownload;

//   bool _isDownloading = false;

//   @override
//   void startDownload() {
//     if (downloadStatus == DownloadStatus.notDownloaded) {
//       _doSimulatedDownload();
//     }
//   }

//   @override
//   void stopDownload() {
//     if (_isDownloading) {
//       _isDownloading = false;
//       _downloadStatus = DownloadStatus.notDownloaded;
//       _progress = 0.0;
//       notifyListeners();
//     }
//   }

//   @override
//   void openDownload() {
//     if (downloadStatus == DownloadStatus.downloaded) {
//       _onOpenDownload();
//     }
//   }

//   Future<void> _doSimulatedDownload() async {
//     _isDownloading = true;
//     _downloadStatus = DownloadStatus.fetchingDownload;
//     notifyListeners();

//     // Wait a second to simulate fetch time.
//     await Future<void>.delayed(const Duration(seconds: 1));

//     // If the user chose to cancel the download, stop the simulation.
//     if (!_isDownloading) {
//       return;
//     }

//     // Shift to the downloading phase.
//     _downloadStatus = DownloadStatus.downloading;
//     notifyListeners();

//     const downloadProgressStops = [0.0, 0.15, 0.45, 0.8, 1.0];
//     for (final stop in downloadProgressStops) {
//       // Wait a second to simulate varying download speeds.
//       await Future<void>.delayed(const Duration(seconds: 1));

//       // If the user chose to cancel the download, stop the simulation.
//       if (!_isDownloading) {
//         return;
//       }

//       // Update the download progress.
//       _progress = stop;
//       notifyListeners();
//     }

//     // Wait a second to simulate a final delay.
//     await Future<void>.delayed(const Duration(seconds: 1));

//     // If the user chose to cancel the download, stop the simulation.
//     if (!_isDownloading) {
//       return;
//     }

//     // Shift to the downloaded state, completing the simulation.
//     _downloadStatus = DownloadStatus.downloaded;
//     _isDownloading = false;
//     notifyListeners();
//   }
// }

// @immutable
// class DownloadButton extends StatelessWidget {
//   const DownloadButton({
//     super.key,
//     required this.status,
//     this.downloadProgress = 0.0,
//     required this.onDownload,
//     required this.onCancel,
//     required this.onOpen,
//     this.transitionDuration = const Duration(milliseconds: 500),
//   });

//   final DownloadStatus status;
//   final double downloadProgress;
//   final VoidCallback onDownload;
//   final VoidCallback onCancel;
//   final VoidCallback onOpen;
//   final Duration transitionDuration;

//   bool get _isDownloading => status == DownloadStatus.downloading;

//   bool get _isFetching => status == DownloadStatus.fetchingDownload;

//   bool get _isDownloaded => status == DownloadStatus.downloaded;

//   void _onPressed() {
//     switch (status) {
//       case DownloadStatus.notDownloaded:
//         onDownload();
//         break;
//       case DownloadStatus.fetchingDownload:
//         // do nothing.
//         break;
//       case DownloadStatus.downloading:
//         onCancel();
//         break;
//       case DownloadStatus.downloaded:
//         onOpen();
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _onPressed,
//       child: Stack(
//         children: [
//           ButtonShapeWidget(
//             transitionDuration: transitionDuration,
//             isDownloaded: _isDownloaded,
//             isDownloading: _isDownloading,
//             isFetching: _isFetching,
//           ),
//           Positioned.fill(
//             child: AnimatedOpacity(
//               duration: transitionDuration,
//               opacity: _isDownloading || _isFetching ? 1.0 : 0.0,
//               curve: Curves.ease,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   ProgressIndicatorWidget(
//                     downloadProgress: downloadProgress,
//                     isDownloading: _isDownloading,
//                     isFetching: _isFetching,
//                   ),
//                   if (_isDownloading)
//                     const Icon(
//                       Icons.stop,
//                       size: 14,
//                       color: CupertinoColors.activeBlue,
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// @immutable
// class ButtonShapeWidget extends StatelessWidget {
//   const ButtonShapeWidget({
//     super.key,
//     required this.isDownloading,
//     required this.isDownloaded,
//     required this.isFetching,
//     required this.transitionDuration,
//   });

//   final bool isDownloading;
//   final bool isDownloaded;
//   final bool isFetching;
//   final Duration transitionDuration;

//   @override
//   Widget build(BuildContext context) {
//     var shape = const ShapeDecoration(
//       shape: StadiumBorder(),
//       color: CupertinoColors.lightBackgroundGray,
//     );

//     if (isDownloading || isFetching) {
//       shape = ShapeDecoration(
//         shape: const CircleBorder(),
//         color: Colors.white.withOpacity(0),
//       );
//     }

//     return AnimatedContainer(
//       duration: transitionDuration,
//       curve: Curves.ease,
//       width: double.infinity,
//       decoration: shape,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 6),
//         child: AnimatedOpacity(
//           duration: transitionDuration,
//           opacity: isDownloading || isFetching ? 0.0 : 1.0,
//           curve: Curves.ease,
//           child: Text(
//             isDownloaded ? 'OPEN' : 'GET',
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: CupertinoColors.activeBlue,
//                 ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// @immutable
// class ProgressIndicatorWidget extends StatelessWidget {
//   const ProgressIndicatorWidget({
//     super.key,
//     required this.downloadProgress,
//     required this.isDownloading,
//     required this.isFetching,
//   });

//   final double downloadProgress;
//   final bool isDownloading;
//   final bool isFetching;

//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 1,
//       child: TweenAnimationBuilder<double>(
//         tween: Tween(begin: 0, end: downloadProgress),
//         duration: const Duration(milliseconds: 200),
//         builder: (context, progress, child) {
//           return CircularProgressIndicator(
//             backgroundColor: isDownloading
//                 ? CupertinoColors.lightBackgroundGray
//                 : Colors.white.withOpacity(0),
//             valueColor: AlwaysStoppedAnimation(isFetching
//                 ? CupertinoColors.lightBackgroundGray
//                 : CupertinoColors.activeBlue),
//             strokeWidth: 2,
//             value: isFetching ? null : progress,
//           );
//         },
//       ),
//     );
//   }
// }