import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilService {
  static Future<String?> obtenerRolUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final perfilSnap = await FirebaseFirestore.instance.collection('perfiles').doc(user.uid).get();
    if (!perfilSnap.exists) return null;
    return (perfilSnap.data()?['rol'] as String?)?.trim().toLowerCase();
  }
}