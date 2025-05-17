import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:mi_wallet/RegisterScreen.dart';
import 'package:mi_wallet/WalletScreen.dart';
import 'package:mi_wallet/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _usuarios = [];

  String? _correoSeleccionado;
  Map<String, dynamic>? _usuarioSeleccionado;
  String _mensajeError = "UPS, VUELVE A INTENTARLO";
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _login() async {
    final pass = passwordController.text.trim();
    if (_usuarioSeleccionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona un usuario')));
      return;
    }
    final email = _usuarioSeleccionado!['correo'];

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final hashedPassword = _hashPassword(pass);

    try {
      final user = await _dbHelper.validarUsuario(email, hashedPassword);

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('correo', user['correo']);
        await prefs.setString('nombre', user['nombre']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => WalletScreen(
                  correo: user['correo'],
                  nombreUsuario: user['nombre'],
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña incorrectos')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarUsuarios() async {
    try {
      final usuarios = await _dbHelper.obtenerUsuariosRegistrados();
      setState(() {
        _usuarios = usuarios;
      });
    } catch (e) {
      debugPrint('Error al cargar usuarios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = screenWidth * 0.8;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF002A7E), Color(0xFFFF8C3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '   HEALTHY WALLET',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60.0),
              Center(
                child: Container(
                  width: fieldWidth + 40,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 235, 231, 237),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 4,
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/logo.png', // Usa el nombre real de tu archivo
                        height: 80,
                        width: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        '¡Bienvenido!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002A7E),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Selecciona tu usuario',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      SizedBox(
                        width: fieldWidth,
                        child: DropdownButtonFormField<String>(
                          value: _correoSeleccionado,
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Selecciona un usuario',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          items:
                              _usuarios.map((usuario) {
                                return DropdownMenuItem<String>(
                                  value: usuario['correo'],
                                  child: Text(usuario['nombre']),
                                );
                              }).toList(),
                          onChanged: (correo) {
                            setState(() {
                              _correoSeleccionado = correo;
                              _usuarioSeleccionado = _usuarios.firstWhere(
                                (u) => u['correo'] == correo,
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Contraseña',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      SizedBox(
                        width: fieldWidth,
                        child: TextField(
                          controller: passwordController,
                          obscureText: _obscureText,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            hintText: '********',
                            hintStyle: const TextStyle(color: Colors.grey),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF4568DC),
                                width: 2,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      SizedBox(
                        width: fieldWidth,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002A7E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _isLoading ? null : _login,
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'ENTRAR',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Primera vez aquí? Regístrate'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
