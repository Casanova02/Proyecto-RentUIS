import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'add_offer_page.dart';
import 'add_request_page.dart';

class RentingPage extends StatefulWidget {
  final String userEmail;
  final String offerId;

  RentingPage({required this.userEmail, required this.offerId});

  @override
  _RentingPageState createState() => _RentingPageState();
}

class _RentingPageState extends State<RentingPage> {
  String? userId;
  List<Map<String, dynamic>> userRequest = [];
  String? selectedItemId;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _deviceToken;

  @override
  void initState() {
    super.initState();
    _getUserId();
    _initFirebaseMessaging(); // Agrega esta línea para inicializar el servicio de mensajería.
  }

  void _getUserId() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('email', isEqualTo: widget.userEmail)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot userDoc = querySnapshot.docs.first;
      userId = userDoc.get('email');
      _getUserRequest();
      print('se encontró un usuario con el correo electrónico proporcionado.$userId');
    } else {
      print('No se encontró un usuario con el correo electrónico proporcionado.');
    }
  }

  void _getUserRequest() {
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('items_solicitados')
          .where('userId', isEqualTo: userId)
          .get()
          .then((QuerySnapshot snapshot) {
        setState(() {
          userRequest = snapshot.docs
              .map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            data['itemId'] = document.id;
            String xd = document.id; // Agregar el campo 'itemId' con el valor del ID del documento
            return data;
            print('No se pudo obtener el ID del usuario.$xd');
          })
              .toList();
        });
      }).catchError((error) {
        print('Error al obtener las ofertas del usuario: $error');
      });
    } else {
      print('No se pudo obtener el ID del usuario.');
    }
  }

  void _initFirebaseMessaging() async {
    await _firebaseMessaging.requestPermission();
    _firebaseMessaging.getToken().then((token) {
      setState(() {
        _deviceToken = token;
      });
    });
  }

  void getDeviceToken(String offerId) async {
    final DocumentSnapshot offerSnapshot = await FirebaseFirestore.instance
        .collection('items')
        .doc(offerId)
        .get();

    if (offerSnapshot.exists) {
      final String email = offerSnapshot.get('userId');
      String deviceToken;
      print('Correo electrónico del usuario: $email');

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = querySnapshot.docs.first;
        deviceToken = userSnapshot.get('deviceToken');
        // Aquí tienes el deviceToken del usuario asociado al offerId
        print('Device Token del usuario: $deviceToken');

        // Puedes utilizar el deviceToken para enviar notificaciones push
        sendPushNotificationToDevice(deviceToken);
      } else {
        print('No se encontró un usuario asociado al offerId');
      }
    } else {
      print('No se encontró una solicitud con el offerId proporcionado');
    }
  }

  void sendPushNotificationToDevice(String deviceToken) async {
    final serverKey = 'AAAAlg8BvrA:APA91bEvsXeL8r4LBFYQyBNAsio27pS4925N9dY70oLoocBXob2Q0cfjA0979qF5QvzRyhqVcNCdkLrLA5X9bGdwWtBE5tj0_r4O7TGakIVsYGIDMTR6Lt-lLVlrgI94gYZR-dVqmIzf'; // Reemplaza con tu clave de servidor de FCM
    final url = 'https://fcm.googleapis.com/fcm/send';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final body = {
      'notification': {
        'title': 'Te han hecho una solicitud',
        'body': '¡Tienes una nueva solicitud para tu renta!',
      },
      'to': deviceToken,
    };

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      print('Notificación enviada correctamente al dispositivo: $deviceToken');
    } else {
      print('Error al enviar la notificación al dispositivo: $deviceToken. Código de estado: ${response.statusCode}');
    }
  }

  void _showSuccessNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('La oferta se ha enviado con éxito.'),
      ),
    );

    if (_deviceToken != null) {
      sendPushNotificationToDevice(_deviceToken!);
    }
  }


  @override
  Widget build(BuildContext context) {
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
        title: Text('Tus solicitudes'),
        actions: [],

      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 120.0),
            child: Text(
              'Seleccionar solicitud',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: userRequest.length,
              itemBuilder: (context, index) {
                return _buildOfferCard(userRequest[index], widget.offerId);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 35.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AddRequestPage(userEmail: widget.userEmail),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue, // Color azul
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offerData, String offerId) {
    String itemName = offerData['name'];
    String startDateString = offerData['start_date'];
    String startTimeString = offerData['start_time'];
    String endDateString = offerData['end_date'];
    String endTimeString = offerData['end_time'];
    int itemRating = offerData['rating'] ?? 1; // Valor predeterminado de 0 si es nulo
    String imagePath = offerData['image'];
    String itemId = offerData['itemId']; // Obtene

    DateTime startDate = DateFormat('dd/MM/yy').parse(startDateString);
    DateTime startTime = DateFormat('h:mm a').parse(startTimeString);
    DateTime endDate = DateFormat('dd/MM/yy').parse(endDateString);
    DateTime endTime = DateFormat('h:mm a').parse(endTimeString);

    String formattedStartDate = DateFormat('dd/MM/yy - hh:mm a').format(DateTime(
        startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute));
    String formattedEndDate = DateFormat('dd/MM/yy - hh:mm a').format(DateTime(
        endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute));
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30.0,
            backgroundImage: NetworkImage(imagePath),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  itemName,
                  style: TextStyle(
                    fontSize: 18, // Tamaño de fuente personalizado
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(formattedStartDate),
              Text(formattedEndDate),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(itemRating, (index) {
                    return Icon(Icons.star, color: Colors.yellow);
                  }),
                ),
              ),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () {
              setState(() {
                selectedItemId = itemId; // Asignar el ID del item seleccionado a la variable selectedItemId
              });
              _showSuccessNotification();
              getDeviceToken(offerId); // Llama a la función getDeviceToken con el offerId
              print('Oferta seleccionada: $itemName');
              _updateItemOfferId(widget.offerId);
            },
            child: Text('Seleccionar'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              backgroundColor: Colors.lightBlueAccent,
            ),
          ),
          onTap: () {
            print('Oferta $itemName seleccionada');
          },
        ),
      ),
    );
  }
  void _updateItemOfferId(String offerId) {
    FirebaseFirestore.instance
        .collection('items')
        .doc(offerId)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        // El documento existe, puedes acceder y actualizar el campo "ofertas"
        List<String> currentOffers = List<String>.from(snapshot.get('solicitudes'));
        List<String> newOffers = List.from(currentOffers)..add(selectedItemId!);

        FirebaseFirestore.instance
            .collection('items')
            .doc(offerId)
            .update({'solicitudes': newOffers})
            .then((_) {
          print('ID del item guardado correctamente para el offerId: $offerId');
        }).catchError((error) {
          print('Error al guardar el ID del item: $error');
        });
      } else {
        print(
            'El documento con offerId: $offerId no existe en la colección items_seleccionados');
      }
    }).catchError((error) {
      print('Error al obtener el documento: $error');
    });
  }
}