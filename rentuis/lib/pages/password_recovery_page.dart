import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class PasswordRecoveryPage extends StatefulWidget {
  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final TextEditingController emailController = TextEditingController();
  bool accountExists = true;
  Timer? _timer;
  String? _userEmail;
  String? _verificationCode;
  DateTime? _codeCreationTime;

  Future<void> checkAccountExists(BuildContext context) async {
    final String email = emailController.text;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final QuerySnapshot snapshot = await firestore
        .collection('usuarios')
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isEmpty) {
      setState(() {
        accountExists = false;
      });
    } else {
      final user = snapshot.docs.first;
      final userEmail = user.get('email');

      _verificationCode = _generateVerificationCode();
      _codeCreationTime = DateTime.now(); // Almacenar la hora de creación del código
      _sendVerificationCode(userEmail, _verificationCode!);
      _startTimer();

      setState(() {
        _userEmail = userEmail;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationCodePage(
            userEmail: userEmail,
            verificationCode: _verificationCode!,
            codeCreationTime: _codeCreationTime!,
          ),
        ),
      );
    }
  }

  void _sendVerificationCode(String userEmail, String code) async {
    final smtpServer = gmail('rentuis.soporte@gmail.com', 'wwvocoplwwzxoqby');

    final message = Message()
      ..from = Address('rentuis.soporte@gmail.com', 'RentUIS')
      ..recipients.add(userEmail)
      ..subject = 'Código de verificación - Recuperación de contraseña'
      ..text = '''
    ¡Hola!

    Recibimos una solicitud para restablecer la contraseña de tu cuenta en nuestra aplicación. A continuación, te proporcionamos un código de verificación para verificar tu identidad:

    Código de verificación: $code

    Por favor, ingresa este código en la pantalla de verificación de la aplicación para continuar con el proceso de restablecimiento de contraseña.

    Si no solicitaste restablecer tu contraseña o consideras que esto es un error, por favor, ignora este mensaje.

    Si tienes alguna pregunta o necesitas ayuda, no dudes en contactarnos.

    ¡Gracias por usar nuestra aplicación!

    Saludos,
    RentUIS
    ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Código de verificación enviado a $userEmail');
    } catch (e) {
      print('Error al enviar el correo electrónico: $e');
    }
  }

  String _generateVerificationCode() {
    final random = Random();
    final code = List.generate(6, (_) => random.nextInt(10)).join();
    return code;
  }

  void _startTimer() {
    const oneMinute = Duration(minutes: 1);
    _timer = Timer(oneMinute, _onTimerExpired);
  }

  void _onTimerExpired() {
    setState(() {
      _verificationCode = null;
      _codeCreationTime = null;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        title: Text('Recuperación de contraseña'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Ingresa tu correo electrónico registrado y te enviaremos un código de verificación.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.0),
            Image.asset(
              'assets/password_email.png', // Ruta de la imagen
              width: 200.0,
              height: 200.0,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 32.0),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.lightBlueAccent,
                    Colors.lightGreen,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: ElevatedButton(
                onPressed: () {
                  checkAccountExists(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                  elevation: MaterialStateProperty.all<double>(0.0),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Enviar código de verificación',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            if (!accountExists)
              Text(
                'No existe una cuenta con esta dirección de correo electrónico',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class VerificationCodePage extends StatefulWidget {
  final String userEmail;
  final String verificationCode;
  final DateTime codeCreationTime;

  VerificationCodePage({
    required this.userEmail,
    required this.verificationCode,
    required this.codeCreationTime,
  });

  @override
  _VerificationCodePageState createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  List<TextEditingController> codeControllers = [];
  int codeLength = 6;
  bool _isCodeCorrect = false;
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < codeLength; i++) {
      codeControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < codeLength; i++) {
      codeControllers[i].dispose();
    }
    passwordController.dispose();
    super.dispose();
  }

  void _verifyCode() {
    String inputCode = "";
    for (int i = 0; i < codeLength; i++) {
      inputCode += codeControllers[i].text;
    }

    if (inputCode.isNotEmpty && inputCode == widget.verificationCode && !_isCodeExpired()) {
      setState(() {
        _isCodeCorrect = true;
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Código de verificación incorrecto'),
          content: Text('El código de verificación ingresado no es válido o ha expirado.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  bool _isCodeExpired() {
    // Verifica si el código de verificación ha expirado
    const validDuration = Duration(minutes: 1);
    final now = DateTime.now();
    final codeExpirationTime = widget.codeCreationTime.add(validDuration);
    return now.isAfter(codeExpirationTime);
  }

  void _resetPassword() {
    final newPassword = passwordController.text;

    if (newPassword.length < 8) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Contraseña inválida'),
          content: Text('La contraseña debe tener al menos 8 caracteres.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Aceptar'),
            ),
          ],
        ),
      );
      return;
    }

    FirebaseFirestore.instance
        .collection('usuarios')
        .where('email', isEqualTo: widget.userEmail)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final user = snapshot.docs.first;
        user.reference.update({'contraseña': newPassword}).then((_) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Contraseña restablecida'),
              content: Text('Tu contraseña se ha restablecido correctamente.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('Aceptar'),
                ),
              ],
            ),
          );
        }).catchError((error) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text('No se pudo restablecer la contraseña. Inténtalo nuevamente más tarde.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Aceptar'),
                ),
              ],
            ),
          );
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('No se encontró el usuario correspondiente. Inténtalo nuevamente.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    });
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
        title: Text('Verificación de código'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 32.0),
            Icon(
              CupertinoIcons.envelope_open_fill,
              size: 50.0,
              color: Colors.lightGreen,
            ),
            Text(
              'Ingresa el código de verificación',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.0),
            Text(
              'Se ha enviado un código de verificación al correo electrónico asociado con tu cuenta.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            Text(
              'Correo electrónico: ${widget.userEmail}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Ingresa el código de 6 dígitos para verificar tu identidad.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                codeLength,
                    (index) => Container(
                  width: 40.0,
                  child: TextFormField(
                    controller: codeControllers[index],
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < codeLength - 1) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            if (_isCodeCorrect)
              Column(
                children: [
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      prefixIcon: Icon(
                        Icons.password,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
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
                    child: ElevatedButton(
                      onPressed: _resetPassword,
                      child: Text(
                        'Restablecer contraseña',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
                        elevation: MaterialStateProperty.all<double>(0.0),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (!_isCodeCorrect)
              Container(
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
                child: ElevatedButton(
                  onPressed: _verifyCode,
                  child: Text(
                    'Verificar código',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
                    elevation: MaterialStateProperty.all<double>(0.0),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}