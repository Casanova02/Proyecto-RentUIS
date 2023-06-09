import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rentuis/pages/password_recovery_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/registration_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(RentUISApp());
}

class RentUISApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RentUIS',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen, // Cambia el color primario aquí
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.lightGreenAccent, // Cambia el color secundario aquí
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/register': (context) => RegistrationPage(),
        '/password_recovery': (context) => PasswordRecoveryPage(),
      },
    );
  }
}
