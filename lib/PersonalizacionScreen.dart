import 'package:flutter/material.dart';

/// Screen de Personalización.
class PersonalizacionScreen extends StatefulWidget {
  const PersonalizacionScreen({Key? key}) : super(key: key);

  @override
  _PersonalizacionScreenState createState() => _PersonalizacionScreenState();
}

class _PersonalizacionScreenState extends State<PersonalizacionScreen> {
  bool _isDarkModeEnabled = false;
  
  /// Función para crear rutas personalizadas con transición.
  Route _createRoute(Widget screen) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Combina FadeTransition con SlideTransition.
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
    // Dependiendo del modo oscuro, se modifican los colores.
    final backgroundColor = _isDarkModeEnabled ? Colors.black : Colors.white;
    final appBarColor = _isDarkModeEnabled ? Colors.black : Colors.white;
    final appBarTextColor = _isDarkModeEnabled ? Colors.white : Colors.black;
    final iconColor = _isDarkModeEnabled ? Colors.white : Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Personalización', style: TextStyle(color: appBarTextColor)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: appBarTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // Opción: Modo Oscuro, con Switch y animación.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: ListTile(
              key: ValueKey<bool>(_isDarkModeEnabled),
              leading: Icon(Icons.dark_mode, color: _isDarkModeEnabled ? Colors.blue : iconColor),
              title: Text(
                'Modo Oscuro',
                style: TextStyle(color: appBarTextColor, fontSize: 16),
              ),
              trailing: Switch(
                value: _isDarkModeEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isDarkModeEnabled = value;
                  });
                },
              ),
            ),
          ),
          const Divider(),
          // Opción: Tema / Fondo
          ListTile(
            leading: Icon(Icons.color_lens, color: iconColor),
            title: Text(
              'Tema / Fondo',
              style: TextStyle(color: appBarTextColor, fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              Navigator.push(context, _createRoute(const ThemeOptionsScreen()));
            },
          ),
          const Divider(),
          // Opción: Idioma / Región.
          ListTile(
            leading: Icon(Icons.language, color: iconColor),
            title: Text(
              'Idioma / Región',
              style: TextStyle(color: appBarTextColor, fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              Navigator.push(context, _createRoute(const LanguageRegionScreen()));
            },
          ),
          const Divider(),
          // Opción: Moneda y Formato de Fecha.
          ListTile(
            leading: Icon(Icons.monetization_on, color: iconColor),
            title: Text(
              'Moneda y Fecha',
              style: TextStyle(color: appBarTextColor, fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              Navigator.push(context, _createRoute(const CurrencyDateFormatScreen()));
            },
          ),
        ],
      ),
    );
  }
}

/// Pantalla para seleccionar opciones de tema
class ThemeOptionsScreen extends StatelessWidget {
  const ThemeOptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Puedes personalizar esta pantalla
      appBar: AppBar(
        title: const Text("Tema / Fondo"),
      ),
      body: Center(
        child: Text(
          "Selecciona un color para el fondo del WalletScreen:\n- Morado\n- Azul marino\n- Naranja\n- Verde",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

/// Pantalla para seleccionar Idioma y Región.
class LanguageRegionScreen extends StatelessWidget {
  const LanguageRegionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stub para idioma y región
      appBar: AppBar(
        title: const Text("Idioma / Región"),
      ),
      body: Center(
        child: Text(
          "Elige el idioma y región de la aplicación:\n(Ejemplo: Español, Inglés, etc.)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

/// Pantalla para cambiar la moneda local y formato de fecha.
class CurrencyDateFormatScreen extends StatelessWidget {
  const CurrencyDateFormatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stub para moneda y formato de fecha
      appBar: AppBar(
        title: const Text("Moneda y Fecha"),
      ),
      body: Center(
        child: Text(
          "Selecciona la moneda local (MXN, USD, EUR, ...) y el formato de fecha (DD/MM/AAAA o MM/DD/AAAA).",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
