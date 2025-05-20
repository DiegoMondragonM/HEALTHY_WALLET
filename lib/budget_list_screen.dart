import 'package:flutter/material.dart';
import 'package:mi_wallet/db_helper.dart';

class BudgetsListScreen extends StatelessWidget {
  final String correo;
  final int tarjetaId;

  const BudgetsListScreen({
    Key? key,
    required this.correo,
    required this.tarjetaId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Presupuestos'),
        backgroundColor: const Color(0xFF4568DC),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper().obtenerPresupuestos(correo, tarjetaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay presupuestos registrados'));
          }

          final presupuestos = snapshot.data!;
          return ListView.builder(
            itemCount: presupuestos.length,
            itemBuilder: (context, index) {
              final presupuesto = presupuestos[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(presupuesto['nombre']),
                  subtitle: Text(
                    "Categoría: ${presupuesto['categoria']}",
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "\$${presupuesto['monto'].toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Restante: \$${presupuesto['monto_restante'].toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4568DC),
        onPressed: () async {
          // Navegar a AddBudgetScreen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}