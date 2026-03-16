class UserModel {
  // 1. Definimos las propiedades (deben coincidir con tus columnas de pgAdmin)
  final int? id;
  final String nameUsuario;
  final String name;
  final String correo;
  final String password;
  final bool premium;

  // 2. Constructor
  UserModel({
    this.id,
    required this.nameUsuario,
    required this.name,
    required this.correo,
    required this.password,
    this.premium = false,
  });

  // 3. De Mapa a Objeto (Para cuando LEEMOS de la base de datos)
  // Útil cuando hagas un "SELECT * FROM usuarios"
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      nameUsuario: data['name_usuario'],
      name: data['name'],
      correo: data['correo'],
      password: data['password'],
      premium: data['premium'] ?? false,
    );
  }

  // 4. De Objeto a Mapa (Para cuando ESCRIBIMOS en la base de datos)
  // Útil cuando hagas un "INSERT INTO usuarios..."
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