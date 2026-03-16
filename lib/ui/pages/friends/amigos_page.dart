import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config.dart'; // Importamos la configuración
import '../../../data/models/user_model.dart';

class AmigosPage extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const AmigosPage({super.key, required this.usuario});

  @override
  State<AmigosPage> createState() => _AmigosPageState();
}

class _AmigosPageState extends State<AmigosPage> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _misAmigos = [];
  List<UserModel> _resultadosBusqueda = [];
  bool _isSearching = false;
  bool _isLoadingAmigos = true;

  @override
  void initState() {
    super.initState();
    _cargarMisAmigos();
  }

  Future<void> _cargarMisAmigos() async {
    setState(() => _isLoadingAmigos = true);
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/amigos/mis-amigos/${widget.usuario['id']}'),
      );
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        setState(() {
          _misAmigos = data.map((u) => UserModel.fromMap(u)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error cargando amigos: $e");
    } finally {
      setState(() => _isLoadingAmigos = false);
    }
  }

  Future<void> _buscarNuevosAmigos(String query) async {
    if (query.length < 3) {
      setState(() => _resultadosBusqueda = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/usuarios/buscar?query=$query&miId=${widget.usuario['id']}'),
      );
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        setState(() {
          _resultadosBusqueda = data.map((u) => UserModel.fromMap(u)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error buscando usuarios: $e");
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _anadirAmigo(int amigoId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/amigos/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'miId': widget.usuario['id'],
          'amigoId': amigoId,
        }),
      );
      if (response.statusCode == 200) {
        _cargarMisAmigos();
        setState(() {
          _resultadosBusqueda = [];
          _searchController.clear();
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡AMIGO AÑADIDO!")),
        );
      }
    } catch (e) {
      debugPrint("Error añadiendo amigo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("GESTIÓN DE AMIGOS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _buscarNuevosAmigos,
                decoration: InputDecoration(
                  hintText: "BUSCAR NUEVOS AMIGOS...",
                  hintStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  prefixIcon: const Icon(Icons.person_search, color: Colors.black),
                  suffixIcon: _isSearching 
                      ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) 
                      : null,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text("RESULTADOS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                Expanded(child: Divider(indent: 10, color: Colors.black, thickness: 1)),
              ],
            ),
          ),
          Expanded(
            child: _searchController.text.isNotEmpty
                ? _buildResultadosBusqueda()
                : _buildListaMisAmigos(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultadosBusqueda() {
    if (_resultadosBusqueda.isEmpty && !_isSearching) {
      return const Center(child: Text("NO SE ENCONTRARON USUARIOS", style: TextStyle(fontWeight: FontWeight.bold)));
    }
    return ListView.builder(
      itemCount: _resultadosBusqueda.length,
      itemBuilder: (context, i) {
        final user = _resultadosBusqueda[i];
        bool yaEsAmigo = _misAmigos.any((amigo) => amigo.id == user.id);
        return ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.black, child: Icon(Icons.person, color: Colors.white)),
          title: Text(user.nameUsuario.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: yaEsAmigo 
              ? const Icon(Icons.check_circle, color: Colors.green)
              : IconButton(
                  icon: const Icon(Icons.person_add_alt_1, color: Colors.black),
                  onPressed: () => _anadirAmigo(user.id!),
                ),
        );
      },
    );
  }

  Widget _buildListaMisAmigos() {
    if (_isLoadingAmigos) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }
    if (_misAmigos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text("AÚN NO TIENES AMIGOS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: _misAmigos.length,
      itemBuilder: (context, i) {
        final amigo = _misAmigos[i];
        return ListTile(
          leading: const CircleAvatar(backgroundColor: Color(0xFFE1FF00), child: Icon(Icons.person, color: Colors.black)),
          title: Text(amigo.nameUsuario.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(amigo.name),
          trailing: const Icon(Icons.verified, color: Colors.blue, size: 20),
        );
      },
    );
  }
}
