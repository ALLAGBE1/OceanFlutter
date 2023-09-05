import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      debugShowCheckedModeBanner: false,
      home: const DismissibleDemo(),
    );
  }
}

class DismissibleDemo extends StatefulWidget {
  const DismissibleDemo({Key? key}) : super(key: key);

  @override
  State<DismissibleDemo> createState() => _DismissibleDemoState();
}

class _DismissibleDemoState extends State<DismissibleDemo> {
  List<String> items = [
    "Watch",
    "Jeans",
    "Shirt",
    "T-Shirt",
    "Cup",
    "Shoes",
    "Cap",
    "Shorts",
    "Trouser",
    "Lower",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text("Flutter Dismissible Demo"),
        ),
        body: ListView.builder(
          itemCount: items.length,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              background: Container(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: const [
                      Icon(Icons.favorite, color: Colors.red),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text('Move to favorites',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text('Move to trash',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              key: ValueKey<String>(items[index]),
              onDismissed: (DismissDirection direction) {
                setState(() {
                  items.removeAt(index);
                });
              },
              confirmDismiss: (DismissDirection direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Add Gift to Cart"),
                        content: const Text(
                            "Are you sure you want to add this gift in your cart"),
                        actions: <Widget>[
                          ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Yes")),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("No"),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Remove Gift"),
                        content: const Text(
                            "Are you sure you want to remove this gift item?"),
                        actions: <Widget>[
                          ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Yes")),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("No"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: ListTile(
                leading: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.black,
                ),
                title: Text(
                  items[index],
                  style: TextStyle(
                      color: Colors.black.withOpacity(.6), fontSize: 18),
                ),
                subtitle: Text(
                  "This Gift is For you",
                  style: TextStyle(color: Colors.green.withOpacity(.6)),
                ),
              ),
            );
          },
        ));
  }
}
