import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rentuis/pages/rents_page.dart';
import 'package:intl/intl.dart';

import 'add_request_page.dart';
import 'home_page.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});





  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
      int selectedIndex = 0;
  int count = 0;
  int clickCounter = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final screens = [const RequestPage(),const HomePage(), const RentPage()];

     
    return Scaffold(
      appBar: AppBar(
        title: Text('ListView Example'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0), // Bordes más redondeados
                  ),
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Buscar',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('items_solicitados').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error al obtener los datos');
                }

                if (snapshot.hasData) {
                  return ListView.separated(
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 15.0); // Separación vertical entre elementos
                    },
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      Map<String, dynamic> itemData = document.data() as Map<String, dynamic>;
                      String itemName = itemData['name'];
                      Timestamp itemFechai = itemData['fechai'];
                      Timestamp itemFechaf = itemData['fechaf'];
                      int itemRating = itemData['rating'];
                      String imagePath = itemData['image'];

                      DateTime dateTime = itemFechai.toDate();
                      dateTime = dateTime.subtract(Duration(hours: 5));
                      String formattedDate = DateFormat('dd/MM/yy - hh:mm a').format(dateTime);
                      DateTime dateTimef = itemFechaf.toDate();
                      dateTimef = dateTimef.subtract(Duration(hours: 5));
                      String formattedDatef = DateFormat('dd/MM/yy - hh:mm a').format(dateTimef);

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0), // Espacio de relleno alrededor del item
                        child: Card(
                          elevation: 4, // Elevación para crear la sombra
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0), // Bordes redondeados
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30.0, // Ajusta el tamaño según tus necesidades
                              backgroundImage: AssetImage(imagePath),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(itemName),
                                Text(formattedDate),
                                Text(formattedDatef),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(itemRating, (index) {
                                    return Icon(Icons.star, color: Colors.yellow);
                                  }),
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // Acción al presionar el botón "Rentar"
                                print('Rentar presionado en el artículo $itemName');
                              },
                              child: Text('Ofertar'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0), // Bordes redondeados
                                ),
                              ),
                            ), // Icono a la derecha
                            onTap: () {
                              // Acción al hacer clic en un elemento
                              print('Elemento $index seleccionado');
                            },
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => AddRequestPage(),
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
            icon: const Icon(Icons.article,),
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
            label: 'Ofertas',
            backgroundColor: colors.tertiary,
          ),
        
        ],
        
      ),
    );
  }
}



