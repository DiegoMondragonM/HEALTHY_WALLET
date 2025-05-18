import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_wallet/ProfileScreen.dart';
import 'package:mi_wallet/SaludFinancieraScreen.dart';
import 'package:mi_wallet/WalletScreen.dart';
import 'package:intl/intl.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:mi_wallet/db_helper.dart';

class AddCardScreen extends StatefulWidget {
  final String correo;
  final String nombreUsuario;

  const AddCardScreen({
    super.key,
    required this.correo,
    required this.nombreUsuario,
  });

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final DBHelper _dbHelper = DBHelper();
  bool _autoValidate = false;
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  String cardType = 'Visa';
  Color cardColor = const Color(0xFF4568DC);

  List<Color> availableColors = [
    Colors.purple[300]!,
    Colors.blue[300]!,
    Colors.green[300]!,
    Colors.orange[300]!,
    Colors.red[300]!,
    Colors.orange[300]!,
    const Color(0xFFFF9800),
  ];
  @override
  void initState() {
    super.initState();

    nameController.addListener(() => setState(() {}));
    numberController.addListener(() => setState(() {}));
    expiryDateController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    amountController.dispose();
    expiryDateController.dispose();
    pinController.dispose();
    super.dispose();
  }

  Widget _buildColorPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children:
          availableColors.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  cardColor = color;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border:
                      cardColor == color
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                ),
              ),
            );
          }).toList(),
    );
  }

  Future<void> _submitCard() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autoValidate = true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final dbHelper = DBHelper();
      final double? monto = double.tryParse(
        amountController.text.replaceAll(RegExp(r'[^\d.]'), ''),
      );
      final cardData = {
        'correo': widget.correo,
        'nombre_tarjeta': nameController.text.trim(),
        'numero_tarjeta': numberController.text.replaceAll(' ', ''),
        'tipo_tarjeta': cardType,
        'monto':
            double.tryParse(
              amountController.text.replaceAll(RegExp(r'[^\d.]'), ''),
            ) ??
            0.0,
        'pin':
            pinController.text.trim().isEmpty
                ? null
                : pinController.text.trim(),
        'fecha_vencimiento': expiryDateController.text.trim(),
        // ignore: deprecated_member_use
        'color': cardColor.value,
      };

      final result = await dbHelper.insertarTarjeta(cardData);

      if (result > 0) {
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
      } else {
        _showSnackBar('Error al guardar la tarjeta');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(width: 8.0),
            const Text(
              'Registrar Tarjeta',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              // Vista previa de la tarjeta.
              _buildCardPreview(),
              const SizedBox(height: 20.0),
              // Formulario.
              Form(
                key: _formKey,
                autovalidateMode:
                    _autoValidate
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                child: Column(
                  children: [
                    // Nombre de la Tarjeta (obligatorio)
                    _buildOvalTextField(
                      controller: nameController,
                      label: 'Nombre de la Tarjeta',
                      hintText: 'Ejemplo: Mi Tarjeta Personal',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    // Número de la Tarjeta (obligatorio; debe ser de 16 dígitos)
                    _buildOvalTextField(
                      controller: numberController,
                      label: 'Número de la Tarjeta',
                      hintText: '1234 5678 9012 3456',
                      keyboardType: TextInputType.number,
                      inputFormatters: [CardNumberInputFormatter()],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        // Quitamos los espacios y comprobamos la cantidad
                        final digits = value.replaceAll(' ', '');
                        if (digits.length != 16) {
                          return 'El número debe tener 16 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    // Selector de tipo de tarjeta.
                    _buildCardTypeField(),
                    const SizedBox(height: 20.0),
                    // Monto de la Tarjeta (obligatorio)
                    _buildOvalTextField(
                      controller: amountController,
                      label: 'Monto de la Tarjeta',
                      hintText: '\$0.00 pesos',
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    // Fecha de Vencimiento (obligatorio)
                    _buildOvalTextField(
                      controller: expiryDateController,
                      label: 'Fecha de Vencimiento (MM/AAAA)',
                      hintText: '12/2025',
                      inputFormatters: [ExpiryDateInputFormatter()],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        // Opcional: agregar validación de formato.
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    // Nuevo campo: PIN (opcional, numérico de 4 dígitos)
                    _buildOvalTextField(
                      controller: pinController,
                      label: 'Ingrese un PIN',
                      hintText: '1234 (opcional)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.length != 4) {
                            return 'El PIN debe ser de 4 dígitos';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40.0),
                    _buildColorPicker(), // Selector de color
                    const SizedBox(height: 40.0),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          // Aquí la lógica de navegación del BottomNavigationBar.
          // Actualizamos el índice y verificamos la navegación.
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => WalletScreen(
                      nombreUsuario:
                          widget
                              .nombreUsuario, // aquí podrías pasar el nombre si lo guardas en sesión
                      correo: widget.correo,
                    ),
              ),
            );
          } else if (index == 1) {
            // Salud financiera
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
            // Estamos en Agregar Tarjeta; no hacemos nada.
          } else if (index == 4) {
            // Perfil
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
          setState(() {});
        },
        selectedItemColor: Color(0xFF4568DC),
        unselectedItemColor: Colors.grey[400],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Tarjetas"),

          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            label: "Finanzas",
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

  // Vista previa de la tarjeta que se actualiza en tiempo real
  Widget _buildCardPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nameController.text.isNotEmpty
                ? nameController.text
                : "Nombre de la Tarjeta",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            numberController.text.isNotEmpty
                ? numberController.text
                : "**** **** **** 1234",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expiryDateController.text.isNotEmpty
                        ? expiryDateController.text
                        : "MM/AAAA",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    cardType,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              //const Icon(Icons.credit_card, color: Colors.white, size: 40.0),
            ],
          ),
        ],
      ),
    );
  }

  // Oval TextField con fondo blanco
  Widget _buildOvalTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.15,
            ), // Color y opacidad de la sombra
            blurRadius: 3, // Difuminado de la sombra
            offset: const Offset(0, 2), // Posición de la sombra (x, y)
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15.0,
            horizontal: 20.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Selector de tipo de tarjeta usando botones que muestran el logo y, si está seleccionado, un check
  Widget _buildCardTypeField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCardTypeButton('Visa', 'assets/visa.png'),
        _buildCardTypeButton('Mastercard', 'assets/mastercard.png'),
        _buildCardTypeButton('American Express', 'assets/amex.png'),
      ],
    );
  }

  Widget _buildCardTypeButton(String type, String assetPath) {
    bool isSelected = cardType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          cardType = type;
        });
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              border:
                  isSelected
                      ? Border.all(color: Colors.deepPurple, width: 2)
                      : Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Image.asset(
              assetPath,
              width: 60,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          if (isSelected)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // Botón para guardar la tarjeta.
  // Al pulsar Guardar, si el formulario no es válido, activamos la autovalidación.
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _submitCard,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4568DC), // Azul BBVA
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
      ),
      child: const Text('Guardar Tarjeta', style: TextStyle(fontSize: 18.0)),
    );
  }
}

