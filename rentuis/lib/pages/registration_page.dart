import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController numeroTelefonoController = TextEditingController();
  String carreraValue = '';
  File? profileImage;
  XFile? _image;

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

  @override
  void initState() {
    super.initState();
    carreraValue = carreraOptions[0];
  }

  void verificarExistenciaUsuario(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await firestore
        .collection('usuarios')
        .where('email', isEqualTo: emailController.text)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Ya existe una cuenta con esta dirección de correo electrónico.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      registrarUsuario();
    }
  }

  Future<void> registrarUsuario() async {
    try {
      // Registrar usuario en Firebase Authentication
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: contrasenaController.text.trim(),
      );

      // Obtener el ID único del usuario registrado
      String userId = userCredential.user!.uid;

      // Guardar la información del usuario en Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var usuarioRef = firestore.collection('usuarios').doc(userId);
      String imageUrl = await uploadImageToFirebaseStorage(File(_image!.path));

      await usuarioRef.set({
        'id': userId,
        'nombres': nombresController.text.trim(),
        'apellidos': apellidosController.text.trim(),
        'email': emailController.text.trim(),
        'numeroTelefono': numeroTelefonoController.text.trim(),
        'carrera': carreraValue,
        'contraseña': contrasenaController.text,
        'rating': 5,
        'image': imageUrl,
      });

      // Mostrar mensaje de éxito y redirigir a la página de inicio de sesión
      _showSuccessMessage();
      _redirectToLoginPage();
    } catch (e) {
      print('Error al registrar usuario: $e');
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Te has registrado con éxito'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _redirectToLoginPage() {
    Navigator.pushReplacementNamed(context, '/'); // Ajusta la ruta según tu implementación
  }

  Future<void> pickImage(ImageSource source) async {
    XFile? imageFile = await ImagePicker().pickImage(source: source);
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
        title: Text('Registrar usuario'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Seleccionar foto de perfil'),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: [
                                GestureDetector(
                                  child: Text('Galería'),
                                  onTap: () {
                                    pickImage(ImageSource.gallery);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                SizedBox(height: 16.0),
                                GestureDetector(
                                  child: Text('Cámara'),
                                  onTap: () {
                                    pickImage(ImageSource.camera);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 150.0,
                    height: 150.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      image: profileImage != null && profileImage!.existsSync()
                          ? DecorationImage(
                        image: FileImage(profileImage!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: profileImage == null
                        ? Icon(
                      Icons.add_a_photo,
                      size: 40.0,
                      color: Colors.grey[400],
                    )
                        : null,
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: nombresController,
                  decoration: InputDecoration(
                    labelText: 'Nombres',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                      return 'Ingresa solo letras en este campo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: apellidosController,
                  decoration: InputDecoration(
                    labelText: 'Apellidos',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                      return 'Ingresa solo letras en este campo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Ingresa un email válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: contrasenaController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    } else if (value.length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: numeroTelefonoController,
                  decoration: InputDecoration(
                    labelText: 'Número de teléfono',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    } else if (value.length != 10 ||
                        !(value.startsWith('30') || value.startsWith('31') || value.startsWith('32'))) {
                      return 'Ingresa un número de teléfono válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Container(
                  width: 400.0,
                  child: DropdownButtonFormField<String>(
                    value: carreraValue,
                    decoration: InputDecoration(
                      labelText: 'Carrera',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    items: carreraOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        carreraValue = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 32.0),
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                      verificarExistenciaUsuario(context);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      gradient: LinearGradient(
                        colors: [
                          Colors.lightBlueAccent,
                          Colors.lightGreen,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Confirmar registro',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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