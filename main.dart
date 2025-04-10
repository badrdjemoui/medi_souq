import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/manage_users_screen.dart';
import 'screens/home_screen.dart';
import 'screens/sign_up_screen.dart'; // إضافة شاشة التسجيل

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Routing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/manageUsers': (context) => ManageUsersScreen(),
        '/HomeScreen': (context) => HomeScreen(setLocale: (Locale) {}),
        '/signUp': (context) => SignUpScreen(), // شاشة التسجيل
      },
    );
  }
}

