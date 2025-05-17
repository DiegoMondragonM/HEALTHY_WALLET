import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mi_wallet/AddTransactionScreen.dart';
import 'package:mi_wallet/db_helper.dart';

class CardDetailScreen extends StatefulWidget {
  final String correo;
  final Map<String, dynamic> card;

  const CardDetailScreen({Key? key, required this.card, required this.correo})
    : super(key: key);

  @override
  _CardDetailScreenState createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final DBHelper _dbHelper = DBHelper();
  double _monthlyExpenses = 0.0;
  double _monthlyIncomes = 0.0;
  List<Map<String, dynamic>> _movimientos = [];
  double _cardBalance = 0.0;
  double? _saldoBase;
  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_MX', '').then((_) {
      Intl.defaultLocale = 'es_MX';
      _saldoBase = double.tryParse(widget.card['monto'].toString()) ?? 0.0;
      _cardBalance = _saldoBase!;
      _fetchMovimientos();
    });
  }

  Future<void> _fetchMovimientos() async {
    try {
      final data = await _dbHelper.obtenerMovimientos(
        widget.correo,
        widget.card['id'],
      );
      setState(() => _movimientos = data);
      _recalcularSaldoYTotales();
    } catch (e) {
      print('Error al obtener movimientos locales: $e');
    }
  }

  void _recalcularSaldoYTotales() {
    final grupos = groupMovimientosPorMes();
    final currentKey = DateFormat('MMMM-yyyy', 'es_MX').format(DateTime.now());
    final movimientosMes = grupos[currentKey] ?? [];

    double ingresos = 0.0, gastos = 0.0;
    for (var m in movimientosMes) {
      final monto = double.tryParse(m['monto'].toString()) ?? 0.0;
      if (m['tipo'].toString().toLowerCase() == 'ingreso')
        ingresos += monto;
      else
        gastos += monto;
    }

    setState(() {
      _monthlyIncomes = ingresos;
      _monthlyExpenses = gastos;
    });
  }

  Future<void> _openAddTransaction() async {
    final inserted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddTransactionScreen(
              correo: widget.correo,
              tarjetaId: widget.card['id'],
              card: widget.card,
            ),
      ),
    );
    if (inserted == true) {
      await _fetchMovimientos();
      await _actualizarMontoTarjeta();
    }
  }

  Future<void> _actualizarMontoTarjeta() async {
    final tarjetas = await _dbHelper.obtenerTarjetas(widget.correo);
    final tarjetaActualizada = tarjetas.firstWhere(
      (t) => t['id'] == widget.card['id'],
      orElse: () => {},
    );
    if (tarjetaActualizada.isNotEmpty) {
      setState(() {
        _cardBalance =
            double.tryParse(tarjetaActualizada['monto'].toString()) ??
            _cardBalance;
      });
    }
  }

  Future<void> _deleteCardAndMovements() async {
    try {
      final deleted = await _dbHelper.eliminarTarjetaYMovimientos(
        widget.card['id'],
        widget.correo,
      );
      if (deleted > 0) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al borrar la tarjeta')),
        );
      }
    } catch (e) {
      print('Error eliminando localmente: $e');
    }
  }

  Map<String, List<Map<String, dynamic>>> groupMovimientosPorMes() {
    final grupos = <String, List<Map<String, dynamic>>>{};
    for (var m in _movimientos) {
      final fecha = DateTime.tryParse(m['fecha_movimiento']) ?? DateTime.now();
      final key = DateFormat('MMMM-yyyy', 'es_MX').format(fecha);
      grupos.putIfAbsent(key, () => []).add(m);
    }
    return grupos;
  }

  // El resto del build se mantiene igual, pero quitamos lógica de peticiones http
  // y usamos _movimientos como fuente.

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar personalizado sin flecha y con ícono "X" pegado a la esquina
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              padding:
                  EdgeInsets
                      .zero, // Quita el padding extra para acercarlo al borde
              icon: const Icon(Icons.close, size: 32, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      // Uso de Stack para posicionar el botón de borrar tarjeta en la parte inferior
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Vista previa de la tarjeta
                _buildDetailedCardPreview(widget.card),
                const SizedBox(height: 16),
                // Sección: Saldo de la Tarjeta
                _buildSectionHeader("Saldo de la Tarjeta"),
                _buildCardBalance(widget.card),
                const SizedBox(height: 16),
                // Nuevos apartados: Gastos Mensuales e Ingresos Mensuales
                _buildMonthlySummary(),
                const SizedBox(height: 16),

                // Sección: Ingresos y Gastos (con botón de agregar más pequeño)
                // Dentro de tu Column principal:
                // 1) Fila de título + botón
                // 1) Header con botón circular
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader("Ingresos y Gastos"),
                    _buildIncomeExpenseSection(
                      widget.card,
                    ), // tu botón circular aquí
                  ],
                ),

                const SizedBox(height: 12),

                // 2) Lista de movimientos
                _buildMonthlyMovementsList(),

                const SizedBox(
                  height: 100,
                ), // Asegura espacio para el botón flotante
              ],
            ),
          ),
          // Botón de borrar tarjeta posicionado en la parte inferior central
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Center(child: _buildDeleteButton()),
          ),
        ],
      ),
    );
  }

  // Cabecera de cada sección.
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  String formatCardNumber(String cardNumber) {
    // Quita cualquier espacio existente
    cardNumber = cardNumber.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < cardNumber.length; i++) {
      if (i != 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += cardNumber[i];
    }
    return formatted;
  }

  // Vista previa detallada de la tarjeta.
  Widget _buildDetailedCardPreview(Map<String, dynamic> card) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(card['color']),
        borderRadius: BorderRadius.circular(20), // más redondeado
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card['nombre_tarjeta'] ?? 'Nombre de la Tarjeta',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            formatCardNumber(card['numero_tarjeta'] ?? 'XXXX XXXX XXXX XXXX'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            'Tipo: ${card['tipo_tarjeta']}',
            style: const TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          const SizedBox(height: 10.0),
          Text(
            'Vence: ${card['fecha_vencimiento']}',
            style: const TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyMovementsList() {
    // Agrupamos los movimientos por mes usando la función groupMovimientosPorMes()
    Map<String, List<Map<String, dynamic>>> grupos = groupMovimientosPorMes();

    // Obtenemos la lista de claves (meses) y las ordenamos de forma descendente (mes más reciente primero)
    List<String> keys = grupos.keys.toList();
    keys.sort((a, b) {
      DateTime da = DateFormat('MMMM-yyyy', 'es_ES').parse(a);
      DateTime db = DateFormat('MMMM-yyyy', 'es_ES').parse(b);
      return db.compareTo(da);
    });

    List<Widget> sections = [];
    for (String mes in keys) {
      // Agrega el encabezado de la sección
      sections.add(_buildSectionHeader(toTitleCase(mes)));
      // Por cada movimiento de este mes, usa tu widget ya definido _buildMovementCard
      for (var mov in grupos[mes]!) {
        sections.add(_buildMovementCard(mov));
      }
      // Espacio entre secciones
      sections.add(const SizedBox(height: 20));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }

  Widget _buildMovementCard(Map mov) {
    final dt = DateTime.parse(mov['fecha_movimiento']);
    final fecha = DateFormat('dd/MM/yyyy').format(dt);
    final isIngreso = mov['tipo'] == 'ingreso';
    final colorHeader = isIngreso ? Colors.green : Colors.red;
    final sign = isIngreso ? '+\$' : '-\$';
    final montoTxt = '$sign${mov['monto'].toString()}';

    final w = MediaQuery.of(context).size.width * 0.9;

    return Container(
      width: w,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Columna izq.: fecha + encabezado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fecha, style: TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  mov['encabezado'],
                  style: TextStyle(
                    fontSize: 16,
                    color: colorHeader,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Monto a la derecha
          Text(
            montoTxt,
            style: TextStyle(
              fontSize: 16,
              color: colorHeader,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Muestra el saldo de la tarjeta.
  Widget _buildCardBalance(_) {
    final bal = _cardBalance.toStringAsFixed(2);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFEDEDED), // gris claro uniforme
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        "\$$bal",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Sección para registrar ingresos y gastos con un botón más pequeño.
  Widget _buildIncomeExpenseSection(Map<String, dynamic> card) {
    return Tooltip(
      message: "Añadir Ingresos o Gastos",
      child: ElevatedButton(
        onPressed: _openAddTransaction, // usa tu método de navegación + recarga
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  // Sección compuesta de dos cuadros: Gastos Mensuales e Ingresos Mensuales.
  // Sección compuesta de dos cuadros: Gastos Mensuales e Ingresos Mensuales.
  Widget _buildMonthlySummary() {
    return Row(
      children: [
        // ─── Gastos Mensuales ─────
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0), // Naranja claro
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Gastos Mensuales",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9800), // Naranja
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  "\$${_monthlyExpenses.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // ─── Ingresos Mensuales ─────
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD), // Azul claro
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Ingresos Mensuales",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4568DC), // Azul
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  "\$${_monthlyIncomes.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return ElevatedButton.icon(
      onPressed: onDeleteCard,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      ),
      icon: const Icon(Icons.delete, size: 20),
      label: const Text('Borrar Tarjeta', style: TextStyle(fontSize: 18.0)),
    );
  }

  /// Función para borrar la tarjeta y sus movimientos asociados
  Future<bool> deleteCardWithMovimientos() async {
    try {
      final dbHelper = DBHelper();
      final id = widget.card['id'];

      // Primero eliminamos los movimientos asociados
      await dbHelper.eliminarMovimientosPorTarjeta(id);

      // Luego eliminamos la tarjeta
      final rowsDeleted = await dbHelper.eliminarTarjeta(id);

      return rowsDeleted > 0;
    } catch (e) {
      print('Error al borrar la tarjeta y movimientos: $e');
      return false;
    }
  }

  /// Método que se invoca al presionar el botón de eliminar en la UI
  void onDeleteCard() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirmar eliminación"),
            content: const Text(
              "¿Estás seguro de que deseas borrar esta tarjeta? Se eliminarán todos los movimientos asociados.",
            ),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text("Eliminar"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );

    if (confirm == true) {
      bool success = await deleteCardWithMovimientos();
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al borrar la tarjeta. Intenta nuevamente.'),
          ),
        );
      }
    }
  }
}
