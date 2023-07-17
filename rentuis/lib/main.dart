import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentuis/pages/login_page.dart';
import 'package:rentuis/pages/password_recovery_page.dart';
import 'package:rentuis/pages/registration_page.dart';
import 'package:rentuis/pages/home_page.dart';
import 'package:rentuis/pages/offers_page.dart';
import 'package:rentuis/pages/add_offer_page.dart';
import 'package:rentuis/firebase_messaging.dart';
import 'package:rentuis/pages/request_page.dart'; // Importar el archivo firebase_messaging.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final messagingService = FirebaseMessagingService(); // Crear una instancia del servicio de notificaciones
  messagingService.init(); // Inicializar el servicio de notificaciones
  runApp(RentUISApp());
}

class RentUISApp extends StatelessWidget {
  final FirebaseMessagingService messagingService = FirebaseMessagingService();

  RentUISApp() {
    messagingService.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RentUIS',
      theme: ThemeData(
        fontFamily: GoogleFonts.openSans().fontFamily,
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
