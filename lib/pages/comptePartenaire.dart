// // ignore_for_file: unnecessary_string_interpolations

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:ocean/authentification/user_data.dart';
// import 'package:google_fonts/google_fonts.dart';

// class ComptePartenaire extends StatefulWidget {
//   const ComptePartenaire({super.key});

//   @override
//   State<ComptePartenaire> createState() => _ComptePartenaireState();
// }

// class _ComptePartenaireState extends State<ComptePartenaire> {
//   File? _image;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage() async {
//     final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
//     setState(() {
//       if (pickedImage != null) {
//         _image = File(pickedImage.path);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Column(
//         // mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(top : 25.0),
//             child: Row(
//               children: [
//                 Expanded(child: Text(" ")),
//                 Icon(Icons.drive_file_rename_outline_rounded, color: Colors.white,)
//               ],
//             ),
//           ),
//           _profile(),
//           Expanded(
//             child: Container(
//               height: MediaQuery.sizeOf(context).height/1,
//               width: MediaQuery.sizeOf(context).width,
//               decoration: const BoxDecoration(
//                 color: Colors.white
//               ),
//               child: Column(
//                 children: [
//                   _cardInfo(),
//                   _entreprise(),
//                   const Divider(height: 25,),
//                   _motdepasse(),
//                   const Divider(height: 25,),
//                   _langue(),
//                   const Divider(height: 25,),
//                   _inviter(),
//                   const Divider(height: 30,),
//                   _sedeconnecter()
//                 ],
//               ),
//             ),
//           ),
          
//         ],
//       ),
//     );
//   }

//   Widget _profile() {
//     return Container(
//       margin: const EdgeInsets.only(top: 5),
//       child: Column(
//         children: [
//           GestureDetector(
//             onTap: _pickImage,
//             child: CircleAvatar(
//               radius: 50,
//               backgroundImage: _image != null ? FileImage(_image!) : null,
//               child: _image == null
//                   ? Image.asset(
//                       "img/profile.png",
//                       height: 100,
//                       width: 100,
//                       fit: BoxFit.cover,
//                     )
//                   : null,
//             ),
//           ),
//           const SizedBox(height: 8,),
//           const Column(
//             children: [
//               // Text('${UserData.nom} ${UserData.prenom}'),
//               // Text('${UserData.email}'),
//               Text('Josué ALLAGBE', style: TextStyle(color: Colors.white),),
//               Text('j.allagbe1@gmail.com', style: TextStyle(color: Colors.white),),
//               SizedBox(height: 25,)
//             ],
//           ),
//           const SizedBox(height: 8,),
//         ],
//       ),
//     );
//   }

//   Widget _cardInfo() {
//     return SizedBox(
//       child: Transform.translate(
//         offset: const Offset(0.0, -25.0),
//         child: SizedBox(
//           height: MediaQuery.sizeOf(context).height * 0.06,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: const BorderRadius.all(Radius.circular(25),),
//               border: Border.all(width: 0.9, color: Colors.blue)
//             ),
//             width: MediaQuery.of(context).size.width / 1.6,
//             // width: 210,
//             child: Container(
              
//              alignment: Alignment.center,
//               child: Text(
//                 "Paramètres personnels",
//                 style: GoogleFonts.acme(
//                   color: Colors.blue,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1
//                   // wordSpacing: 20
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _entreprise() {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       child: InkWell(
//         onTap: () {
//           print("qsqs");
//         },
//         child: const Row(
//           children: [
//             Expanded(child: Text("Détails de l'entreprise", style: TextStyle(fontSize: 16,),)),
//             Icon(Icons.arrow_forward_ios_rounded,),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _motdepasse() {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       child: const Row(
//         children: [
//           Expanded(child: Text("Changer de mot de passe", style: TextStyle(fontSize: 16,),)),
//           Icon(Icons.arrow_forward_ios_rounded,),
//         ],
//       ),
//     );
//   }

//   Widget _langue() {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       child: const Row(
//         children: [
//           Expanded(child: Text("Changer de langue", style: TextStyle(fontSize: 16,),)),
//           Icon(Icons.arrow_forward_ios_rounded,),
//         ],
//       ),
//     );
//   }

//   Widget _inviter() {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       child: const Row(
//         children: [
//           Expanded(child: Text("Disponibilité", style: TextStyle(fontSize: 16,),)),
//           Icon(Icons.arrow_forward_ios_rounded,),
//         ],
//       ),
//     );
//   }

//   Widget _sedeconnecter() {
//     return Container(
//       width: 180,
//       decoration: BoxDecoration(
//         // color: Colors.blue,
//         border: Border.all(style: BorderStyle.solid),
//         borderRadius: const BorderRadius.all(Radius.circular(0.1))
//       ),
//       child: TextButton(onPressed: (){
//         // Navigator.push(
//         //   context,
//         //   MaterialPageRoute(builder: (context) => const BottomNavBar()),
//         // );
//       }, child: Row(
//           children: [
//             const Icon(Icons.album_rounded, color: Colors.yellow,),
//             const SizedBox(width: 6,),
//             Text(
//               'Se déconnecter',
//               style: GoogleFonts.acme(
//                 fontSize: 20.0,
//                 color: Colors.blue,
//                 fontWeight: FontWeight.bold,
//             )),
//           ],
//         )
//     ));
//   }

// }