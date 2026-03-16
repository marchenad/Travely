import 'package:postgres/postgres.dart';

class DatabaseHelper {
  static Connection? _connection;

  static Future<Connection> get connection async {
    // CAMBIO AQUÍ: Usamos solo la nulidad para verificar
    if (_connection != null) {
      return _connection!;
    }

    try {
      _connection = await Connection.open(
        Endpoint(
          host: '10.0.2.2',
          database: 'Travely', // Cambia esto si usas otro nombre
          username: 'postgres',
          password: '1234',
          port: 5432,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.disable,
        ),
      );

      print("Conexión exitosa a PostgreSQL");
      return _connection!;
    } catch (e) {
      print("Error al conectar a la base de datos: $e");
      rethrow;
    }
  }

  static Future<void> closeConnection() async {
    // CAMBIO AQUÍ: La v3 usa .close() directamente
    if (_connection != null) {
      await _connection!.close();
      _connection = null; // Limpiamos la variable
    }
  }
}