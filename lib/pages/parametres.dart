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
                  _termesConditions(),
                  const Divider(height: 25,),
                  _aproposdenous(),
                  const Divider(height: 25,),
                  _faq(),
                  const Divider(height: 30,),
                  _contacteznous()
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

  Widget _confidentialites() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: InkWell(
        onTap: () {
          print("qsqs");
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

  Widget _termesConditions() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: const Row(
        children: [
          Expanded(child: Text("Termes et conditions", style: TextStyle(fontSize: 16,),)),
          Icon(Icons.arrow_forward_ios_rounded,),
        ],
      ),
    );
  }

  Widget _aproposdenous() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: const Row(
        children: [
          Expanded(child: Text("A propos de nous", style: TextStyle(fontSize: 16,),)),
          Icon(Icons.arrow_forward_ios_rounded,),
        ],
      ),
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

  Widget _contacteznous() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: const Row(
        children: [
          Expanded(child: Text("Contactez nous", style: TextStyle(fontSize: 16,),)),
          Icon(Icons.arrow_forward_ios_rounded,),
        ],
      ),
    );
  }


}