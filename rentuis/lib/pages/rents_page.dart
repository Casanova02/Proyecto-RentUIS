import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rentuis/pages/request_page.dart';
import 'package:flutter/painting.dart';

import 'add_offer_page.dart';
import 'home_page.dart';

class RentPage extends StatefulWidget {
  const RentPage({super.key});

  @override
  State <RentPage> createState() =>  _RentPageState();
}

class  _RentPageState extends State <RentPage> {
      int selectedIndex = 2;
  int count = 0;
  int clickCounter = 0;

  @override
  Widget build(BuildContext context) {
        final colors = Theme.of(context).colorScheme;

    final screens = [const RequestPage(),const HomePage(), const RentPage()];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary, // Color de fondo personalizado
        title: Text('Rentas disponibles'),
        centerTitle: false,
        automaticallyImplyLeading: false, // Eliminar el botón de navegación de retroceso
        actions: [], // Eliminar los elementos de acción
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
              stream: FirebaseFirestore.instance.collection('items').snapshots(),
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
                      int itemPrice = itemData['price'];
                      String itemTimeUnit = itemData['time_unit'];
                      int itemRating = itemData['rating'];
                      String imagePath = itemData['image'];

                       return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0), // Espacio de relleno alrededor del item
                        child: Container(
                          height: 120.0, // Aumentar la altura del Card
                          child: Card(
                            elevation: 4, // Elevación para crear la sombra
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0), // Bordes redondeados
                            ),
                            child: Align(
                              alignment: Alignment.center, // Centrar verticalmente el contenido
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30.0, // Ajusta el tamaño según tus necesidades
                                  backgroundImage: NetworkImage(imagePath),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8.0), // Aumentar el espaciado inferior
                                      child: Text(itemName,
                                      style: TextStyle(
                                          fontSize: 18, // Tamaño de fuente personalizado
                                          fontWeight: FontWeight.bold,)
                                      ),
                                      
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8.0), // Aumentar el espaciado inferior
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
                            trailing: ElevatedButton(
                              onPressed: () {
                                // Acción al presionar el botón "Rentar"
                                print('Rentar presionado en el artículo $itemName');
                              },
                              child: Text('Rentar'),
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
                        )
                        )
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

