import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';


class Publicites {
  final String id;
  final String? imagepublier;

  Publicites(this.id, this.imagepublier);
}

class MesPublicites extends StatefulWidget {
  const MesPublicites({super.key});

  @override
  State<MesPublicites> createState() => _MesPublicitesState();
}

class _MesPublicitesState extends State<MesPublicites> {
  List<Publicites> publicites = [];

  @override
  void initState() {
    super.initState();
    // Appeler la fonction fetchPublicites pour récupérer les données
    fetchPublicites().then((fetchedPublicites) {
      setState(() {
        publicites = fetchedPublicites;
      });
    });
  }

  Future<List<Publicites>> fetchPublicites() async {
    final apiUrl = 'https://ocean-52xt.onrender.com/publier';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        print(data);
        // var convert = data.imagepublier;
        final fetchedPublicites = data
            .map((item) => Publicites(
                  item['_id'] as String,
                  item['imagepublier'] != null ? item['imagepublier'] as String : "",
                ))
            .toList();

        return fetchedPublicites;
      } else {
        print('Erreur lors de la récupération des données');
        return [];
      }
    } catch (error) {
      print('Erreur lors de la requête HTTP : $error');
      return [];
    }
  }

  Future<void> deletePublicite(String publiciteId) async {
    final apiUrl = 'https://ocean-52xt.onrender.com/publier/publicite/$publiciteId';

    try {
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // La suppression a réussi
        print('Publicité supprimée avec succès');
      } else {
        print('Erreur lors de la suppression de la publicité');
      }
    } catch (error) {
      print('Erreur lors de la requête HTTP : $error');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes publicités"),),
      body: ListView.builder(
          itemCount: publicites.length,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              background: Container(
                color: Colors.red,
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text('Mettre à la corbeille',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text('Mettre à la corbeille',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              key: ValueKey<String>(publicites[index].id),
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.startToEnd) {
                  // Supprimer la publicité de l'API
                  deletePublicite(publicites[index].id);
                  setState(() {
                    publicites.removeAt(index);
                  });
                }
              },
              confirmDismiss: (DismissDirection direction) async {
                if (direction == DismissDirection.startToEnd) {
                  final confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Supprimer la publicité"),
                        content: const Text(
                            "Etes-vous sûr de vouloir supprimer cette publicité ?"),
                        actions: <Widget>[
                          ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Oui")),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Non"),
                          ),
                        ],
                      );
                    },
                  );
                  return confirm == true;
                } else {
                    final confirm = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Supprimer la publicité"),
                          content: const Text(
                              "Etes-vous sûr de vouloir supprimer cette publicité ?"),
                          actions: <Widget>[
                            ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("Oui")),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Non"),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      // Supprimer la publicité de l'API
                      deletePublicite(publicites[index].id);
                      setState(() {
                        publicites.removeAt(index);
                      });
                    }

                    return confirm == true;
                }
              },
              child: CachedNetworkImage(
                imageUrl: "${publicites[index].imagepublier}",
                placeholder: (context, imageUrl) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, imageUrl, error) =>
                    const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            );
          },
        )
    );
  }
}
