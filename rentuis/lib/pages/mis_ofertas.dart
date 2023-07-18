import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentuis/pages/request_page.dart';
import 'package:rentuis/pages/user_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class MisOfertas extends StatefulWidget {
  final String userEmail;
  final List<dynamic> ofertas;

  MisOfertas({required this.userEmail, required this.ofertas});

  @override
  State<StatefulWidget> createState() {
    return _MisOfertasPageState();
  }
}

class _MisOfertasPageState extends State<MisOfertas> {
  late double _deviceHeight, _deviceWidth;
  String? userEmail;
  String? user;
  String? telefono;
  String? nombres;

  @override
  Widget build(BuildContext context) {
    // Guardar el alto y ancho del dispositivo para su uso posterior
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Ofertas'),
        flexibleSpace: _buildGradientAppBar(),
      ),
      body: _buildOfertasListView(),
    );
  }

  Widget _buildGradientAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.lightBlueAccent, // Cambia este color al que desees
            Colors.lightGreen, // Cambia este color al que desees
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildOfertasListView() {
    return FutureBuilder<List<dynamic>>(
      future: obtenerObjetosDesdeFirebase(widget.ofertas),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error al obtener los objetos'),
          );
        } else {
          List<dynamic> objetos = snapshot.data ?? [];
          return ListView.builder(
            itemCount: objetos.length,
            itemBuilder: (context, index) {
              return _buildObjetoContainer(objetos[index]);
            },
          );
        }
      },
    );
  }

Widget _buildObjetoContainer(Map<String, dynamic> objeto) {
  String imageUrl = objeto['image']; // Obtener la URL de la imagen desde el campo 'image'
  String userId = objeto['userId'];
 _getUserId(objeto['userId']);

  return Container(
    padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.01, vertical: _deviceHeight * 0.04),
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30.0),
      boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 5.0)],
    ),
    child: Row(
      children: [
        Container(
          width: 90, // Tamaño del cuadrado verde
          height: 90, // Tamaño del cuadrado verde
          margin: const EdgeInsets.only(right: 6.0, left: 8.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.lightBlueAccent, // Cambia este color al que desees
                Colors.lightGreen, // Cambia este color al que desees
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
          ), // Margen a la izquierda del cuadrado verde
          child: Center(
            child: CircleAvatar(
              radius: 36, // Tamaño del círculo de la imagen
              backgroundColor: Colors.black, // Color del borde negro
              child: CircleAvatar(
                radius: 33, // Tamaño de la imagen circular (ajusta el tamaño según sea necesario)
                backgroundImage: NetworkImage(imageUrl), // Mostrar la imagen circular
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'telefono: ',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    nombres ?? ''.toString(), // Mostrar el campo 'rating' del objeto
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              Text(
                objeto['name'], // Mostrar el campo 'name' del objeto
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), // Aplicar negrita al texto
              ),
              const SizedBox(height: 6), // Espacio entre el nombre y la descripción
              Text(
                objeto['description'], // Mostrar el campo 'description' del objeto
                style: const TextStyle(fontSize: 16.0), // Estilo del texto de la descripción
              ),
              const SizedBox(height: 2), // Espacio entre la descripción y el precio
              Row(
                children: [
                  const Text(
                    'Precio: ',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    objeto['price'].toString(), // Mostrar el campo 'price' del objeto
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              const SizedBox(height: 2), // Espacio entre el precio y el rating
              Row(
                children: [
                  const Text(
                    'Rating: ',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    objeto['rating'].toString(), // Mostrar el campo 'rating' del objeto
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'telefono: ',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    telefono ?? ''.toString(), // Mostrar el campo 'rating' del objeto
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Espacio entre el rating y el botón de borrado
              ElevatedButton(
                onPressed: () {
                  // Lógica para borrar el objeto aquí
                  _borrarObjeto(widget.ofertas);
                },
                child: const Text('Borrar'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildObjetoListTile(Map<String, dynamic> objeto) {
    return Expanded(
      child: ListTile(
        title: Text(
          objeto['name'], // Mostrar el campo 'name' del objeto
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize:24), // Aplicar negrita al texto
        ), 
        // Otros atributos que desees mostrar en el ListTile
      ),
    );
  }

  Future<List<dynamic>> obtenerObjetosDesdeFirebase(List<dynamic> ofertas) async {
    List<dynamic> objetos = [];
 
    for (var ofertaId in ofertas) {
      try {
        // Hacer la consulta a Firestore usando el ID de la oferta
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('items')
            .doc(ofertaId)
            .get();

        // Verificar si el objeto existe antes de añadirlo a la lista
        if (snapshot.exists) {
          objetos.add(snapshot.data());
        }
      } catch (e) {
        print('Error al obtener objeto con ID $ofertaId: $e');
      }
    }

    return objetos;
  }


  void _borrarObjeto(List<dynamic> objeto) async {
    // Obtenemos el ID del objeto a borrar desde el mapa
    String objectId = objeto[0].toString();
    print('El id del objeto es');
    print(objectId);

    try {
      // Eliminar el objeto de Firebase usando su ID
      await FirebaseFirestore.instance.collection('items').doc(objectId).delete();
      
      // Eliminar el ID del objeto de la lista ofertas local
      setState(() {
        widget.ofertas.remove(objectId);
      });
    } catch (e) {
      print('Error al borrar el objeto con ID $objectId: $e');
    }
  }

    void _getUserId(userId) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('email', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot userDoc = querySnapshot.docs.first;
      telefono = userDoc.get('numeroTelefono');
      nombres = userDoc.get('nombres');
    } else {
      print('No se encontró un usuario con el correo electrónico proporcionado.');
    }
  }


}
