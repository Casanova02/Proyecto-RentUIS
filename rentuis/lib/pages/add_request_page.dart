import 'package:flutter/material.dart';
import 'package:rentuis/pages/request_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddRequestPage extends StatefulWidget {
  final String userEmail;

  const AddRequestPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _AddRequestPageState createState() => _AddRequestPageState();
}

class _AddRequestPageState extends State<AddRequestPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  XFile? _image;
  String? userId;

  @override
  void dispose() {
    _titleController.dispose();
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Al iniciar la página, buscamos el id del usuario que coincida con el userEmail
    getUserIdFromEmail();
  }

  Future<void> getUserIdFromEmail() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('email', isEqualTo: widget.userEmail)
          .limit(1)
          .get();

      if (snapshot.size > 0) {
        // Si encontramos un usuario con el email, obtenemos el id
        final user = snapshot.docs.first;
        userId = user.id;
      } else {
        // Si no se encuentra el usuario, puedes mostrar un mensaje de error
        // o realizar alguna otra acción.
        print('Usuario no encontrado con el email: ${widget.userEmail}');
      }
    } catch (e) {
      print('Error al obtener el id del usuario: $e');
    }
  }
  Future<int?> _getUserRating(String userEmail) async {
    final snapshot = await FirebaseFirestore.instance.collection('usuarios').where('email', isEqualTo: userEmail).get();
    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs[0].data();
      return data['rating'];
    }
    return null;
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

  void redirectToRequestPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RequestPage(userEmail: widget.userEmail)),
    );
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('Cerrar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> selectStartDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selectedDate != null) {
      _startDateController.text = selectedDate.day.toString().padLeft(2, '0') +
          '/' +
          selectedDate.month.toString().padLeft(2, '0') +
          '/' +
          selectedDate.year.toString().substring(2);
    }
  }

  Future<void> selectStartTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      _startTimeController.text = selectedTime.format(context);
    }
  }

  Future<void> selectEndDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selectedDate != null) {
      _endDateController.text = selectedDate.day.toString().padLeft(2, '0') +
          '/' +
          selectedDate.month.toString().padLeft(2, '0') +
          '/' +
          selectedDate.year.toString().substring(2);
    }
  }

  Future<void> selectEndTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      _endTimeController.text = selectedTime.format(context);
    }
  }
  void showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('La solicitud se ha añadido con éxito.'),
      ),
    );
  }
  void addRequest() async {
    if (_image == null ||
        _titleController.text.isEmpty ||
        _startDateController.text.isEmpty ||
        _startTimeController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        _endTimeController.text.isEmpty) {
      showErrorMessage('Debes llenar todos los campos para añadir una solicitud.');
    } else {
      final String userId = widget.userEmail; // Usar el userEmail directamente
      final String title = _titleController.text.trim();
      final int? rating = await _getUserRating(widget.userEmail);

      // Subir la imagen a Firebase Storage y obtener la URL de descarga
      String imageUrl = await uploadImageToFirebaseStorage(File(_image!.path));
      String requestId = FirebaseFirestore.instance.collection('items_solicitados').doc().id;

      // Almacenar la URL de descarga de la imagen en el campo "image" de la colección "requests"
      FirebaseFirestore.instance.collection('items_solicitados').doc(requestId).set({

        'userId': userId,
        'name': title,
        'start_date': _startDateController.text,
        'start_time': _startTimeController.text,
        'end_date': _endDateController.text,
        'end_time': _endTimeController.text,
        'image': imageUrl,
        'rating': rating,
        'ofertas':[],
      });

      print('Solicitud presionada');
      print('userId: $userId, title: $title, startDate: ${_startDateController.text} ${_startTimeController.text}, endDate: ${_endDateController.text} ${_endTimeController.text}');
      print('imageUrl: $imageUrl');

      showSuccessMessage(context);

      // Borrar los campos de entrada de texto
      _startDateController.clear();
      _startTimeController.clear();
      _endDateController.clear();
      _titleController.clear();
      _endTimeController.clear();
      setState(() {

        _image = null;
      });
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
        title: Text('Añadir solicitud'),
        actions: [],

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
                      labelText: 'Título de la solicitud',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                        child: TextField(
                          controller: _startDateController,
                          readOnly: true,
                          onTap: selectStartDate,
                          decoration: InputDecoration(
                            labelText: 'Fecha inicial',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                        child: TextField(
                          controller: _startTimeController,
                          readOnly: true,
                          onTap: selectStartTime,
                          decoration: InputDecoration(
                            labelText: 'Hora inicial',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                        child: TextField(
                          controller: _endDateController,
                          readOnly: true,
                          onTap: selectEndDate,
                          decoration: InputDecoration(
                            labelText: 'Fecha final',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                        child: TextField(
                          controller: _endTimeController,
                          readOnly: true,
                          onTap: selectEndTime,
                          decoration: InputDecoration(
                            labelText: 'Hora final',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 60.0),
                Container(
                  width: 150.0,
                  padding: EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: addRequest,
                    child: Text(
                      'Añadir',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      backgroundColor: Colors.lightBlueAccent,
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