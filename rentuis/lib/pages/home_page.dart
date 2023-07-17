import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentuis/pages/rents_page.dart';
import 'package:rentuis/pages/request_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomePage extends StatefulWidget {
  final String userEmail;

  HomePage({required this.userEmail});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userFullName;
  String? imagePath;
  int selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    getDeviceToken();

  }
  void getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? deviceToken = await messaging.getToken();
    print('Device Token: $deviceToken');
    saveDeviceToken(deviceToken);
  }

  void saveDeviceToken(String? deviceToken) {
    if (deviceToken != null) {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userRef = firestore.collection('usuarios').doc(userId);

      userRef.update({
        'deviceToken': deviceToken,
      }).then((value) {
        print('Token de registro del dispositivo guardado para el usuario');
      }).catchError((error) {
        print('Error al guardar el token en la base de datos: $error');
      });
    }
  }

  Future<void> fetchUserData() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('email', isEqualTo: widget.userEmail)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs.first.data();
      setState(() {
        userFullName = '${userData['nombres']}';
        imagePath = '${userData['image']}';
      });
    }
  }
  void saveTokenToDatabase(String token) {
    // Aquí puedes guardar el token en la base de datos
    print('Token guardado en la base de datos: $token');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final screens = [
      RequestPage(userEmail: widget.userEmail),
      HomePage(userEmail: widget.userEmail),
      RentPage(userEmail: widget.userEmail),
    ];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.lightBlueAccent,
                Colors.lightGreen,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('RentUIS'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            Container(
              width: 370,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2,
                    spreadRadius: 2,
                    offset: Offset(1, 1),
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32.0,
                    backgroundImage: imagePath != null ? NetworkImage(imagePath!) : null,
                  ),
                  SizedBox(width: 16.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, ',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        userFullName ?? '',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              width: 370,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2,
                    spreadRadius: 2,
                    offset: Offset(1, 1),
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.rate_review,
                    size: 40.0,
                    color: Colors.lightBlueAccent,
                  ),
                  SizedBox(width: 16.0),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Ayúdanos a mejorar!',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Danos una opinión acerca de tu experiencia con RentUIS',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              width: 370,
              padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2,
                    spreadRadius: 2,
                    offset: const Offset(1, 1),
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top:5.0,bottom:20),
                    child:const Text(
                      "Tus solicitudes",
                      style: TextStyle(
                        color:Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      crearRecuadro(index: 0),
                      crearRecuadro(index: 1),
                      crearRecuadro(index: 2),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            const Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Resto del contenido de la página
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => screens[value],
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          });
        },
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.article),
            activeIcon: const Icon(Icons.article_outlined),
            label: 'Solicitudes',
            backgroundColor: colors.primary,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'Inicio',
            backgroundColor: colors.primary,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.monetization_on),
            activeIcon: const Icon(Icons.monetization_on_outlined),
            label: 'Rentas',
            backgroundColor: colors.tertiary,
          ),
        ],
      ),
    );
  }
}
Widget crearRecuadro({required int index}) {
  return FutureBuilder<QuerySnapshot>(
    future: FirebaseFirestore.instance.collection('items').limit(3).get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else if (snapshot.hasError) {
        return const Center(
          child: Text('Error al cargar los datos'),
        );
      } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
        // Verificar que el índice esté dentro del rango de documentos disponibles
        if (index >= 0 && index < snapshot.data!.docs.length) {
          var document = snapshot.data!.docs[index];
          String imageUrl = document['image'];
          String itemName = document['name'];
          return Column(
            children: [
              Stack(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.lightBlueAccent, Colors.lightGreen],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                      ),
                    ),
                  ),
                ],
              ),
              if (imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          );
        }
      }

      // Mostrar el contenedor verde sin la imagen si no se encontró el documento o el campo "imageUrl" es null
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlueAccent, Colors.lightGreen],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      );
    },
  );
}
