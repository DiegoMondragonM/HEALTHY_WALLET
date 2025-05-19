import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_wallet/AddCardScreen.dart';
import 'package:mi_wallet/PersonalizacionScreen.dart';
import 'package:mi_wallet/SaludFinancieraScreen.dart';
import 'package:mi_wallet/SecurityScreen.dart';
import 'package:mi_wallet/UserProfileScreen.dart';
import 'package:mi_wallet/WalletScreen.dart';
import 'package:mi_wallet/db_helper.dart';
import 'package:mi_wallet/login_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  final String nombreUsuario;
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
  int _currentIndex = 3;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _cargarFotoUsuario();
  }

  /// Carga la ruta de foto desde SQLite e inicializa el avatar
  Future<void> _cargarFotoUsuario() async {
    final usuario = await DBHelper().obtenerUsuario(widget.correo);
    final ruta = usuario?['foto'] as String?;
    if (ruta != null && ruta.isNotEmpty) {
      setState(() => _profileImage = File(ruta));
    }
  }

  /// Actualiza la imagen de perfil cuando regresa de la pantalla de edición
  void _updateProfileImage(File? image) {
    if (image != null) setState(() => _profileImage = image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => WalletScreen(
                      nombreUsuario: widget.nombreUsuario,
                      correo: widget.correo,
                    ),
              ),
            );
          } else if (index == 1) {
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
            setState(() {
              _currentIndex = 3;
            });
          } else if (index == 3) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        selectedItemColor: const Color(0xFF4568DC),
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
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
                  CircleAvatar(
                    radius: 32,
                    backgroundImage:
                        _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                    child:
                        _profileImage == null
                            ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
                            : null,
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => EditarPerfilScreen(
                                nombreUsuario: widget.nombreUsuario,
                                correo: widget.correo,
                                onImageSelected:
                                    _updateProfileImage, // Pasamos la función que actualizará la imagen
                              ),
                        ),
                      );
                    },
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
                          // Navegamos a la pantalla de perfil con el diseño solicitado
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => UserProfileScreen(
                                    nombre: widget.nombreUsuario,
                                    apellidoPaterno:
                                        "Apellido Paterno", // Puedes reemplazar con la info real
                                    apellidoMaterno:
                                        "Apellido Materno", // Puedes reemplazar con la info real
                                    correo: widget.correo,
                                    profileImageUrl:
                                        _profileImage != null
                                            ? _profileImage!.path
                                            : 'assets/default_avatar.png',
                                  ),
                            ),
                          );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PersonalizacionScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      // Segunda sección: "Cambiar contraseña" y "Soporte"
                      _buildBoton(
                        title: 'Seguridad',
                        icon: Icons.security,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SecurityScreen(),
                            ),
                          );
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
        color: Colors.white70,
        borderRadius: BorderRadius.circular(16),
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

// ----------------------- SCREEN EDITAR PERFIL -----------------------
class EditarPerfilScreen extends StatefulWidget {
  final String nombreUsuario;
  final String correo;
  final void Function(File?) onImageSelected;

  const EditarPerfilScreen({
    Key? key,
    required this.nombreUsuario,
    required this.correo,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  late final TextEditingController _nombreController;
  late final TextEditingController _correoController;
  late final TextEditingController _apellidoPaternoController;
  late final TextEditingController _apellidoMaternoController;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombreUsuario);
    _correoController = TextEditingController(text: widget.correo);
    _apellidoPaternoController = TextEditingController();
    _apellidoMaternoController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    super.dispose();
  }

  /// Pide permiso y abre la galería
  Future<void> _pickImageFromGallery() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      // En Android < 13 necesitas READ_EXTERNAL_STORAGE
      // En Android ≥ 13 necesitas READ_MEDIA_IMAGES, que el plugin mapea a Permission.photos
      if (await Permission.storage.isGranted ||
          await Permission.photos.isGranted) {
        status = PermissionStatus.granted;
      } else {
        // Solicita ambos; al menos uno debe ser aceptado
        final result = await [Permission.storage, Permission.photos].request();
        status =
            result[Permission.storage]!.isGranted
                ? result[Permission.storage]!
                : result[Permission.photos]!;
      }
    } else {
      // iOS / otros
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      // Abre la galería
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) setState(() => _imageFile = File(picked.path));
    } else if (status.isPermanentlyDenied) {
      // Lleva a ajustes
      await showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Permiso necesario'),
              content: const Text(
                'Activa el permiso para acceder a la galería en los ajustes de tu dispositivo.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Ir a Ajustes'),
                ),
              ],
            ),
      );
    } else {
      // Denegado (pero no permanentemente) o restricted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo acceder a la galería')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El fondo se define en el Container
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4568DC), Color(0xFFB06AB3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // Utilizamos SafeArea para evitar superposiciones con el notch o statusbar
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado: Botón "X" a la izquierda y título centrado.
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Editar Perfil",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Se agrega un IconButton transparente para balancear el Row.
                    Opacity(
                      opacity: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Botón grande para cambiar la foto de perfil.
                // Se utiliza un CircleAvatar para mostrar la foto de perfil.
                // 1) Mostrar la foto (o placeholder)
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1) El avatar (o placeholder)
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            _imageFile != null ? FileImage(_imageFile!) : null,
                        child:
                            _imageFile == null
                                ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                )
                                : null,
                      ),

                      // 2) El botón de cámara posicionado abajo-derecha
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _pickImageFromGallery,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Campo de texto "Nombre(s)"
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Nombre(s)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Campo de texto "Apellido Paterno"
                TextField(
                  controller: _apellidoPaternoController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Apellido Paterno",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Campo de texto "Apellido Materno"
                TextField(
                  controller: _apellidoMaternoController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Apellido Materno",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Campo de texto "Correo Electrónico"
                TextField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Correo Electrónico",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Botón "Guardar" en la parte inferior central.
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_imageFile != null) {
                        // 1) Guarda la ruta en SQLite:
                        await DBHelper().actualizarFotoUsuario(
                          widget.correo,
                          _imageFile!.path,
                        );
                        // 2) Llama al callback para actualizar ProfileScreen inmediatamente:
                        widget.onImageSelected(_imageFile);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                        255,
                        3,
                        60,
                        106,
                      ), // Fondo azul.
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Guardar",
                      style: TextStyle(
                        color: Colors.orange, // Letras en naranja.
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
