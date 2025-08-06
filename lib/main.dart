
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Levantamiento de Servicios',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  String? errorText;

  final users = {'admin': '1234', 'user1': '5678'};

  void _login() {
    final user = _userController.text;
    final pass = _passController.text;
    if (users.containsKey(user) && users[user] == pass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => FormPage(userId: user)),
      );
    } else {
      setState(() {
        errorText = 'Usuario o contraseña incorrectos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Iniciar Sesión")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _userController, decoration: InputDecoration(labelText: 'Usuario')),
            TextField(controller: _passController, obscureText: true, decoration: InputDecoration(labelText: 'Contraseña')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text("Ingresar")),
            if (errorText != null) Text(errorText!, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

class FormPage extends StatefulWidget {
  final String userId;
  FormPage({required this.userId});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  LocationData? _locationData;
  File? _imageFile;
  final _obsController = TextEditingController();
  final Location location = Location();

  Future<void> _getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    final loc = await location.getLocation();
    setState(() {
      _locationData = loc;
    });
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    final fecha = DateTime.now().toString().split(' ')[0];
    return Scaffold(
      appBar: AppBar(title: Text("Formulario de Levantamiento")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Usuario: ${widget.userId}"),
            Text("Fecha: $fecha"),
            Text("Ubicación: ${_locationData != null ? '${_locationData!.latitude}, ${_locationData!.longitude}' : 'Obteniendo...'}"),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _takePhoto, child: Text("Tomar Fotografía")),
            if (_imageFile != null)
              Image.file(_imageFile!, height: 150),
            SizedBox(height: 10),
            TextField(controller: _obsController, maxLines: 4, decoration: InputDecoration(labelText: "Observaciones")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text("Guardar (Simulado)")),
          ],
        ),
      ),
    );
  }
}
