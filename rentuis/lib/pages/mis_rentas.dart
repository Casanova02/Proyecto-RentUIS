 import 'package:flutter/material.dart';
import 'package:rentuis/pages/request_page.dart';
import 'package:rentuis/pages/user_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'solicitaciones.dart';

class MisRentas extends StatefulWidget {
  final String userEmail;

  MisRentas({required this.userEmail});

  @override
  State<StatefulWidget> createState() {
    return _MisRentasPageState();
  }
}

class _MisRentasPageState extends State<MisRentas> {
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
        title: const Text('Historial de rentas'),
      ),
      body: Container(
        width: _deviceWidth,
        height: _deviceHeight,
        child: userEmail != null
            ? MyListView(userId: widget.userEmail!)
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
  final String userId;

  MyListView({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .where('userId', isEqualTo: userId)
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
            final rating = data['rating']; // Valor del campo 'rating'
            final description = data['description']; // Valor del campo 'description'
            final price = data['price']; // Valor del campo 'price'
            final solicitudes = data['solicitudes'];

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
              child: Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Colors.lightBlueAccent, Colors.lightGreen], // Agregamos el degradado
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    margin: const EdgeInsets.only(right: 8.0, left: 12.0),
                    child: Center(
                      child: CircleAvatar(
                        radius: 35, // Radio del círculo interno con la imagen
                        backgroundColor: Colors.white, // Color de fondo del círculo interno
                        backgroundImage: NetworkImage(imageUrl), // Mostrar la imagen
                        foregroundColor: Colors.black, // Borde negro de 3 píxeles en el círculo
                        child: Container( // Contenedor para el borde negro
                          width: 70, // Ancho del círculo con el borde negro (70 = 35*2)
                          height: 70, // Altura del círculo con el borde negro (70 = 35*2)
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black, // Color del borde negro
                              width: 3, // Grosor del borde negro
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30, // Radio del círculo interno con la imagen
                            backgroundColor: Colors.white, // Color de fondo del círculo interno
                            backgroundImage: NetworkImage(imageUrl), // Mostrar la imagen
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded( // Utilizamos Expanded para que la Columna ocupe el espacio restante
                    child: Column( // Columna para el nombre, la descripción, el precio y el rating debajo
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold, // Texto en negrita
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          'Precio: $price', // Mostrar "Precio: " seguido del valor de price
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
                            'Solicitudes: ${solicitudes.length}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                        //Boton para mis solicitaciones
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
                                      builder: (context) => MisSolicitaciones(
                                        userEmail: userId,
                                        solicitudes: solicitudes,
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
                                  'Solicitudes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              
                            ),
                            
                          ),
                      ],
                    ),
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