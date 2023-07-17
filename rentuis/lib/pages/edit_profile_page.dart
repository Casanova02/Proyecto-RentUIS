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
  String carrera = '';
  // Y otros datos del usuario que necesites...

  File? _imageFile;
  late DocumentReference _userDocument;// Archivo de imagen seleccionado

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

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Cambios guardados correctamente.'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al guardar los cambios.'),
      ));
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
            _buildInfoField('Nombres:', nombres,
              isEditable: _isEditingName,
              controller: _nameController,
              onEdit: () {
                setState(() {
                  _isEditingName = true;
                  _nameController.text = nombres;
                });
              },
              onSave: () {
                setState(() {
                  nombres = _nameController.text.trim();
                  _isEditingName = false;
                });
              },
            ),
            _buildInfoField('Apellidos:', apellidos,
              isEditable: _isEditingLastName,
              controller: _lastNameController,
              onEdit: () {
                setState(() {
                  _isEditingLastName = true;
                  _lastNameController.text = apellidos;
                });
              },
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
              controller: _phoneNumberController,
              onEdit: () {
                setState(() {
                  _isEditingPhone = true;
                  _phoneNumberController.text = phoneNumber;
                });
              },
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
              controller: _passwordController,
              onEdit: () {
                setState(() {
                  _isEditingPassword = true;
                  _passwordController.text = ''; // Puedes cargar la contraseña actual aquí para editarla
                });
              },
              onSave: () {
                setState(() {
                  // Aquí guardas la nueva contraseña en la base de datos
                  _isEditingPassword = false;
                });
              },
            ),
            _buildInfoField('Carrera:', carrera,
              isEditable: _isEditingCarrera,
              controller: _carreraController,
              onEdit: () {
                setState(() {
                  _isEditingCarrera = true;
                  _carreraController.text = carrera;
                });
              },
              onSave: () {
                setState(() {
                  carrera = _carreraController.text.trim();
                  _isEditingCarrera = false;
                });
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

  Widget _buildInfoField(String label, String value,
      {bool isEditable = false, TextEditingController? controller, Function()? onEdit, Function()? onSave}) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: isEditable
          ? TextFormField(
        controller: isEditable ? controller : null,
        keyboardType: TextInputType.text,
        obscureText: label.contains('Contraseña'),
        decoration: InputDecoration(
          hintText: value,
        ),
      )
          : Text(value),
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
          : onEdit != null
          ? IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          if (onEdit != null) {
            onEdit();
          }
        },
      )
          : null,
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
