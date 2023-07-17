import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EditProfilePage extends StatefulWidget {
  final String userEmail;

  EditProfilePage({required this.userEmail});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _isEditingProfileImage = false;
  bool _isEditingPhone = false;
  bool _isEditingPassword = false;
  bool _isEditingName = false;
  bool _isEditingLastName = false;
  bool _isEditingCarrera = false;

  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _carreraController = TextEditingController();

  String _profileImageUrl = ''; // URL de la imagen de perfil (reemplaza con la imagen real)
  String nombres = '';
  String apellidos = '';
  String phoneNumber = '';
  String carrera = 'Biología';
  // Y otros datos del usuario que necesites...

  List<String> carreraOptions = [
    'Biología',
    'Física',
    'Lic. en Matemáticas',
    'Matemáticas',
    'Química',
    'Diseño Industrial',
    'Ingeniería Civil',
    'Ingeniería Eléctrica',
    'Ingeniería Electrónica',
    'Ingeniería Industrial',
    'Ingeniería Mecánica',
    'Ingeniería de Sistemas',
    'Geología',
    'Ingeniería Metalúrgica',
    'Ingeniería de Petróleos',
    'Ingeniería Química',
    'Derecho',
    'Economía',
    'Filosofía',
    'Historia y Archivística',
    'Lic. en Educación Básica Primaria',
    'Lic. en Literatura y Lengua Castellana',
    'Lic. en Lenguas Extranjeras',
    'Lic. en Música',
    'Trabajo Social',
    'Enfermería',
    'Fisioterapia',
    'Medicina',
    'Microbiología y Bioanálisis',
    'Nutrición y Dietética',
  ];

  File? _imageFile;
  late DocumentReference _userDocument; // Archivo de imagen seleccionado

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userDocument = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
        DocumentSnapshot userData = await _userDocument.get();
        setState(() {
          nombres = userData['nombres'];
          apellidos = userData['apellidos'];
          phoneNumber = userData['numeroTelefono'];
          carrera = userData['carrera'];
          _profileImageUrl = userData['image'];
        });
      }
    } catch (e) {
      print('Error al obtener los datos del usuario: $e');
    }
  }

  Future<void> saveChanges() async {
    try {
      await _userDocument.update({
        'nombres': nombres,
        'apellidos': apellidos,
        'numeroTelefono': phoneNumber,
        'carrera': carrera,
        // Aquí puedes agregar más campos que desees actualizar en Firestore.
      });
      // Obtener la nueva contraseña ingresada en el campo de texto
      String newPassword = _passwordController.text.trim();

      // Verificar si la contraseña ha sido editada y no está vacía
      if (_isEditingPassword && newPassword.isNotEmpty) {
        // Obtener el usuario actual
        User? user = FirebaseAuth.instance.currentUser;

        // Verificar que el usuario esté autenticado
        if (user != null) {
          // Actualizar el campo "contraseña" en Firestore solo si es diferente de la contraseña actual
          if (user.email != null) {
            AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: newPassword);
            await user.reauthenticateWithCredential(credential);

            await user.updatePassword(newPassword);
          } else {
            print('El usuario no tiene un correo electrónico válido.');
          }
        }
      }

      if (_imageFile != null) {
        // Subir la nueva imagen de perfil a Firebase Storage
        String userId = FirebaseAuth.instance.currentUser!.uid;
        String fileName = 'perfil_$userId.jpg';

        firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child('profile_images').child(fileName);

        await ref.putFile(_imageFile!);
        String downloadURL = await ref.getDownloadURL();

        // Actualizar la URL de la imagen de perfil en la base de datos
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
            'image': downloadURL,
          });
        }

        setState(() {
          _profileImageUrl = downloadURL;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cambios guardados correctamente.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar los cambios.'),
        ),
      );
      print('Error al guardar los cambios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: _pickImage, // Llamamos a la función para seleccionar una imagen
              child: CircleAvatar(
                radius: 60.0,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!) as ImageProvider<Object>?
                    : (_profileImageUrl.isNotEmpty ? NetworkImage(_profileImageUrl) as ImageProvider<Object>? : null),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              nombres,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            _buildInfoField(
              'Nombres:',
              nombres,
              isEditable: _isEditingName,
              child: TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: nombres,
                ),
              ),
              onSave: () {
                setState(() {
                  nombres = _nameController.text.trim();
                  _isEditingName = false;
                });
              },
            ),
            _buildInfoField(
              'Apellidos:',
              apellidos,
              isEditable: _isEditingLastName,
              child: TextFormField(
                controller: _lastNameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: apellidos,
                ),
              ),
              onSave: () {
                setState(() {
                  apellidos = _lastNameController.text.trim();
                  _isEditingLastName = false;
                });
              },
            ),
            _buildInfoField(
              'Número de Teléfono:',
              _isEditingPhone ? _phoneNumberController.text : phoneNumber,
              isEditable: _isEditingPhone,
              child: TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: _isEditingPhone ? _phoneNumberController.text : phoneNumber,
                ),
              ),
              onSave: () {
                setState(() {
                  phoneNumber = _phoneNumberController.text.trim();
                  _isEditingPhone = false;
                });
              },
            ),
            _buildInfoField('Email:', widget.userEmail),
            _buildInfoField(
              'Contraseña:',
              _isEditingPassword ? _passwordController.text.replaceAll(RegExp(r'.'), '*') : '********',
              isEditable: _isEditingPassword,
              child: TextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Ingrese su nueva contraseña',
                ),
              ),
              onSave: () {
                setState(() {
                  _isEditingPassword = false;
                });
                // Aquí guardas la nueva contraseña en la base de datos
                // Implementa el código necesario para guardar la contraseña aquí.
              },
            ),
            _buildInfoField(
              'Carrera:',
              carrera,
              isEditable: _isEditingCarrera,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: carrera, // Valor actual de la carrera seleccionada
                onChanged: (newValue) {
                  setState(() {
                    carrera = newValue ?? '';
                  });
                },
                items: carreraOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ),
              onSave: () {
                setState(() {
                  _isEditingCarrera = false;
                });
                // Aquí guardas la nueva carrera en Firestore
                _userDocument.update({'carrera': carrera});
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: saveChanges,
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, {bool isEditable = false, Widget? child, Function()? onSave}) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: isEditable ? child : Text(value),
      trailing: isEditable
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (onSave != null) {
                onSave();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              setState(() {
                _isEditingPhone = false;
                _isEditingPassword = false;
                _isEditingName = false;
                _isEditingLastName = false;
                _isEditingCarrera = false;
              });
            },
          ),
        ],
      )
          : IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          setState(() {
            _isEditingPhone = label.contains('Teléfono');
            _isEditingPassword = label.contains('Contraseña');
            _isEditingName = label.contains('Nombres');
            _isEditingLastName = label.contains('Apellidos');
            _isEditingCarrera = label.contains('Carrera');
          });
        },
      ),
    );
  }

  // Función para seleccionar una imagen
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }
}
