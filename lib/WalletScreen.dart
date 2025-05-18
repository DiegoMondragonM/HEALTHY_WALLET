import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_wallet/AddCardScreen.dart';
import 'package:mi_wallet/CardDetailScreen.dart';
import 'package:mi_wallet/ProfileScreen.dart';
import 'package:mi_wallet/SaludFinancieraScreen.dart';
//import 'package:http/http.dart' as http;
import 'package:mi_wallet/db_helper.dart';
import 'package:mi_wallet/Recomendaciones.dart';

class WalletScreen extends StatefulWidget {
  final String nombreUsuario; // sigue disponible si quieres mostrar el nombre
  final String correo; // ahora la PK que pasamos desde el login

  const WalletScreen({
    super.key,
    required this.nombreUsuario,
    required this.correo,
  });

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  //static const _baseUrl = 'http://10.0.2.2:3000'; //'http://10.0.2.2:3000' o 'http://192.168.1.71:3000'
  List<Map<String, dynamic>> userCards = [];
  int _currentIndex = 0; // Índice de la pestaña activa
  final DBHelper _dbHelper = DBHelper();
  late final PageController _pageController;
  double _saldoInicial = 0.0;
  double _totalGastos = 0.0;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.7,
    ); // ✅ Aquí lo inicializas bien
    _fetchCards();
    _calcularProgresoGastos();
  }

  Future<void> _fetchCards() async {
    try {
      final tarjetas = await _dbHelper.obtenerTarjetas(widget.correo);
      setState(() {
        userCards = tarjetas;
      });
      await _calcularProgresoGastos(); // 👈 Actualiza el progreso también
    } catch (e) {
      debugPrint('Error al cargar tarjetas: $e');
    }
  }

  Future<void> _calcularProgresoGastos() async {
    final saldo = await _dbHelper.obtenerTotalSaldoInicial(widget.correo);
    final gastos = await _dbHelper.obtenerTotalGastos(widget.correo);

    setState(() {
      _saldoInicial = saldo;
      _totalGastos = gastos;
    });
  }

  Widget _buildProgresoGasto() {
    if (_saldoInicial <= 0) return SizedBox();
    final porcentajeGastado = (_totalGastos / _saldoInicial).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.show_chart, color: Color(0xFF4568DC)),
              SizedBox(width: 8),
              Text(
                "Progreso de Gasto",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: porcentajeGastado,
              color: Color(0xFF4568DC),
              backgroundColor: Colors.grey[300],
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${(porcentajeGastado * 100).toStringAsFixed(1)}% del presupuesto usado",
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar personalizado: "TuApp" a la izquierda y botón lápiz a la derecha.
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hola!',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              widget.nombreUsuario,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.grey,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgresoGasto(),
            const SizedBox(height: 20),
            Expanded(
              child:
                  userCards.isEmpty
                      ? _buildNoCardsSection()
                      : _buildCardStack(),
            ),
          ],
        ),
      ),
      // Aquí es donde añadimos el FAB:
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4568DC),
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AddCardScreen(
                    correo: widget.correo,
                    nombreUsuario: widget.nombreUsuario,
                  ),
            ),
          );
          if (added == true) {
            _fetchCards(); // 🔄 refresca la lista
          }
        },
        child: const Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          // Actualiza el índice y navega según el ítem seleccionado.
          if (index == 0) {
            // Tarjetas: nos quedamos en esta pantalla.
            setState(() {
              _currentIndex = index;
            });
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
            setState(() {
              _currentIndex = index;
            });
          } else if (index == 2) {
            // Agregar Tarjeta: usa animación slide para navegar a AddCardScreen.
            final Map<String, dynamic>? newCard =
                await Navigator.push<Map<String, dynamic>>(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            AddCardScreen(
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
              // Al volver, forzamos que la pestaña activa sea "Tarjetas".
              _currentIndex = 0;
              if (newCard != null) {
                userCards.add(newCard);
              }
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
            // Perfil: navega a la pantalla de Perfil (ejemplo).
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ProfileScreen(
                      correo: widget.correo,
                      nombreUsuario: widget.nombreUsuario,
                    ),
              ),
            );
          }
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
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
    );
  }

  // Se muestra cuando no hay tarjetas registradas.
  Widget _buildNoCardsSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.credit_card, size: 100, color: Colors.black),
          const SizedBox(height: 20.0),
          const Text(
            '¡Ups! Aún no tienes tarjetas registradas.',
            style: TextStyle(fontSize: 17.0, color: Colors.black),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comienza agregando tu primera tarjeta con el botón +',
            style: TextStyle(fontSize: 16.0, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  String _formatCardNumber(String? number) {
    if (number == null || number.length < 4) return '**** **** ****';
    final visibleDigits = number.substring(number.length - 4);
    return '**** **** **** $visibleDigits';
  }

  void _showCardDetails(Map<String, dynamic> tarjeta) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardDetailScreen(card: tarjeta, correo: widget.correo),
      ),
    );

    // Siempre actualiza al volver
    _fetchCards();
    _calcularProgresoGastos();
  }

  Widget _buildCardStack() {
    return SizedBox(
      height: 280,
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: userCards.length,
        controller: _pageController,
        itemBuilder: (context, index) {
          final card = userCards[index];
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, index * 20),
                child: GestureDetector(
                  onTap: () => _showCardDetails(card),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(card['color'] ?? 0xFF4568DC),
                          Color(card['color'] ?? 0xFF4568DC).withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(4, 4),
                        ),
                        BoxShadow(
                          color: Colors.white24,
                          blurRadius: 6,
                          offset: Offset(-4, -4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card['nombre_tarjeta'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 12),
                            width: 45,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF7D488), Color(0xFFC79125)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 5,
                                  top: 6,
                                  right: 5,
                                  child: Container(
                                    height: 2,
                                    color: Colors.brown[800],
                                  ),
                                ),
                                Positioned(
                                  left: 5,
                                  top: 13,
                                  right: 5,
                                  child: Container(
                                    height: 2,
                                    color: Colors.brown[800],
                                  ),
                                ),
                                Positioned(
                                  left: 5,
                                  top: 20,
                                  right: 5,
                                  child: Container(
                                    height: 2,
                                    color: Colors.brown[800],
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  bottom: 5,
                                  left: 12,
                                  child: Container(
                                    width: 2,
                                    color: Colors.brown[800],
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  bottom: 5,
                                  right: 12,
                                  child: Container(
                                    width: 2,
                                    color: Colors.brown[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatCardNumber(card['numero_tarjeta']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                card['fecha_vencimiento'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                card['tipo_tarjeta'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            '\$${NumberFormat.currency(locale: 'es_MX', symbol: '').format(card['monto'])}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    CardDetailScreen(card: card, correo: widget.correo),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              Animation<Offset> slideAnimation = Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              );
              return SlideTransition(position: slideAnimation, child: child);
            },
          ),
        );
      },
      child: Card(
        color:
            card['color'] != null ? Color(card['color']) : Colors.purple[300]!,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card['nombre_tarjeta'] ?? 'Nombre de la Tarjeta',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                maskCardNumber(card['numero_tarjeta'] ?? 'XXXX XXXX XXXX XXXX'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tipo: ${card['tipo_tarjeta']}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Vence: ${card['fecha_vencimiento']}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Se construye la vista de tarjetas como una pila (Stack) con animación.

// Función auxiliar que enmascara los primeros 12 dígitos.
String maskCardNumber(String cardNumber) {
  // Si el número viene en formato "1234 5678 9012 3456", lo separamos por espacios.
  List<String> parts = cardNumber.split(' ');
  if (parts.length == 4) {
    // Enmascaramos los primeros 3 grupos y dejamos visible el último.
    return "**** **** **** ${parts[3]}";
  } else {
    // En caso de que el número no tenga ese formato, quitamos espacios y enmascaramos
    String digits = cardNumber.replaceAll(' ', '');
    if (digits.length <= 12) return cardNumber;
    String masked = '*' * 12 + digits.substring(12);
    // Opcional: puedes reinsertar espacios cada 4 dígitos si lo deseas.
    return masked.replaceAllMapped(
      RegExp(r".{4}"),
      (match) => "${match.group(0)} ",
    );
  }
}

// Widget que muestra los datos de la tarjeta.
// Dentro de _buildCardItem, envuelto en GestureDetector:

class AnimatedCardItem extends StatefulWidget {
  final Widget child;
  final int delay; // Retardo en milisegundos para el efecto en cascada

  const AnimatedCardItem({super.key, required this.child, this.delay = 0});

  @override
  _AnimatedCardItemState createState() => _AnimatedCardItemState();
}

class _AnimatedCardItemState extends State<AnimatedCardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _scaleAnimation;
  bool _hovering = false; // Controla si el mouse está sobre el widget

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Animación de entrada: desliza la tarjeta desde un 20% abajo a su posición final
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Animación de escalado: desde 0.9 a 1
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos MouseRegion para detectar cuando el mouse entra o sale,
    // y AnimatedContainer para animar la traslación vertical.
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (event) {
        setState(() {
          _hovering = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovering ? -20 : 0, 0),
        curve: Curves.easeInOut,
        child: SlideTransition(
          position: _offsetAnimation,
          child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
        ),
      ),
    );
  }
}
