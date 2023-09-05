import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:ocean/authentification/client.dart';
import 'package:ocean/authentification/partenaire.dart';

bool connecte = false;

class PreInscription extends StatefulWidget {
  const PreInscription({super.key});

  @override
  State<PreInscription> createState() => _PreInscriptionState();
}

class _PreInscriptionState extends State<PreInscription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _entetetext(),
                    SizedBox(height: MediaQuery.sizeOf(context).height*0.14,),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(style: BorderStyle.solid, color: Colors.white),
                        borderRadius: const BorderRadius.all(Radius.circular(0.1))
                      ),
                      child: TextButton(onPressed: (){
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => const LeClient()),
                        // );
                        // Navigator.pushReplacementNamed(context, '/client');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LeClient() ),
                        );

                      }, child: Text(
                        'Client',
                        style: GoogleFonts.acme(
                          fontSize: 20.0,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3.0
                      )))
                    ),
                    SizedBox(height: MediaQuery.sizeOf(context).height*0.060,),
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(style: BorderStyle.solid, color: Colors.white),
                        borderRadius: const BorderRadius.all(Radius.circular(0.1))
                      ),
                      child: TextButton(onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Partenaire()),
                        );
                      }, child: Text(
                        'Partenaire',
                        style: GoogleFonts.acme(
                          fontSize: 20.0,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3.0
                      )))
                    ),
                  ],
                ),  
                
              ],
            )   
          ],
        ),
      ),
    );
  }

  Widget _entetetext() {
    return Container(
      child: Text(
        "Inscrivez vous en tant que",
        style: GoogleFonts.acme(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

}