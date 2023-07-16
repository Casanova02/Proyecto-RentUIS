import 'package:flutter/material.dart';
import 'package:rentuis/pages/request_page.dart';
import 'package:rentuis/pages/user_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_offer_page.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({Key? key}) : super(key: key);

  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final UserSession userSession = UserSession();
  List<Map<String, dynamic>> userOffers = [];

  @override
  void initState() {
    super.initState();
    _getUserOffers();
  }

  void _getUserOffers() {
    final String userId = userSession.userId!;
    FirebaseFirestore.instance
        .collection('items')
        .where('userId', isEqualTo: userId)
        .get()
        .then((QuerySnapshot snapshot) {
      setState(() {
        userOffers = snapshot.docs
            .map((DocumentSnapshot document) => document.data() as Map<String, dynamic>)
            .toList();
      });
    }).catchError((error) {
      print('Error al obtener las ofertas del usuario: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ofertas'),
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 120.0, bottom: 30.0), // Aumentar el margen inferior
            child: Text(
              'Seleccionar oferta',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: userOffers.length,
              itemBuilder: (context, index) {
                return _buildOfferCard(userOffers[index]);
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
                pageBuilder: (context, animation, secondaryAnimation) => AddOfferPage(),
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

  Widget _buildOfferCard(Map<String, dynamic> offerData) {
    String itemName = offerData['name'];
    int itemPrice = offerData['price'];
    String itemTimeUnit = offerData['time_unit'];
    int itemRating = offerData['rating'];
    String imagePath = offerData['image'];

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
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  itemName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text('\$$itemPrice/$itemTimeUnit'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(itemRating, (index) {
                  return Icon(Icons.star, color: Colors.yellow);
                }),
              ),
            ],
          ),
          trailing: Container(
            constraints: BoxConstraints(maxWidth: 110.0), // Establecer un ancho máximo
            child: ElevatedButton(
              onPressed: () {
                // Acción al seleccionar la oferta
                print('Oferta seleccionada: $itemName');
              },
              child: Text('Seleccionar'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
          ),
          onTap: () {
            // Acción al hacer clic en una oferta
            print('Oferta $itemName seleccionada');
          },
        ),
      ),
      
    );
    
    
  }
  
}
