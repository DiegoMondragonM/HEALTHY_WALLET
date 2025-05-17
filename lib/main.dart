import 'package:flutter/material.dart';
import 'package:mi_wallet/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Opcional: puedes inicializar tu base aquí si quieres validar algo
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billetera Digital Innovatec',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}