// ─── FORMATO PARA NÚMERO DE TARJETA ─────────────────────────────
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length > 16) {
      digitsOnly = digitsOnly.substring(0, 16);
    }
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i != 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += digitsOnly[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ─── FORMATO PARA MONTO DE TARJETA ─────────────────────────────
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat integerFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: "\$",
    decimalDigits: 0,
  );
  final NumberFormat decimalFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: "\$",
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String rawText = newValue.text;
    String allowedText = rawText.replaceAll(RegExp(r'[^\d.]'), '');
    bool isDecimalMode = allowedText.contains('.');
    String formatted = '';

    if (!isDecimalMode) {
      if (allowedText.isEmpty) {
        return const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }
      int? intValue = int.tryParse(allowedText);
      if (intValue == null) return oldValue;
      formatted = integerFormat.format(intValue);
    } else {
      int dotIndex = allowedText.indexOf('.');
      String integerPart = allowedText.substring(0, dotIndex);
      String decimalPart = allowedText.substring(dotIndex + 1);
      if (decimalPart.length > 2) {
        return oldValue;
      }
      if (integerPart.isEmpty) {
        integerPart = '0';
      }
      if (allowedText.endsWith('.') || decimalPart.length < 2) {
        int? intVal = int.tryParse(integerPart);
        String formattedInteger =
            intVal != null ? integerFormat.format(intVal) : integerPart;
        formatted = "$formattedInteger.$decimalPart";
      } else {
        int? intVal = int.tryParse(integerPart);
        String formattedInteger =
            intVal != null ? integerFormat.format(intVal) : integerPart;
        formatted = "$formattedInteger.${decimalPart.padRight(2, '0')}";
      }
    }

    // Preservar posición del cursor
    String prefixRaw = newValue.text.substring(
      0,
      newValue.selection.extentOffset,
    );
    String prefixAllowed = prefixRaw.replaceAll(RegExp(r'[^\d.]'), '');
    int targetCount = prefixAllowed.length;
    int currentCount = 0;
    int newCursorPosition = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (RegExp(r'[\d.]').hasMatch(formatted[i])) {
        currentCount++;
      }
      if (currentCount >= targetCount) {
        newCursorPosition = i + 1;
        break;
      }
    }
    newCursorPosition = newCursorPosition.clamp(0, formatted.length);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}

// ─── FORMATO PARA FECHA DE VENCIMIENTO ──────────────────────────
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length > 6) {
      digitsOnly = digitsOnly.substring(0, 6);
    }
    String formatted =
        digitsOnly.length <= 2
            ? digitsOnly
            : '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
