import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/password_recovery_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/registration_page.dart';
import 'pages/request_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(RentUISApp());
}

class RentUISApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title: 'RentUIS',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen, 
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.lightGreenAccent,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(userEmail: ModalRoute.of(context)?.settings.arguments as String),
        '/register': (context) => RegistrationPage(),
        '/password_recovery': (context) => PasswordRecoveryPage(),
        '/requests': (context) => RequestPage(userEmail: ModalRoute.of(context)?.settings.arguments as String),
      },
    );
  }
}