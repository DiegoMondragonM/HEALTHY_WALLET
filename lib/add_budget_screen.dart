import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_wallet/db_helper.dart';

class AddBudgetScreen extends StatefulWidget {
  final String correo;
  final int tarjetaId;
  final Map<String, dynamic> card;
  final Map<String, dynamic>? presupuesto; // Presupuesto para editar (opcional)

  const AddBudgetScreen({
    Key? key,
    required this.correo,
    required this.tarjetaId,
    required this.card,
    this.presupuesto,
  }) : super(key: key);

  @override
  _AddBudgetScreenState createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  String _categoria = 'Hogar';
  DateTime _fecha = DateTime.now();
  final DBHelper _dbHelper = DBHelper();

  final List<String> _categorias = [
    'Hogar',
    'Personal',
    'Entretenimiento',
    'Salud',
    'Transporte',
    'Educación',
    'Otros'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.presupuesto != null) {
      // Si viene un presupuesto para editar, cargar datos en los campos
      _nombreController.text = widget.presupuesto!['nombre'] ?? '';
      _montoController.text = (widget.presupuesto!['monto'] ?? '').toString();
      _categoria = widget.presupuesto!['categoria'] ?? 'Hogar';
      // Parsear fecha yyyy-MM
      try {
        _fecha = DateFormat('yyyy-MM').parse(widget.presupuesto!['fecha']);
      } catch (_) {
        _fecha = DateTime.now();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.presupuesto != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Presupuesto' : 'Agregar Presupuesto'),
        backgroundColor: const Color(0xFF4568DC),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre del Presupuesto',
                hintText: 'Ej. Luz, Supermercado',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _montoController,
                label: 'Monto del Presupuesto',
                hintText: '\$0.00',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _categoria,
                items: _categorias.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoria = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text('Fecha: ${DateFormat('MMMM yyyy').format(_fecha)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _fecha,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDatePickerMode: DatePickerMode.year,
                  );
                  if (picked != null && picked != _fecha) {
                    setState(() {
                      _fecha = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isEditing ? _actualizarPresupuesto : _guardarPresupuesto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4568DC),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                child: Text(isEditing ? 'Guardar Cambios' : 'Guardar Presupuesto'),
              ),
              if (isEditing) ...[
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _eliminarPresupuesto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                  child: const Text('Eliminar Presupuesto'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }

  Future<void> _guardarPresupuesto() async {
    if (!_formKey.currentState!.validate()) return;

    final presupuesto = {
      'correo': widget.correo,
      'tarjeta_id': widget.tarjetaId,
      'nombre': _nombreController.text,
      'monto': double.parse(_montoController.text),
      'categoria': _categoria,
      'fecha': DateFormat('yyyy-MM').format(_fecha),
      'monto_restante': double.parse(_montoController.text),
    };

    try {
      await _dbHelper.insertarPresupuesto(presupuesto);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  Future<void> _actualizarPresupuesto() async {
    if (!_formKey.currentState!.validate()) return;

    final presupuestoEditado = {
      'id': widget.presupuesto!['id'], // Asegúrate que el presupuesto tiene id
      'correo': widget.correo,
      'tarjeta_id': widget.tarjetaId,
      'nombre': _nombreController.text,
      'monto': double.parse(_montoController.text),
      'categoria': _categoria,
      'fecha': DateFormat('yyyy-MM').format(_fecha),
      'monto_restante': double.parse(_montoController.text),
    };

    try {
      await _dbHelper.actualizarPresupuesto(presupuestoEditado);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  Future<void> _eliminarPresupuesto() async {
    final id = widget.presupuesto!['id'];
    bool confirmar = false;

    // Confirmar antes de eliminar
    confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Seguro que deseas eliminar este presupuesto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirmar) return;

    try {
      await _dbHelper.eliminarPresupuesto(id);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }
}




/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_wallet/db_helper.dart';

class AddBudgetScreen extends StatefulWidget {
  final String correo;
  final int tarjetaId;
  final Map<String, dynamic> card;



  const AddBudgetScreen({
    Key? key,
    required this.correo,
    required this.tarjetaId,
    required this.card,
  }) : super(key: key);

  @override
  _AddBudgetScreenState createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  String _categoria = 'Hogar';
  DateTime _fecha = DateTime.now();
  final DBHelper _dbHelper = DBHelper();

  final List<String> _categorias = [
    'Hogar',
    'Personal',
    'Entretenimiento',
    'Salud',
    'Transporte',
    'Educación',
    'Otros'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Presupuesto'),
        backgroundColor: const Color(0xFF4568DC),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre del Presupuesto',
                hintText: 'Ej. Luz, Supermercado',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _montoController,
                label: 'Monto del Presupuesto',
                hintText: '\$0.00',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _categoria,
                items: _categorias.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoria = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text('Fecha: ${DateFormat('MMMM yyyy').format(_fecha)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _fecha,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDatePickerMode: DatePickerMode.year,
                  );
                  if (picked != null && picked != _fecha) {
                    setState(() {
                      _fecha = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _guardarPresupuesto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4568DC),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                child: const Text('Guardar Presupuesto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }

  Future<void> _guardarPresupuesto() async {
    if (!_formKey.currentState!.validate()) return;

    final presupuesto = {
      'correo': widget.correo,
      'tarjeta_id': widget.tarjetaId,
      'nombre': _nombreController.text,
      'monto': double.parse(_montoController.text),
      'categoria': _categoria,
      'fecha': DateFormat('yyyy-MM').format(_fecha),
      'monto_restante': double.parse(_montoController.text),
    };

    try {
      await _dbHelper.insertarPresupuesto(presupuesto);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }
}*/