import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


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

  void verificarExistenciaUsuario(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    firestore
        .collection('usuarios')
        .where('email', isEqualTo: emailController.text)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ya existe una cuenta con esta dirección de correo electrónico.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        guardarInformacionUsuario(context);
      }
    }).catchError((error) {
      print('Error al verificar existencia de usuario: $error');
    });
  }

  void guardarInformacionUsuario(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    var usuarioRef = firestore.collection('usuarios').doc();

    usuarioRef.set({
      'id': usuarioRef.id,
      'nombres': nombresController.text,
      'apellidos': apellidosController.text,
      'email': emailController.text,
      'contraseña': contrasenaController.text,
      'numeroTelefono': numeroTelefonoController.text,
      'carrera': carreraValue,
    }).then((value) {
      print('Usuario registrado con éxito');
      _showSuccessMessage(context);
    }).catchError((error) {
      print('Error al registrar usuario: $error');
    });
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Te has registrado con éxito'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pushReplacementNamed(context, '/');
  }
  void _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        profileImage = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar usuario'),
      ),
      body: SingleChildScrollView( // Usar SingleChildScrollView para permitir el desplazamiento
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Registrar usuario',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32.0),
                CircleAvatar(
                  radius: 64.0,
                  backgroundImage: profileImage != null && profileImage!.existsSync()
                      ? Image.file(File(profileImage!.path)).image
                      : AssetImage('assets/profile_placeholder.jpg'),
                ),
                SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
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
                                    _pickImage(ImageSource.gallery);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                SizedBox(height: 16.0),
                                GestureDetector(
                                  child: Text('Cámara'),
                                  onTap: () {
                                    _pickImage(ImageSource.camera);
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
                  child: Text('Agregar foto de perfil'),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: nombresController,
                  decoration: InputDecoration(
                    labelText: 'Nombres',
                    border: OutlineInputBorder(),
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
                    border: OutlineInputBorder(),
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
                  controller: numeroTelefonoController,
                  decoration: InputDecoration(
                    labelText: 'Número de teléfono',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    } else if (value.length != 10) {
                      return 'El número de teléfono no es válido';
                    } else if (!value.startsWith('30') &&
                        !value.startsWith('31') &&
                        !value.startsWith('32')) {
                      return 'El número de teléfono no es válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
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
                    border: OutlineInputBorder(),
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
                Container(
                  width: 400.0,
                  child: DropdownButtonFormField<String>(
                    value: carreraValue,
                    decoration: InputDecoration(
                      labelText: 'Carrera',
                      border: OutlineInputBorder(),
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
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                      verificarExistenciaUsuario(context);
                    }
                  },
                  child: Text('Confirmar registro'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}