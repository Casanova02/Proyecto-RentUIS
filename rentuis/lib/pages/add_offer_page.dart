import 'package:flutter/material.dart';
import 'package:rentuis/pages/user_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddOfferPage extends StatefulWidget {
  const AddOfferPage({Key? key}) : super(key: key);

  @override
  _AddOfferPageState createState() => _AddOfferPageState();
}

class _AddOfferPageState extends State<AddOfferPage> {
  final UserSession userSession = UserSession();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String? _selectedTimeOption;
  XFile? _image;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    XFile? imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _image = imageFile;
      });
    }
  }

  Future<String> uploadImageToFirebaseStorage(File file) async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    firebase_storage.UploadTask uploadTask = ref.putFile(file);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;

    return await taskSnapshot.ref.getDownloadURL();
  }

  void showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('La oferta se ha añadido con éxito.'),
      ),
    );
  }

  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void addOffer(BuildContext context) async {
    if (_image == null || _titleController.text.isEmpty || _priceController.text.isEmpty || _selectedTimeOption == null || _descriptionController.text.isEmpty) {
      showErrorMessage(context, 'Debes llenar todos los campos para añadir una oferta.');
    } else {
      if (userSession.userId != null) {
        final String userId = userSession.userId!;
        final String title = _titleController.text.trim();
        final int price = int.parse(_priceController.text.trim());
        final String timeUnit = _selectedTimeOption == 'Hora' ? 'H' : 'D';
        final String description = _descriptionController.text.trim();
        final int? rating = userSession.userRating;

        // Subir la imagen a Firebase Storage y obtener la URL de descarga
        String imageUrl = await uploadImageToFirebaseStorage(File(_image!.path));

        // Almacenar la URL de descarga de la imagen en el campo "image" de la colección "items"
        FirebaseFirestore.instance.collection('items').add({
          'userId': userId,
          'name': title,
          'price': price,
          'time_unit': timeUnit,
          'description': description,
          'rating': rating,
          'image': imageUrl,
        });

        print('Rentar presionado');
        print('userId: $userId, title: $title, price: $price, timeUnit: $timeUnit, description: $description');
        print('imageUrl: $imageUrl');

        // Mostrar la notificación de éxito
        showSuccessMessage(context);

        // Borrar los campos de entrada de texto
        _titleController.clear();
        _priceController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedTimeOption = null;
          _image = null;
        });
      } else {
        // No se encontró un usuario autenticado, muestra un mensaje de error o redirige a la página de inicio de sesión
        showErrorMessage(context, 'Debes iniciar sesión para rentar.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir oferta'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 90.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: CircleAvatar(
                    radius: 100.0,
                    backgroundImage: _image != null ? FileImage(File(_image!.path)) as ImageProvider<Object> : AssetImage('assets/profile_placeholder.jpg'),
                  ),
                ),
                SizedBox(height: 30.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Título del artículo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 60.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40.0,
                          child: TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Precio',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 50.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: DropdownButton<String>(
                            value: _selectedTimeOption,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedTimeOption = newValue;
                              });
                            },
                            items: [
                              DropdownMenuItem(
                                value: 'Hora',
                                child: Text('Hora'),
                              ),
                              DropdownMenuItem(
                                value: 'Día',
                                child: Text('Día'),
                              ),
                            ],
                            underline: SizedBox.shrink(),
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 24.0,
                            elevation: 8,
                            style: TextStyle(color: Colors.black),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50.0),
                Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30.0),
                Container(
                  width: 300.0,
                  height: 180.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Escribe la descripción aquí',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 60.0),
                Container(
                  width: 150.0,
                  padding: EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () => addOffer(context),
                    child: Text(
                      'Rentar',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
