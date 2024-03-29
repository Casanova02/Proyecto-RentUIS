import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rentuis/pages/renting_page.dart';
import 'package:rentuis/pages/request_page.dart';
import 'package:flutter/painting.dart';
import 'add_offer_page.dart';
import 'home_page.dart';

class RentPage extends StatefulWidget {
  final String userEmail;

  RentPage({required this.userEmail});

  @override
  State<RentPage> createState() => _RentPageState();
}

class _RentPageState extends State<RentPage> {
  int selectedIndex = 2;
  int count = 0;
  int clickCounter = 0;
  final TextEditingController _searchController = TextEditingController(); // Nuevo controlador de texto

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final screens = [RequestPage(userEmail: widget.userEmail), HomePage(userEmail: widget.userEmail), RentPage(userEmail: widget.userEmail)];
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
        title: Text('Rentas disponibles'),
        actions: [],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
              child: TextField(
                controller: _searchController, // Asigna el controlador de texto
                decoration: InputDecoration(
                  labelText: 'Buscar',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    // Realiza la búsqueda y actualiza los resultados
                  });
                },
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
                  final searchTerm = _searchController.text.toLowerCase(); // Término de búsqueda en minúsculas

                  final filteredData = snapshot.data!.docs.where((document) {
                    final itemName = (document.data() as Map<String, dynamic>)['name'].toString().toLowerCase();
                    return itemName.contains(searchTerm); // Filtra los documentos que contengan el término de búsqueda
                  }).toList();

                  return ListView.separated(
                    itemCount: filteredData.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 15.0);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot document = filteredData[index];
                      Map<String, dynamic> itemData = document.data() as Map<String, dynamic>;
                      String itemName = itemData['name'];
                      int itemPrice = itemData['price'];
                      String itemTimeUnit = itemData['time_unit'];
                      int? itemRating = itemData['rating']; // Cambio aquí para obtener el rating como entero nullable (int?)

                      String imagePath = itemData['image'];

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                        child: Container(
                          height: 120.0,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Align(
                              alignment: Alignment.center,
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
                                      children: List.generate(itemRating ?? 0, (index) {
                                        // Cambio aquí para usar '??' para evitar un error si itemRating es null
                                        return Icon(Icons.star, color: Colors.yellow);
                                      }),
                                    ),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RentingPage(
                                          userEmail: widget.userEmail,
                                          offerId: document.id,
                                        ),
                                      ),
                                    );
                                    print('Valor de offerId: ${document.id}');
                                  },
                                  child: Text('Rentar'),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    backgroundColor: Colors.lightBlueAccent,
                                  ),
                                ),
                                onTap: () {
                                  print('Elemento $index seleccionado');
                                },
                              ),
                            ),
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
              pageBuilder: (context, animation, secondaryAnimation) => AddOfferPage(userEmail: widget.userEmail),
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
        backgroundColor: Colors.blue,
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
            label: 'Ofertas',
            backgroundColor: colors.tertiary,
          ),
        ],
      ),
    );
  }
}
