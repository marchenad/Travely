import '../models/user_model.dart';
import '../providers/database_herlper.dart';

class UserRepository {
  // REGISTRAR USUARIO
  Future<void> createUser(UserModel user) async {
    final conn = await DatabaseHelper.connection;
    await conn.execute(
      r'INSERT INTO usuarios (name_usuario, name, correo, password, premium) VALUES ($1, $2, $3, $4, $5)',
      parameters: [user.nameUsuario, user.name, user.correo, user.password, user.premium],
    );
  }

  // BUSCAR POR EMAIL PARA LOGIN
  Future<UserModel?> getUserByEmail(String correo) async {
    final conn = await DatabaseHelper.connection;
    final results = await conn.execute(
      r'SELECT * FROM usuarios WHERE correo = $1',
      parameters: [correo],
    );

    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first.toColumnMap());
  }
}