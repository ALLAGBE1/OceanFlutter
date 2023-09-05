// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ocean/authentification/user_data.dart';
import 'package:ocean/pages/accueil.dart';
import 'package:ocean/pages/adminPage.dart';
import 'package:ocean/pages/compteClient.dart';
import 'package:ocean/pages/comptePartenaire.dart';
import 'package:ocean/pages/parametres.dart';



class BottomNavBar extends StatefulWidget {
  final String documentFourni; // Déclarer la variable ici
  const BottomNavBar({Key? key, required this.documentFourni}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentPageIndex = 0;
  
  // get documentFourni => "";

  List<NavigationDestination> buildDestinations() {
    List<NavigationDestination> destinations = [
      const NavigationDestination(icon: Icon(Icons.home, color: Colors.white,), label: " "),
      const NavigationDestination(icon: Icon(Icons.person, color: Colors.white,), label: " "),
      const NavigationDestination(icon: Icon(Icons.settings, color: Colors.white,), label: " "),
    ];

    if (UserData.isAdmin) {
      destinations.add(const NavigationDestination(icon: Icon(Icons.admin_panel_settings, color: Colors.white,), label: " ")); // ou n'importe quelle icône représentant l'administration
    }

    return destinations;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async { 
        return true;
       },
      child: SingleChildScrollView(
        dragStartBehavior: DragStartBehavior.down,
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(
              color: Colors.grey,
              border: Border.all(color: Colors.grey, width: 1.5),
              image: const DecorationImage(image: AssetImage('img/background.jpg'), fit: BoxFit.cover) // Changed Image.asset to AssetImage
            ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: [
              const Accueil(),
              CompteClient(documentFourni: widget.documentFourni),
              const Parametres(),
              UserData.isAdmin ? const AdminPage() : const SizedBox.shrink(),
            ][currentPageIndex],
            
            bottomNavigationBar: NavigationBar(
              // height: 40,
              destinations: buildDestinations(),
              selectedIndex: currentPageIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              // backgroundColor: Colors.grey,
              backgroundColor: Colors.transparent,
              animationDuration: const Duration(microseconds: 1000),
            ),
          ),
        ),
      ),
    );
  }

}









// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';

// class BottomNavBar extends StatefulWidget {
//   const BottomNavBar({Key? key,}) : super(key: key);

//   @override
//   State<BottomNavBar> createState() => _BottomNavBarState();
// }

// class _BottomNavBarState extends State<BottomNavBar> {
//   int currentPageIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       dragStartBehavior: DragStartBehavior.down,
//       child: Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         decoration: BoxDecoration(
//           color: Colors.grey,
//           border: Border.all(color: Colors.grey, width: 1.5),
//           image: const DecorationImage(
//             image: AssetImage('img/background.jpg'), 
//             fit: BoxFit.cover
//           )
//         ),
//         child: Scaffold(
//           backgroundColor: Colors.transparent,
//           body: [
//             const Text("data"),
//             const Text("data"),
//             const Text("data"),
//           ][currentPageIndex],
//           bottomNavigationBar: BottomNavigationBar(
//             items: const [
//               BottomNavigationBarItem(icon: Icon(Icons.home, color: Colors.blue), label: "Accueil"),
//               BottomNavigationBarItem(icon: Icon(Icons.person, color: Colors.blue), label: "Produits"),
//               BottomNavigationBarItem(icon: Icon(Icons.settings, color: Colors.blue), label: "Panier"),
//             ],
//             currentIndex: currentPageIndex,
//             onTap: (int index) {
//               setState(() {
//                 currentPageIndex = index;
//               });
//             },
//             backgroundColor: Colors.grey,
//           ),
//         ),
//       ),
//     );
//   }
// }
