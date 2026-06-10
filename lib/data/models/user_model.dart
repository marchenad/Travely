class UserModel {
  final int? id;
  final String nameUsuario;
  final String name;
  final String? correo;    // Ahora es opcional
  final String? password;  // Ahora es opcional
  final bool premium;

  UserModel({
    this.id,
    required this.nameUsuario,
    required this.name,
    this.correo,           // Quitamos el 'required'
    this.password,         // Quitamos el 'required'
    this.premium = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      nameUsuario: data['name_usuario'] ?? '',
      name: data['name'] ?? '',
      correo: data['correo'],
      password: data['password'],
      premium: data['premium'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name_usuario': nameUsuario,
      'name': name,
      'correo': correo,
      'password': password,
      'premium': premium,
    };
  }
}
