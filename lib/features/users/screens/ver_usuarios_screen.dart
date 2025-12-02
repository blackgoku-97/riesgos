import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../widgets/user_list_tile.dart';
import '../widgets/user_search_bar.dart';
import '../widgets/user_edit_dialog.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/user_create_dialog.dart';

class VerUsuariosScreen extends StatefulWidget {
  const VerUsuariosScreen({super.key});

  @override
  State<VerUsuariosScreen> createState() => _VerUsuariosScreenState();
}

class _VerUsuariosScreenState extends State<VerUsuariosScreen> {
  late Future<List<Map<String, dynamic>>> _usuariosFuture = Future.value([]);
  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _filtrados = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verificarAdmin();
  }

  void _showSnack(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _verificarAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _redirigirALogin('Debes iniciar sesión como administrador');
    try {
      final doc = await FirebaseFirestore.instance.collection('perfiles').doc(user.uid).get();
      final rol = (doc.data()?['rol'] ?? '').toString().trim().toLowerCase();
      if (rol != 'admin') return _redirigirALogin('No tienes permisos de administrador');
      setState(() => _usuariosFuture = _cargarUsuarios());
    } catch (e) {
      _redirigirALogin('Error verificando permisos: $e');
    }
  }

  void _redirigirALogin(String mensaje) {
    _showSnack(mensaje);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<List<Map<String, dynamic>>> _cargarUsuarios() async {
    final snap = await FirebaseFirestore.instance.collection('perfiles').where('rol', isEqualTo: 'usuario').get();
    final lista = snap.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'nombre': data['nombre'] ?? '',
        'email': data['email'] ?? '',
        'cargo': data['cargo'] ?? '',
        'rol': data['rol'] ?? '',
        'rut': data['rut'] ?? '',
        'rutFormateado': data['rutFormateado'] ?? '',
      };
    }).toList()
      ..sort((a, b) => a['nombre'].toString().toLowerCase().compareTo(b['nombre'].toString().toLowerCase()));
    _usuarios = lista;
    _filtrados = lista;
    return lista;
  }

  void _filtrar(String q) {
    q = q.trim().toLowerCase();
    setState(() {
      _filtrados = q.isEmpty
          ? _usuarios
          : _usuarios.where((u) {
              return ['nombre', 'cargo', 'email', 'rutFormateado', 'rut']
                  .any((f) => (u[f] ?? '').toString().toLowerCase().contains(q));
            }).toList();
    });
  }

  Future<void> _refrescar() async => setState(() => _usuariosFuture = _cargarUsuarios());

  Future<void> _eliminarUsuario(String id) async {
    final confirmar = await showDialog<bool>(context: context, builder: (_) => const ConfirmDeleteDialog());
    if (confirmar != true) return;
    try {
      final callable = FirebaseFunctions.instanceFor(app: Firebase.app(), region: 'southamerica-west1')
          .httpsCallable('eliminarUsuario');
      await callable.call({'uid': id});
      await _refrescar();
      _showSnack("Usuario eliminado correctamente");
    } catch (e) {
      _showSnack("Error al eliminar usuario: $e");
    }
  }

  Future<void> _editarUsuario(Map<String, dynamic> usuario) async {
    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => UserEditDialog(usuario: usuario),
    );
    if (resultado != null) {
      await FirebaseFirestore.instance.collection('perfiles').doc(usuario['id']).update(resultado);
      _refrescar();
    }
  }

  Future<void> _mostrarDialogoCrearUsuario() async {
    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const UserCreateDialog(),
    );
    if (resultado != null) {
      try {
        final callable = FirebaseFunctions.instanceFor(app: Firebase.app(), region: 'southamerica-west1')
            .httpsCallable('createUserByAdmin');
        await callable.call(resultado);
        await _refrescar();
        _showSnack("Usuario creado con éxito");
      } catch (e) {
        _showSnack("Error al crear usuario: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      appBar: AppBar(backgroundColor: AppColors.rojo, title: const Text('Usuarios')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usuariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (_filtrados.isEmpty) {
            return Column(children: [
              UserSearchBar(controller: _searchCtrl, onChanged: _filtrar),
              const Expanded(child: Center(child: Text('No hay usuarios registrados'))),
            ]);
          }
          return Column(children: [
            UserSearchBar(controller: _searchCtrl, onChanged: _filtrar),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refrescar,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filtrados.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) => UserListTile(
                    usuario: _filtrados[i],
                    onEdit: () => _editarUsuario(_filtrados[i]),
                    onDelete: () => _eliminarUsuario(_filtrados[i]['id']),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.rojo,
        onPressed: _mostrarDialogoCrearUsuario,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}