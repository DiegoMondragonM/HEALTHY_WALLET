import 'package:flutter/material.dart';
import 'package:mi_wallet/db_helper.dart';

class AgregarAhorroScreen extends StatefulWidget {
  final String correo;
  final int tarjetaId;
  final String nombreTarjeta;

  const AgregarAhorroScreen({
    Key? key,
    required this.correo,
    required this.tarjetaId,
    required this.nombreTarjeta,
  }) : super(key: key);

  @override
  State<AgregarAhorroScreen> createState() => _AgregarAhorroScreenState();
}

class _AgregarAhorroScreenState extends State<AgregarAhorroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _montoController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();
  bool _isLoading = false;

  Future<void> _guardarAhorro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final monto = double.tryParse(_montoController.text);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ingresa un monto válido")));
      setState(() => _isLoading = false);
      return;
    }

    try {
      await _dbHelper.insertarAhorro({
        'correo': widget.correo,
        'tarjeta_id': widget.tarjetaId,
        'monto': monto,
        'fecha': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Ahorro registrado")));

      Navigator.pop(context, true);
      //Navigator.pop(context, true)
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Agregar Ahorro",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4568DC),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Tarjeta de información
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.credit_card, color: Colors.blue[700]),
                        const SizedBox(width: 10),
                        Text(
                          widget.nombreTarjeta,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Campo de monto
                TextFormField(
                  controller: _montoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Monto a ahorrar",
                    hintText: "Ej. 500.00",
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: Colors.green,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF4568DC)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingresa un monto";
                    }
                    final val = double.tryParse(value);
                    if (val == null || val <= 0) {
                      return "Monto inválido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Botón de acción
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _guardarAhorro,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4568DC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.savings, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  "GUARDAR AHORRO",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
