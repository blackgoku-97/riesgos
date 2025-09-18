import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';

class VerUsuariosScreen extends StatefulWidget {
  const VerUsuariosScreen({super.key});

  @override
  State<VerUsuariosScreen> createState() => _VerUsuariosScreenState();
}

class _VerUsuariosScreenState extends State<VerUsuariosScreen> {
  late Future<List<Map<String, dynamic>>> _usuariosFuture;
  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _filtrados = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usuariosFuture = _cargarUsuarios();
  }

  Future<List<Map<String, dynamic>>> _cargarUsuarios() async {
    final snap = await FirebaseFirestore.instance
        .collection('perfiles')
        .where('rol', isEqualTo: 'usuario')
        .get();

    final lista = snap.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'nombre': data['nombre'] ?? '',
        'email': data['email'] ?? '',
        'cargo': data['cargo'] ?? '',
        'rol': data['rol'] ?? '',
      };
    }).toList();

    _usuarios = lista;
    _filtrados = lista;
    return lista;
  }

  void _filtrar(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtrados = _usuarios);
    } else {
      setState(() {
        _filtrados = _usuarios.where((u) {
          final nombre = (u['nombre'] ?? '').toString().toLowerCase();
          final cargo = (u['cargo'] ?? '').toString().toLowerCase();
          return nombre.contains(q) || cargo.contains(q);
        }).toList();
      });
    }
  }

  Future<void> _refrescar() async {
    final lista = await _cargarUsuarios();
    setState(() {
      _usuarios = lista;
      _filtrados = lista;
    });
  }

  Future<void> _eliminarUsuario(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: const Text('¿Seguro que quieres eliminar este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojo),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseFirestore.instance.collection('perfiles').doc(id).delete();
      _refrescar();
    }
  }

  void _editarUsuario(Map<String, dynamic> usuario) async {
    final nombreCtrl = TextEditingController(text: usuario['nombre']);
    final cargoCtrl = TextEditingController(text: usuario['cargo']);

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: cargoCtrl,
              decoration: const InputDecoration(labelText: 'Cargo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojo),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (guardar == true) {
      await FirebaseFirestore.instance
          .collection('perfiles')
          .doc(usuario['id'])
          .update({
        'nombre': nombreCtrl.text.trim(),
        'cargo': cargoCtrl.text.trim(),
      });
      _refrescar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      appBar: AppBar(
        backgroundColor: AppColors.rojo,
        title: const Text('Usuarios'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usuariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (_filtrados.isEmpty) {
            return Column(
              children: [
                _buildSearchBar(),
                const Expanded(
                  child: Center(child: Text('No hay usuarios registrados')),
                ),
              ],
            );
          }
          return Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refrescar,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtrados.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final u = _filtrados[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.rojo,
                          child: Text(
                            u['nombre'].isNotEmpty
                                ? u['nombre'][0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          u['nombre'].isNotEmpty ? u['nombre'] : u['email'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${u['cargo']} • ${u['rol']}'.trim(),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editarUsuario(u),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarUsuario(u['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _filtrar,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o cargo...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        ),
      ),
    );
  }
}