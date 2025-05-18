import 'package:flutter/material.dart';
import 'add_budget_screen.dart';
import '../budget_model.dart';

class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({super.key});

  @override
  _BudgetListScreenState createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen> {
  List<Budget> budgets = []; // Lista de presupuestos (se llenará desde BD)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21), // Fondo oscuro futurista
      appBar: AppBar(
        title: const Text('Mis Presupuestos'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  return _buildBudgetCard(budgets[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
          ).then((newBudget) {
            if (newBudget != null) {
              setState(() {
                budgets.add(newBudget); // Agrega el nuevo presupuesto
              });
            }
          });
        },
        backgroundColor: const Color(0xFFFF9F1C), // Naranja futurista
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              budget.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${budget.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF00B4D8), // Azul brillante
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  budget.category,
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${budget.dueDate.day}/${budget.dueDate.month}/${budget.dueDate.year}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}