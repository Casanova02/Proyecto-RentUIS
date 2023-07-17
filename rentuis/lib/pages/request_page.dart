import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rentuis/pages/rents_page.dart';
import 'package:intl/intl.dart';
import 'add_request_page.dart';
import 'home_page.dart';
import 'offers_page.dart';

class RequestPage extends StatefulWidget {
  final String userEmail;

  RequestPage({required this.userEmail});

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

    final screens = [
      RequestPage(userEmail: widget.userEmail),
      HomePage(userEmail: widget.userEmail),
      RentPage(userEmail: widget.userEmail)
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary, // Color de fondo personalizado
        title: Text('Solicitudes disponibles'),
        centerTitle: false,
        automaticallyImplyLeading: false, // Eliminar el botón de navegación de retroceso
        actions: [],
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
                      String startDateString = itemData['start_date'];
                      String startTimeString = itemData['start_time'];
                      String endDateString = itemData['end_date'];
                      String endTimeString = itemData['end_time'];
                      int itemRating = itemData['rating'] ?? 1; // Valor predeterminado de 0 si es nulo
                      String imagePath = itemData['image'];

                      DateTime startDate = DateFormat('dd/MM/yy').parse(startDateString);
                      DateTime startTime = DateFormat('h:mm a').parse(startTimeString);
                      DateTime endDate = DateFormat('dd/MM/yy').parse(endDateString);
                      DateTime endTime = DateFormat('h:mm a').parse(endTimeString);

                      String formattedStartDate = DateFormat('dd/MM/yy - hh:mm a').format(DateTime(
                          startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute));
                      String formattedEndDate = DateFormat('dd/MM/yy - hh:mm a').format(DateTime(
                          endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute));

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
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
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OffersPage(
                                      userEmail: widget.userEmail,
                                      offerId: document.id,
                                    ),
                                    
                                  ),
                                );
                                print('Valor de offerId: ${document.id}');

                              },
                              child: Text('Ofertar'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                            ),
                            onTap: () {
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
