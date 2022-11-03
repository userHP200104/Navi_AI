import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:navi/theme.dart';

import 'package:navi/pages/home.dart';
import 'package:navi/pages/fitness.dart';

List<CameraDescription> cameras = [];

// void main() => runApp(MaterialApp(
//   home: MainPage(),
//   initialRoute: '/',
//   routes: {
//     '/loading': (context) => Loading(),
//     '/home': (context) => Home(),
//     '/fitness' : (context) => Fitness(),
//   },
//   theme: ThemeData(
//     colorSchemeSeed: Colors.pink,
//     brightness: Brightness.light,
//     useMaterial3: true,
//   ),
// ));

// initialRoute: '/',
// routes: {
//   '/new_exercise': (context) => NewExercise(),
//   '/home': (context) => Home(),
//   '/fitness' : (context) => Fitness(),
// },

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      theme: ThemeData(
        colorSchemeSeed: AppTheme.customColor,
        brightness: AppTheme.customBrightness,
        useMaterial3: true,
      ),
    );
  }
}

class MainPage extends StatefulWidget {

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int index = 0;
  final screens = [
    Home(),
    Fitness(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: screens[index],
    bottomNavigationBar: NavigationBarTheme(
      data: NavigationBarThemeData(
        // indicatorColor: Colors.pink[100],
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            // color: Colors.pink[400]
          )
        )
      ),
      child: NavigationBar(
        // backgroundColor: Colors.pink[50],
        selectedIndex: index,
        onDestinationSelected: (index) =>
          setState(() => this.index = index),

        destinations: [
          NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                // color: Colors.pink[400],
              ),
              selectedIcon: Icon(
                Icons.home,
                // color: Colors.pink[400],
              ),
              label: 'Home'
          ),
          NavigationDestination(
              icon: Icon(
                Icons.sports_gymnastics_outlined,
                // color: Colors.pink[400],
              ),
              selectedIcon: Icon(
                Icons.sports_gymnastics,
                // color: Colors.pink[400],
              ),
              label: 'Yoga'
          ),
        ],
      ),
    ),
  );
}








