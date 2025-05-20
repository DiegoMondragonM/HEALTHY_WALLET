/*import 'package:flutter/material.dart';
import '/budget_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthy Wallet',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0E21),
          elevation: 0,
        ),
      ),
      home: const BudgetListScreen(),
    );
  }
}*/


////MAIN ORIGINAL SIN EDITAR
/*import 'package:flutter/material.dart';
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
}*/

import 'package:flutter/material.dart';
import 'package:mi_wallet/login_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> eliminarBaseDeDatos() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'mi_wallet.db');
  await deleteDatabase(path);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Borra la base de datos vieja (solo la primera vez)
  await eliminarBaseDeDatos();

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

