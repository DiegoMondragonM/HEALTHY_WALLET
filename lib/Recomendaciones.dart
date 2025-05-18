import 'package:flutter/material.dart';
import 'package:mi_wallet/WalletScreen.dart';
import 'package:mi_wallet/SaludFinancieraScreen.dart';
import 'package:mi_wallet/AddCardScreen.dart';
import 'package:mi_wallet/ProfileScreen.dart';

class RecomendacionesScreen extends StatefulWidget {
  final String nombreUsuario;
  final String correo;

  const RecomendacionesScreen({
    super.key,
    required this.correo,
    required this.nombreUsuario,
  });

  @override
  State<RecomendacionesScreen> createState() => _RecomendacionesScreenState();
}

class _RecomendacionesScreenState extends State<RecomendacionesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      _addBotMessage(
        '¡Hola, ${widget.nombreUsuario}! 👋\nSoy tu asistente financiero. ¿En qué puedo ayudarte hoy?',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox(),
        title: Text(
          'Asistente Financiero',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(),
                  const SizedBox(height: 20),
                  _buildProgressCard(),
                  const SizedBox(height: 20),
                  _buildTipCard(
                    icon: Icons.auto_graph,
                    title: 'Consejo del día',
                    content:
                        'Empieza con el 20% de tus ingresos. Ahorra \$100 por cada \$500 que ganes.',
                  ),
                  const SizedBox(height: 15),
                  _buildQuickTipsSection(),
                  const SizedBox(height: 20),
                  if (_messages.isNotEmpty) ...[
                    const Text(
                      'Conversación:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(children: _messages.map((msg) => msg).toList()),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          _buildChatInput(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
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
                      nombreUsuario: widget.nombreUsuario,
                      correo: widget.correo,
                    ),
              ),
            );
          } else if (index == 2) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => AddCardScreen(
                      nombreUsuario: widget.nombreUsuario,
                      correo: widget.correo,
                    ),
              ),
            );
            setState(() => _currentIndex = 0);
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ProfileScreen(
                      nombreUsuario: widget.nombreUsuario,
                      correo: widget.correo,
                    ),
              ),
            );
          }
        },
        selectedItemColor: const Color(0xFF4568DC),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Tarjetas"),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            label: "Salud",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_card_rounded),
            label: "Agregar",
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

  void _simulateBotResponse(String userMessage) {
    String lower = userMessage.toLowerCase();
    String response;
    if (lower.contains('ahorrar') || lower.contains('ahorro')) {
      response =
          '💡 Consejos para ahorrar:\n• Regla 50/30/20\n• Automatiza transferencias\n• Elimina gastos hormiga';
    } else if (lower.contains('invertir')) {
      response =
          '📈 Invierte desde CETES, fondos indexados, hasta crypto (con precaución).';
    } else {
      response =
          '¿Quieres hablar de ahorros, inversiones, deudas o presupuestos?';
    }
    _addBotMessage(response);
  }

  void _addBotMessage(String text) {
    setState(() => _isTyping = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(ChatMessage(text: text, isUser: false));
        _scrollToBottom();
        _isTyping = false;
      });
    });
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _scrollToBottom();
    });
    _simulateBotResponse(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, ${widget.nombreUsuario} 👋',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Te ayudaré a optimizar tus finanzas con consejos personalizados',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF4568DC).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.savings, color: Color(0xFF4568DC)),
                const SizedBox(width: 10),
                const Text(
                  'Meta mensual',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Chip(
                  label: const Text('40% completado'),
                  backgroundColor: const Color(0xFF4568DC).withOpacity(0.2),
                  labelStyle: const TextStyle(color: Color(0xFF4568DC)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const LinearProgressIndicator(
              value: 0.4,
              backgroundColor: Colors.grey,
              color: Color(0xFF4568DC),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4568DC).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF4568DC)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(content, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones rápidas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildActionChip('¿Cómo ahorrar en comida?', Icons.restaurant),
            _buildActionChip('Inversiones básicas', Icons.trending_up),
            _buildActionChip('Reducir suscripciones', Icons.subscriptions),
            _buildActionChip('Presupuesto mensual', Icons.pie_chart),
          ],
        ),
      ],
    );
  }

  Widget _buildActionChip(String label, IconData icon) {
    return ActionChip(
      label: Text(label),
      avatar: Icon(icon, size: 18),
      onPressed: () {
        _addUserMessage(label);
      },
      backgroundColor: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Pregúntame sobre finanzas...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  _addUserMessage(text);
                  _messageController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF4568DC),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  _addUserMessage(_messageController.text);
                  _messageController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isUser ? Colors.grey : const Color(0xFF4568DC),
            child: Icon(
              isUser ? Icons.person : Icons.savings,
              color: Colors.white,
              size: 18,
            ),
            radius: 15,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? Colors.grey[200]
                        : const Color(0xFF4568DC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: text.startsWith('**') ? FontWeight.bold : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
