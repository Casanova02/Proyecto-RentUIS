import 'package:flutter/material.dart';
import 'package:rentuis/pages/request_page.dart';
import 'package:rentuis/pages/user_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class MisOfertas extends StatefulWidget {
  final String userEmail;
  final List<String> ofertas;

  MisOfertas({required this.userEmail,required this.ofertas});

  @override
  State<StatefulWidget> createState() {
    return _MisOfertasPageState();
  }
}

class _MisOfertasPageState extends State<MisOfertas> {
  late double _deviceHeight, _deviceWidth;
  String? userEmail;
  final UserSession userSession = UserSession();
  List<Map<String, dynamic>> userOffers = [];

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
        title: const Text('Ofertas'),
      ),
      body: Container(
        width: _deviceWidth,
        height: _deviceHeight,
        child: userEmail != null
            ? MyListView(userEmail: widget.userEmail)
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  void _getUserId() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('email', isEqualTo: widget.userEmail)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot userDoc = querySnapshot.docs.first;
      setState(() {
        userEmail = userDoc.get('id');
      });
    } else {
      print('No se encontró un usuario con el correo electrónico proporcionado.');
    }
  }
}
class MyListView extends StatelessWidget {
  final String userEmail;

  MyListView({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items_solicitados')
          .where('userId', isEqualTo: userEmail)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Error al obtener los datos'),
          );
        }

        final documents = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final data = documents[index].data() as Map<String, dynamic>;
            final name = data['name']; // Accedemos al campo 'name' del documento
            final imageUrl = data['image']; // URL de la imagen
            final startDate = data['start_date']; // Fecha de inicio
            final endDate = data['end_date']; // Fecha de fin
            final rating = data['rating'];
            final ofertas = data['ofertas'];

            return Container(
              width: 370,
              padding: const EdgeInsets.symmetric(vertical: 35.0),
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [Colors.lightBlueAccent, Colors.lightGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        margin: const EdgeInsets.only(right: 8.0, left: 12.0),
                        child: Center(
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(imageUrl),
                            foregroundColor: Colors.black,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(imageUrl),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold, // Negrita para el nombre
                            ),
                          ),
                          const SizedBox(height: 8), // Espacio entre el nombre y la fecha
                          Text(
                            'Fecha de inicio: $startDate', // Mostrar la fecha de inicio
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            'Fecha de fin: $endDate', // Mostrar la fecha de fin
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            'Rating: $rating', // Mostrar la fecha de fin
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                          ),

                          
                          const SizedBox(height: 8), // Espacio entre el rating y el botón
                          Container(
                            width: 120, // Ancho del botón
                            height: 35, // Alto del botón
                            child:Container(
                          // Utilizamos otro Container para aplicar el degradado
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.lightBlueAccent, Colors.lightGreen], // Gradiente de colores
                              begin: Alignment.centerLeft, // Comienza desde el centro-izquierda
                              end: Alignment.centerRight, // Termina en el centro-derecha
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextButton(
                            onPressed: () {
                              // Aquí puedes agregar el código para manejar el evento del botón
                              // Por ejemplo, navegar a otra página o realizar alguna acción.
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Ver ofertas',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                ),
                              ),
                            ),
                          )
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}



