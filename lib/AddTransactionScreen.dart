import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mi_wallet/db_helper.dart';

class DetailEntry {
  TextEditingController descriptionController;
  TextEditingController amountController;

  DetailEntry({
    required this.descriptionController,
    required this.amountController,
  });
}

class AddTransactionScreen extends StatefulWidget {
  final String correo;
  final int tarjetaId;
  final Map<String, dynamic> card;

  const AddTransactionScreen({
    super.key,
    required this.correo,
    required this.tarjetaId,
    required this.card,
  });

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _headerController = TextEditingController();
  final _amountController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();

  String _operationType = "Ingreso";
  DateTime selectedDate = DateTime.now();
  bool _showDetails = false;
  bool _submitted = false;

  List<DetailEntry> detailEntries = [];

  @override
  void initState() {
    super.initState();
    detailEntries.add(
      DetailEntry(
        descriptionController: TextEditingController(),
        amountController: TextEditingController(),
      ),
    );
    for (var entry in detailEntries) {
      entry.amountController.addListener(_updateTotals);
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _amountController.dispose();
    for (var entry in detailEntries) {
      entry.descriptionController.dispose();
      entry.amountController.dispose();
    }
    super.dispose();
  }

  void _updateTotals() => setState(() {});

  double get totalDetailAmount {
    double total = 0.0;
    for (var entry in detailEntries) {
      String text =
          entry.amountController.text
              .replaceAll("\$", "")
              .replaceAll(",", "")
              .trim();
      double value = double.tryParse(text) ?? 0.0;
      total += value;
    }
    return total;
  }

  String get formattedTotal => "\$${totalDetailAmount.toStringAsFixed(2)}";

  bool get isAmountMatching {
    String topText =
        _amountController.text.replaceAll("\$", "").replaceAll(",", "").trim();
    double topValue = double.tryParse(topText) ?? 0.0;
    return (topValue == totalDetailAmount);
  }

  void _addDetailEntry(int index) {
    setState(() {
      var newEntry = DetailEntry(
        descriptionController: TextEditingController(),
        amountController: TextEditingController(),
      );
      newEntry.amountController.addListener(_updateTotals);
      detailEntries.insert(index + 1, newEntry);
    });
  }

  void _removeDetailEntry(int index) {
    if (detailEntries.length > 1) {
      setState(() {
        detailEntries.removeAt(index);
      });
    }
  }

  void _onSave() async {
    setState(() {
      _submitted = true;
    });

    if (!_formKey.currentState!.validate()) return;

    String header = _headerController.text.trim();
    String totalText =
        _amountController.text.replaceAll("\$", "").replaceAll(",", "").trim();
    double totalAmount = double.tryParse(totalText) ?? 0.0;

    String detalles = "";
    for (int i = 0; i < detailEntries.length; i++) {
      String desc = detailEntries[i].descriptionController.text.trim();
      String amount =
          detailEntries[i].amountController.text
              .replaceAll("\$", "")
              .replaceAll(",", "")
              .trim();
      if (desc.isNotEmpty && amount.isNotEmpty) {
        detalles += "$desc: $amount";
        if (i < detailEntries.length - 1) detalles += "\n";
      }
    }

    Map<String, dynamic> movimiento = {
      "correo": widget.correo,
      "tarjeta_id": widget.tarjetaId,
      "encabezado": header,
      "tipo": _operationType.toLowerCase(),
      "monto": totalAmount,
      "detalles": detalles.isEmpty ? null : detalles,
      "fecha_movimiento": DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(selectedDate),
    };

    try {
      await _dbHelper.insertarMovimiento(movimiento);

      //  Actualizar el saldo de la tarjeta:
      if (_operationType.toLowerCase() == 'gasto') {
        await _dbHelper.actualizarMontoTarjeta(widget.tarjetaId, -totalAmount);
      } else if (_operationType.toLowerCase() == 'ingreso') {
        await _dbHelper.actualizarMontoTarjeta(widget.tarjetaId, totalAmount);
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool requiredField = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color.fromARGB(255, 238, 238, 238),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF4568DC), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator:
              (value) =>
                  requiredField && value!.isEmpty ? 'Campo obligatorio' : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        title: const Text(
          'Agregar Movimiento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _headerController,
                label: "Encabezado",
                hintText: "Ej. Compra en supermercado",
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _amountController,
                label: "Monto Total",
                hintText: "\$0.00",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _operationType,
                items:
                    ["Ingreso", "Gasto"].map((e) {
                      return DropdownMenuItem<String>(
                        value: e,
                        child: Row(
                          children: [
                            Icon(
                              e == "Ingreso"
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: e == "Ingreso" ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(e, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (val) => setState(() => _operationType = val!),
                decoration: InputDecoration(
                  labelText: "Tipo de Movimiento",
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 238, 238, 238),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4568DC),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("Fecha: "),
                  const SizedBox(width: 8),
                  Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (int i = 0; i < detailEntries.length; i++) ...[
                _buildTextField(
                  controller: detailEntries[i].descriptionController,
                  label: "Detalle ${i + 1} - Descripción",
                  hintText: "Ej. Leche",
                  requiredField: false,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: detailEntries[i].amountController,
                  label: "Monto",
                  hintText: "\$0.00",
                  keyboardType: TextInputType.number,
                  requiredField: false,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (detailEntries.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeDetailEntry(i),
                      ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _addDetailEntry(i),
                    ),
                  ],
                ),
                const Divider(),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4568DC),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Guardar Movimiento",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
