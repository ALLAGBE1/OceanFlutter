// ignore_for_file: unnecessary_string_interpolations, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CanevaRecherche extends StatefulWidget {
  const CanevaRecherche({super.key});

  @override
  State<CanevaRecherche> createState() => _CanevaRechercheState();
}

class _CanevaRechercheState extends State<CanevaRecherche> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.only(top : 25.0),
            child: _vsearch(),
          ),
          const SizedBox(height: 8,),
          _plusconsommes(),
          const SizedBox(height: 12,),
          Expanded(
          child: Container(
            // padding: EdgeInsets.only(bottom: 1),
            height: MediaQuery.sizeOf(context).height/1,
            width: MediaQuery.sizeOf(context).width,
            decoration: const BoxDecoration(
              color: Colors.white
            ),
            child: Column(
              children: [
                // const Divider(height: 35,),
                _mesCommandes1(),
              ],
            ),
          ),
        ),
          
        ],
      ),
    );
  }

  Widget _plusconsommes(){
    return Container(
      // backgroundColor: Colors.red,
      height: MediaQuery.of(context).size.height * 0.08,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.blue
        // image: DecorationImage(
        //   image: AssetImage(("img/banniere.jpg")),
        //   fit: BoxFit.cover,
        // ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  // border: Border.all(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blueAccent),
              child: InkWell(
                onTap: (){
                  print("oui");
                  
                },
                child: const Text("Electricien", style: TextStyle(
                  color: Colors.white
                ),),
              )),
          ), 
          const SizedBox(width: 3,),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  // border: Border.all(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blueAccent),
              child: const Text("Garagiste", style: TextStyle(
                color: Colors.white
              ),)),
          ), 
          const SizedBox(width: 3,),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  // border: Border.all(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blueAccent),
              child: const Text("Plombier", style: TextStyle(
                color: Colors.white
              ),)),
          ), 
          const SizedBox(width: 3,),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  // border: Border.all(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blueAccent),
              child: const Text("Légumes", style: TextStyle(
                color: Colors.white
              ),)),
          ), 
        ],
      ),
    );
}

  Widget _vsearch() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: CupertinoTextField(
        padding: const EdgeInsets.all(13),
        prefix: const Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: Icon(Icons.search),
        ),
        // controller: usernameController,
        placeholder: "Rechercher un prestataire",
        decoration: BoxDecoration(
          border: Border.all(color: Colors.greenAccent),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _mesCommandes1() {
    return Expanded(
      child: ListView(
        children: [
          const Divider(height: 8,),
          InkWell(
            onTap: (){
              print("Bonjour !!!!");
            },
            child: Container(
              height: 80,
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.grey,
                // border: Border.all(color: Colors.grey, width: 1.5),
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
              ),
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Icon(Icons.person_2),
                  ),
                  Expanded(child: Column(
                    children: [
                      Column(
                        children: [
                          Text("Yunus graphik")
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: Row(children: [
                                Icon(Icons.location_on_outlined),
                                SizedBox(width: 3,),
                                Text("Localisation")
                              ],)),
                              // SizedBox(width: 3,),
                              Expanded(child: Row(children: [
                                Icon(Icons.done_outline_sharp),
                                SizedBox(width: 3,),
                                Text("Disponible oui")
                              ],)),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: Row(children: [
                                Icon(Icons.contact_phone_outlined),
                                SizedBox(width: 3,),
                                Text("0585649579")
                              ],)),
                              // SizedBox(width: 3,),
                              Expanded(child: Row(children: [
                                Icon(Icons.star_rate_outlined),
                                SizedBox(width: 3,),
                                Text("Notes")
                              ],)),
                            ],
                          ),
                        ],
                      )
                    ],
                  ))
                ],
              )
            ),
          ),
          const Divider(height: 8,),
        ],
      ),
    );
  }

}
