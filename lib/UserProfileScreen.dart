import 'package:flutter/material.dart';
import 'dart:io';

// ------------------ USER PROFILE SCREEN (diseño de perfil de usuario) ------------------
class UserProfileScreen extends StatelessWidget {
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String profileImageUrl; // Puede ser un URL o una ruta local

  const UserProfileScreen({
    Key? key,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo degradado entre morado y azul.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
             colors: [Color(0xFF002A7E), Color(0xFFFF8C3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Botón "X" para volver.
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Título centrado en la parte superior.
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Perfil',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Recuadro blanco que ocupa gran parte de la pantalla.
            Positioned(
              top: 120,
              left: 16,
              right: 16,
              bottom: 20,
              child: Container(
                padding:
                    const EdgeInsets.only(top: 70, left: 16, right: 16, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nombre(s)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Apellido Paterno',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        apellidoPaterno,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Apellido Materno',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        apellidoMaterno,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Correo Electrónico',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        correo,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Avatar en la intersección entre el degradado y el recuadro blanco.
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? (profileImageUrl.startsWith('http')
                          ? NetworkImage(profileImageUrl)
                          : FileImage(File(profileImageUrl)))
                      : const AssetImage('assets/default_avatar.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}