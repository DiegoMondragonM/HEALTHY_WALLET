import 'package:flutter/material.dart';
import 'package:mi_wallet/AddCardScreen.dart';
import 'package:mi_wallet/SaludFinancieraScreen.dart';
import 'package:mi_wallet/WalletScreen.dart';
import 'package:mi_wallet/login_screen.dart';
import 'package:mi_wallet/Recomendaciones.dart';

class ProfileScreen extends StatefulWidget {
  final String nombreUsuario;
  // Si es necesario, agrega otros parámetros como correo.
  final String correo;

  const ProfileScreen({
    Key? key,
    required this.nombreUsuario,
    required this.correo,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Como en el menú de Wallet, la pestaña de Perfil es la última (índice 3)
  int _currentIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Usamos el mismo BottomNavigationBar de tu WalletScreen.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 0) {
            // Ítem "Tarjetas": navegamos a la pantalla de Wallet/Tarjetas.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => WalletScreen(
                      nombreUsuario:
                          widget
                              .nombreUsuario, // aquí podrías pasar el nombre si lo guardas en sesión
                      correo: widget.correo,
                    ),
              ),
            );
          } else if (index == 1) {
            // Ítem "Salud Financiera": navegamos a la pantalla correspondiente.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => SaludFinancieraScreen(
                      correo: widget.correo,
                      nombreUsuario: widget.nombreUsuario,
                    ),
              ),
            );
          } else if (index == 2) {
            // Ítem "Agregar Tarjeta": navegamos con animación a AddCardScreen.
            // Navega con animación a AddCardScreen sin asignar el resultado a una variable.
            await Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder:
                    (context, animation, secondaryAnimation) => AddCardScreen(
                      correo: widget.correo,
                      nombreUsuario: widget.nombreUsuario,
                    ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
            // Después de regresar de AddCardScreen, actualiza el índice.
            setState(() {
              _currentIndex = 4; // Regresa al índice de Perfil.
            });
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => RecomendacionesScreen(
                      correo: widget.correo,
                      nombreUsuario: widget.nombreUsuario,
                    ),
              ),
            );
            setState(() {
              _currentIndex = index;
            });
          } else if (index == 4) {
            // Ítem "Perfil": ya estás en esta pantalla.
            setState(() {
              _currentIndex = index;
            });
          }
        },
        selectedItemColor: Color(0xFF4568DC),
        unselectedItemColor: Colors.grey[500],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Tarjetas"),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            label: "Salud Financiera",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_card_rounded),
            label: "Agregar Tarjeta",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tips_and_updates_outlined),
            label: "Recomendaciones",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
      // Contenido principal del profileScreen
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4568DC), Color(0xFFB06AB3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage(
                      'assets/images/profile_pic.png',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hola 👋!',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          widget.nombreUsuario,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Contenedor blanco que muestra la lista de botones
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      // Primera sección: "Perfil", "Notificaciones" y "Personalización"
                      _buildBoton(
                        title: 'Perfil',
                        icon: Icons.account_circle,
                        onTap: () {
                          // Acción al seleccionar "Perfil"
                        },
                      ),
                      _buildBoton(
                        title: 'Notificaciones',
                        icon: Icons.notifications,
                        onTap: () {
                          // Acción para Notificaciones
                        },
                      ),
                      _buildBoton(
                        title: 'Personalización',
                        icon: Icons.brush,
                        onTap: () {
                          // Acción para Personalización
                        },
                      ),
                      const Divider(),
                      // Segunda sección: "Cambiar contraseña" y "Soporte"
                      _buildBoton(
                        title: 'Cambiar contraseña',
                        icon: Icons.lock,
                        onTap: () {
                          // Acción para cambiar contraseña
                        },
                      ),
                      _buildBoton(
                        title: 'Soporte',
                        icon: Icons.report_problem,
                        onTap: () {
                          // Acción para soporte
                        },
                      ),
                      const Divider(),
                      // Tercera sección: "Cerrar sesión"
                      _buildBoton(
                        title: 'Cerrar sesión',
                        icon: Icons.exit_to_app,
                        color:
                            Colors
                                .red, // Se especifica el color rojo para este botón
                        onTap: () {
                          _mostrarDialogoCerrarSesion(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Método auxiliar para construir cada botón con ícono.
  // Método _buildBoton modificado para aceptar un parámetro opcional "color"
  Widget _buildBoton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontSize: 16, color: color)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  /// Muestra un diálogo para confirmar el cierre de sesión.
  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Desea cerrar su sesión?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sí'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navegamos a la pantalla de login.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
