import 'package:flutter/material.dart';

import 'package:lypht_prptotype/googleMaps.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lypht',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const HomePage(title: 'Lypht'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  bool isDark = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black54 : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    isDark = !isDark;
                  });

                  debugPrint('Action');
                }
              },
              icon: const Icon(Icons.accessibility_outlined))
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
                onPressed: () {
                  debugPrint('Hello');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const GoogleMapsPage();
                      },
                    ),
                  );
                },
                child: const Text('Open Maps')),
          ),
        ],
      ),
    );
  }
}
