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
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _profileImageUrl;
  File? _pickedImage;
  bool _editingPhone = false;
  bool _editingPassword = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
        setState(() {
          _phoneNumberController.text = userData['numeroTelefono'] ?? '';
          // Obtener otros datos del usuario y mostrarlos en los campos correspondientes
          String nombres = userData['nombres'] ?? '';
          String apellidos = userData['apellidos'] ?? '';
          String carrera = userData['carrera'] ?? '';
          _profileImageUrl = userData['image'];
        });
      }
    } catch (e) {
      print('Error al obtener los datos del usuario: $e');
    }
  }

  Future<void> savePhoneNumber() async {
    try {
      String phoneNumber = _phoneNumberController.text.trim();
      if (!isValidPhoneNumber(phoneNumber)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El número de teléfono no es válido.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
          'numeroTelefono': phoneNumber,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Número de teléfono actualizado correctamente.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _editingPhone = false;
        });
      }
    } catch (e) {
      print('Error al guardar el número de teléfono: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el número de teléfono.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> changePassword() async {
    try {
      String newPassword = _passwordController.text.trim();
      if (newPassword.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La contraseña debe tener al menos 8 caracteres.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contraseña actualizada correctamente.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _editingPassword = false;
        });
      }
    } catch (e) {
      print('Error al cambiar la contraseña: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar la contraseña.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool isValidPhoneNumber(String phoneNumber) {
    // Verificar que el número de teléfono tenga 10 dígitos y empiece con '30', '31' o '32'
    RegExp regExp = RegExp(r'^(30|31|32)\d{8}$');
    return regExp.hasMatch(phoneNumber);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImageToFirestore() async {
    if (_pickedImage == null) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        firebase_storage.Reference reference =
        firebase_storage.FirebaseStorage.instance.ref('perfil/$fileName');
        await reference.putFile(_pickedImage!);
        String imageUrl = await reference.getDownloadURL();

        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
          'image': imageUrl,
        });

        setState(() {
          _profileImageUrl = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imagen de perfil actualizada.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error al actualizar la imagen de perfil: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar la imagen de perfil.'),
          backgroundColor: Colors.red,
        ),
      );
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
        title: Text(
          'Edita tu perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60.0,
              backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
            ),
            SizedBox(height: 16.0),
            _buildUserInfoField('Nombres:', 'Nombre del usuario'),
            _buildUserInfoField('Apellidos:', 'Apellidos del usuario'),
            _buildUserInfoField('Teléfono:', _editingPhone ? _phoneNumberController.text : 'Número de teléfono del usuario'),
            _buildUserInfoField('Email:', widget.userEmail),
            _buildUserInfoField(
              'Contraseña:',
              _editingPassword ? _passwordController.text.replaceAll(RegExp(r'.'), '*') : '********',
            ),
            _buildUserInfoField('Carrera:', 'Carrera del usuario'),
            SizedBox(height: 16.0),
            _editingPhone
                ? ElevatedButton(
              onPressed: () => savePhoneNumber(),
              child: Text('Guardar número de teléfono'),
            )
                : IconButton(
              onPressed: () => setState(() => _editingPhone = true),
              icon: Icon(Icons.edit),
            ),
            SizedBox(height: 16.0),
            _editingPassword
                ? ElevatedButton(
              onPressed: () => changePassword(),
              child: Text('Guardar contraseña'),
            )
                : IconButton(
              onPressed: () => setState(() => _editingPassword = true),
              icon: Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoField(String label, String value) {
    return Container(
      width: 300,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            spreadRadius: 2,
            offset: Offset(1, 1),
            color: Colors.grey.withOpacity(0.2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
