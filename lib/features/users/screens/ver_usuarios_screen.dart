import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../widgets/user_list_tile.dart';
import '../widgets/user_search_bar.dart';
import '../widgets/user_edit_dialog.dart';
import '../widgets/confirm_delete_dialog.dart';

class VerUsuariosScreen extends StatefulWidget {
  const VerUsuariosScreen({super.key});

  @override
  State<VerUsuariosScreen> createState() => _VerUsuariosScreenState();
}

class _VerUsuariosScreenState extends State<VerUsuariosScreen> {
  late Future<List<Map<String, dynamic>>> _usuariosFuture = Future.value([]);
  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _filtrados = [];
  final TextEditingController _searchCtrl = TextEditingController();
  String? _rolUsuario;

  @override
  void initState() {
    super.initState();
    _verificarAdmin();
  }

  Future<void> _verificarAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      _redirigirALogin('Debes iniciar sesión como administrador');
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('perfiles')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final rol = (doc.data()?['rol'] ?? '').toString().trim().toLowerCase();
      setState(() {
        _rolUsuario = rol;
      });
      if (rol != 'admin') {
        if (!mounted) return;
        _redirigirALogin('No tienes permisos de administrador');
        return;
      }
      setState(() {
        _usuariosFuture = _cargarUsuarios();
      });
    } catch (e) {
      if (!mounted) return;
      _redirigirALogin('Error verificando permisos: $e');
    }
  }

  void _redirigirALogin(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
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
        'rut': data['rut'] ?? '',
        'rutFormateado': data['rutFormateado'] ?? '',
      };
    }).toList();

    lista.sort((a, b) => a['nombre']
        .toString()
        .toLowerCase()
        .compareTo(b['nombre'].toString().toLowerCase()));

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
          final email = (u['email'] ?? '').toString().toLowerCase();
          final rut = (u['rutFormateado'] ?? u['rut'] ?? '').toString().toLowerCase();
          return nombre.contains(q) ||
              cargo.contains(q) ||
              email.contains(q) ||
              rut.contains(q);
        }).toList();
      });
    }
  }

  Future<void> _refrescar() async {
    final lista = await _cargarUsuarios();
    if (!mounted) return;
    setState(() {
      _usuarios = lista;
      _filtrados = lista;
    });
  }

  Future<void> _eliminarUsuario(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDeleteDialog(),
    );
    if (confirmar != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay sesión activa en FirebaseAuth')),
      );
      return;
    }

    try {
      // 👇 fuerza token fresco antes de llamar a la función
      await user.getIdToken(true);

      await FirebaseFunctions.instance
          .httpsCallable('eliminarUsuario')
          .call({'uid': id});

      await _refrescar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado correctamente')),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    }
  }

  Future<void> _editarUsuario(Map<String, dynamic> usuario) async {
    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => UserEditDialog(usuario: usuario),
    );
    if (resultado != null) {
      await FirebaseFirestore.instance
          .collection('perfiles')
          .doc(usuario['id'])
          .update({
        'nombre': resultado['nombre']!,
        'cargo': resultado['cargo']!,
        'rut': resultado['rut']!,
        'rutFormateado': resultado['rutFormateado']!,
      });
      if (!mounted) return;
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
      body: Column(
        children: [
          if (_rolUsuario != null)
            Container(
              width: double.infinity,
              color: _rolUsuario == 'admin' ? Colors.green : Colors.orange,
              padding: const EdgeInsets.all(8),
              child: Text(
                'Estás logueado como ${_rolUsuario!.toUpperCase()}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
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
                      UserSearchBar(controller: _searchCtrl, onChanged: _filtrar),
                      const Expanded(
                        child: Center(child: Text('No hay usuarios registrados')),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    UserSearchBar(controller: _searchCtrl, onChanged: _filtrar),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refrescar,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtrados.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final u = _filtrados[index];
                            return UserListTile(
                              usuario: u,
                              onEdit: () => _editarUsuario(u),
                              onDelete: () => _eliminarUsuario(u['id']),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}