import 'package:flutter/material.dart';

/// Pantalla de Seguridad con animaciones suaves y transiciones.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _isBiometricsEnabled = false;
  bool _isPinEnabled = false;

  /// Función que devuelve una ruta personalizada con transiciones animadas.
  Route _createRoute(Widget screen) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Combina una transición de desvanecimiento con un deslizado.
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Colocamos el botón de cerrar en el lado izquierdo.
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Seguridad', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // Opción: Biometría con AnimatedSwitcher para animar el cambio del ícono.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: ListTile(
              // La key depende del estado para que se active la animación al cambiar.
              key: ValueKey<bool>(_isBiometricsEnabled),
              leading: Icon(
                Icons.fingerprint,
                color: _isBiometricsEnabled ? Colors.blue : Colors.grey,
              ),
              title: const Text('Biometría'),
              trailing: Switch(
                value: _isBiometricsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isBiometricsEnabled = value;
                  });
                  if (value) {
                    // Navega a la pantalla de configuración con animación.
                    Navigator.push(
                      context,
                      _createRoute(const BiometricOptionsScreen()),
                    );
                  }
                },
              ),
            ),
          ),
          const Divider(),
          // Opción: Pin Personalizado con animación en el ícono.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: ListTile(
              key: ValueKey<bool>(_isPinEnabled),
              leading: Icon(
                Icons.lock_outline,
                color: _isPinEnabled ? Colors.blue : Colors.grey,
              ),
              title: const Text('Pin Personalizado'),
              trailing: Switch(
                value: _isPinEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isPinEnabled = value;
                  });
                  if (value) {
                    // Navega a la pantalla de configurar el PIN con animación.
                    Navigator.push(
                      context,
                      _createRoute(const CustomPinScreen()),
                    );
                  }
                },
              ),
            ),
          ),
          const Divider(),
          // Opción: Cambiar Contraseña con indicación de navegación.
          ListTile(
            leading: const Icon(Icons.vpn_key, color: Colors.grey),
            title: const Text('Cambiar Contraseña'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                _createRoute(const ChangePasswordScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Stub de la pantalla de configuración de Biometría.
class BiometricOptionsScreen extends StatelessWidget {
  const BiometricOptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración de Biometría"),
      ),
      body: const Center(
        child: Text("Opciones de Biometría aquí"),
      ),
    );
  }
}

/// Stub de la pantalla para configurar el PIN personalizado.
class CustomPinScreen extends StatelessWidget {
  const CustomPinScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración de Pin Personalizado"),
      ),
      body: const Center(
        child: Text("Opciones para configurar tu PIN personalizado"),
      ),
    );
  }
}

/// Stub de la pantalla para cambiar la contraseña.
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cambiar Contraseña"),
      ),
      body: const Center(
        child: Text("Formulario para cambiar la contraseña"),
      ),
    );
  }
}