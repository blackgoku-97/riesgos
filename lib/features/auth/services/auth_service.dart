import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Validadores públicos ---
  bool isValidEmail(String email) => _isValidEmail(email);
  bool isValidRUT(String rut) => _isValidRUT(rut);
  bool isValidPassword(String password) => _isValidPassword(password);
  bool startsWithCapital(String text) =>
      text.isNotEmpty && text[0] == text[0].toUpperCase();

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // --- Registro ---
  Future<void> registerUser({
    required String nombre,
    required String rut,
    required String cargo,
    required String email,
    required String password,
  }) async {
    if (!_isValidEmail(email)) throw Exception('El correo electrónico no es válido');
    if (!_isValidRUT(rut)) throw Exception('El RUT ingresado no es válido');
    if (!_isValidPassword(password)) {
      throw Exception('La contraseña debe tener mínimo 8 caracteres, 1 mayúscula y 1 número');
    }
    if (!startsWithCapital(nombre)) throw Exception('El nombre debe comenzar con mayúscula');
    if (!startsWithCapital(cargo)) throw Exception('El cargo debe comenzar con mayúscula');

    final perfilesRef = _db.collection('perfiles');

    int totalUsuarios;
    try {
      final countSnap = await perfilesRef.count().get();
      totalUsuarios = countSnap.count ?? 0;
    } catch (_) {
      final snap = await perfilesRef.get();
      totalUsuarios = snap.docs.length;
    }

    final rol = totalUsuarios < 3 ? 'admin' : 'usuario';

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await perfilesRef.doc(cred.user!.uid).set({
      'nombre': capitalize(nombre),
      'rut': rut,
      'cargo': capitalize(cargo),
      'email': email,
      'rol': rol,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Login ---
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    if (!_isValidEmail(email)) throw Exception('El correo electrónico no es válido');
    if (!_isValidPassword(password)) {
      throw Exception('La contraseña debe tener mínimo 8 caracteres, 1 mayúscula y 1 número');
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No existe una cuenta con este correo');
      } else if (e.code == 'wrong-password') {
        throw Exception('Contraseña incorrecta');
      } else {
        throw Exception('Error al iniciar sesión: ${e.message}');
      }
    }
  }

  // --- Validaciones internas ---
  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool _isValidRUT(String rut) {
    final cleanRut = rut.replaceAll('.', '').replaceAll('-', '').toUpperCase();
    if (cleanRut.length < 8) return false;

    final body = cleanRut.substring(0, cleanRut.length - 1);
    final dv = cleanRut.substring(cleanRut.length - 1);

    int sum = 0;
    int multiplier = 2;

    for (int i = body.length - 1; i >= 0; i--) {
      sum += int.parse(body[i]) * multiplier;
      multiplier = multiplier == 7 ? 2 : multiplier + 1;
    }

    final expectedDV = 11 - (sum % 11);
    String dvCalc;
    if (expectedDV == 11) {
      dvCalc = '0';
    } else if (expectedDV == 10) {
      dvCalc = 'K';
    } else {
      dvCalc = expectedDV.toString();
    }

    return dvCalc == dv;
  }

  bool _isValidPassword(String password) {
    // Mínimo 8 caracteres, al menos 1 mayúscula y 1 número
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    return regex.hasMatch(password);
  }
}