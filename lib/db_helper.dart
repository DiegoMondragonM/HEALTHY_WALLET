import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "billetera_local.db");
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        correo TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tarjetas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        correo TEXT,
        nombre_tarjeta TEXT,
        numero_tarjeta TEXT,
        tipo_tarjeta TEXT,
        monto REAL,
        fecha_vencimiento TEXT,
        pin TEXT,
        color INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE movimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        correo TEXT,
        tarjeta_id INTEGER,
        encabezado TEXT,
        tipo TEXT,
        monto REAL,
        detalles TEXT,
        fecha_movimiento TEXT
      )
    ''');
  }

  // ─── TARJETAS ──────────────────────────────────────
  Future<int> insertarTarjeta(Map<String, dynamic> tarjeta) async {
    final dbClient = await db;
    return await dbClient.insert('tarjetas', tarjeta);
  }

  Future<List<Map<String, dynamic>>> obtenerTarjetas(String correo) async {
    final dbClient = await db;
    return await dbClient.query(
      'tarjetas',
      where: 'correo = ?',
      whereArgs: [correo],
    );
  }

  Future<int> eliminarTarjeta(int tarjetaId) async {
    final dbClient = await db;
    return await dbClient.delete(
      'tarjetas',
      where: 'id = ?',
      whereArgs: [tarjetaId],
    );
  }

  // ─── MOVIMIENTOS ───────────────────────────────────
  Future<int> insertarMovimiento(Map<String, dynamic> movimiento) async {
    final dbClient = await db;
    return await dbClient.insert('movimientos', movimiento);
  }

  Future<List<Map<String, dynamic>>> obtenerMovimientos(
    String correo,
    int tarjetaId,
  ) async {
    final dbClient = await db;
    return await dbClient.query(
      'movimientos',
      where: 'correo = ? AND tarjeta_id = ?',
      whereArgs: [correo, tarjetaId],
    );
  }

  Future<int> eliminarMovimientosPorTarjeta(int tarjetaId) async {
    final dbClient = await db;
    return await dbClient.delete(
      'movimientos',
      where: 'tarjeta_id = ?',
      whereArgs: [tarjetaId],
    );
  }

  // Total del monto inicial de todas las tarjetas del usuario
  Future<double> obtenerTotalSaldoInicial(String correo) async {
    final dbClient = await db;
    final result = await dbClient.rawQuery(
      'SELECT SUM(monto) as total FROM tarjetas WHERE correo = ?',
      [correo],
    );
    final total = result.first['total'];
    return total != null ? total as double : 0.0;
  }

  Future<void> actualizarMontoTarjeta(int tarjetaId, double cambioMonto) async {
    final dbClient = await db;
    await dbClient.rawUpdate(
      '''
    UPDATE tarjetas
    SET monto = monto + ?
    WHERE id = ?
    ''',
      [cambioMonto, tarjetaId],
    );
  }

  // Total de los gastos registrados en movimientos
  Future<double> obtenerTotalGastos(String correo) async {
    final dbClient = await db;
    final result = await dbClient.rawQuery(
      '''
      SELECT SUM(monto) as total FROM movimientos
      WHERE correo = ? AND LOWER(tipo) = 'gasto'
      ''',
      [correo],
    );
    final total = result.first['total'];
    return total != null ? total as double : 0.0;
  }

  // ─── USUARIOS ──────────────────────────────────────
  Future<int> registrarUsuario(Map<String, dynamic> usuario) async {
    final dbClient = await db;
    return await dbClient.insert('usuarios', usuario);
  }

  Future<Map<String, dynamic>?> validarUsuario(
    String correo,
    String password,
  ) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'usuarios',
      where: 'correo = ? AND password = ?',
      whereArgs: [correo, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> obtenerUsuariosRegistrados() async {
    final dbClient = await db;
    return await dbClient.query('usuarios');
  }

  Future<List<Map<String, dynamic>>> obtenerTodosLosMovimientos(
    String correo,
  ) async {
    final dbClient = await db;
    return await dbClient.query(
      'movimientos',
      where: 'correo = ?',
      whereArgs: [correo],
    );
  }

  //eliminar datos
  Future<int> eliminarTarjetaYMovimientos(int tarjetaId, String correo) async {
    final dbClient = await db;

    // Primero eliminamos los movimientos relacionados
    await dbClient.delete(
      'movimientos',
      where: 'tarjeta_id = ? AND correo = ?',
      whereArgs: [tarjetaId, correo],
    );

    // Luego eliminamos la tarjeta
    return await dbClient.delete(
      'tarjetas',
      where: 'id = ? AND correo = ?',
      whereArgs: [tarjetaId, correo],
    );
  }
}
