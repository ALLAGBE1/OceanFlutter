import 'package:flutter/material.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Veuillez confirmer votre inscription en cliquant sur le lien dans l\'email que nous vous avons envoyé.',
            ),
            ElevatedButton(
              child: const Text('Renvoyer l\'email de confirmation'),
              onPressed: () {
                // Appeler une fonction pour renvoyer l'email de confirmation
              },
            ),
          ],
        ),
      ),
    );
  }
}
