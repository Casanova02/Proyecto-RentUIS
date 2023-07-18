import 'package:flutter/material.dart';
import 'package:rentuis/pages/request_page.dart';
import 'package:rentuis/pages/user_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mis_ofertas.dart';

class MisSolicitudes extends StatefulWidget {
  final String userEmail;

  MisSolicitudes({required this.userEmail});

  @override
  State<StatefulWidget> createState() {
    return _MisSolicitudesPageState();
  }
}

class _MisSolicitudesPageState extends State<MisSolicitudes> {
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
        title: const Text('Historial de solicitudes'),
      ),
      body: Container(
        width: _deviceWidth,
        height: _deviceHeight,
        child: userEmail != null
            ? MyListView(userEmail: widget.userEmail, borrarDocumento: _borrarDocumento) // Pasamos el método como parámetro
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

  void _borrarDocumento(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('items_solicitados').doc(documentId).delete();
      print('Documento eliminado correctamente');
    } catch (e) {
      print('Error al eliminar el documento: $e');
    }
  }
}

class MyListView extends StatelessWidget {
  final String userEmail;
  final void Function(String) borrarDocumento; // Declaración de la función para borrar el documento

  MyListView({required this.userEmail, required this.borrarDocumento});

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
            final documentId = documents[index].id; // Obtenemos el ID del documento
            final name = data['name'];
            final imageUrl = data['image'];
            final startDate = data['start_date'];
            final endDate = data['end_date'];
            final rating = data['rating'];
            final ofertas = data['ofertas']; // Obtenemos la lista de ofertas

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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fecha de inicio: $startDate',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            'Fecha de fin: $endDate',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            'Rating: $rating',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            'Ofertas: ${ofertas.length}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 120,
                            height: 35,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.lightBlueAccent, Colors.lightGreen],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MisOfertas(
                                        userEmail: userEmail,
                                        ofertas: ofertas,
                                      ),
                                    ),
                                  );
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
                            ),
                          ),
                          const SizedBox(height: 4), // Espacio entre el rating y el botón de borrado
                          ElevatedButton(
                            onPressed: () {
                              borrarDocumento(documentId); // Llamada al método para borrar el documento
                            },
                            child: const Text('Borrar'),
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
