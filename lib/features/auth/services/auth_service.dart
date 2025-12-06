import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  bool isValidEmail(String email) => _isValidEmail(email);
  bool isValidRut(String rut) => _isValidRut(rut);
  bool isValidPassword(String password) => _isValidPassword(password);
  bool startsWithCapital(String text) =>
      text.isNotEmpty && text[0] == text[0].toUpperCase();

  String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String formatRut(String rut) {
    final clean = rut.replaceAll('.', '').replaceAll('-', '').toUpperCase();
    final body = clean.substring(0, clean.length - 1);
    final dv = clean.substring(clean.length - 1);
    final buffer = StringBuffer();
    int counter = 0;
    for (int i = body.length - 1; i >= 0; i--) {
      buffer.write(body[i]);
      counter++;
      if (counter == 3 && i != 0) {
        buffer.write('.');
        counter = 0;
      }
    }
    final reversed = buffer.toString().split('').reversed.join('');
    return '$reversed-$dv';
  }

  Future<void> registerUser({
    required String nombre,
    required String rutFormateado,
    required String cargo,
    required String email,
    required String password,
  }) async {
    if (!_isValidEmail(email)) {
      throw Exception('El correo electrónico no es válido');
    }
    if (!_isValidRut(rutFormateado)) {
      throw Exception('El RUT ingresado no es válido');
    }
    if (!_isValidPassword(password)) {
      throw Exception('La contraseña debe tener al menos 8 caracteres, incluyendo letras y números');
    }
    if (!startsWithCapital(nombre)) {
      throw Exception('El nombre debe comenzar con mayúscula');
    }
    if (!startsWithCapital(cargo)) {
      throw Exception('El cargo debe comenzar con mayúscula');
    }

    final perfilesRef = db.collection('perfiles');

    final existingEmail = await perfilesRef.where('email', isEqualTo: email).limit(1).get();
    if (existingEmail.docs.isNotEmpty) {
      throw Exception('Ya existe un usuario con este correo');
    }

    final existingRut = await perfilesRef.where('rutFormateado', isEqualTo: formatRut(rutFormateado)).limit(1).get();
    if (existingRut.docs.isNotEmpty) {
      throw Exception('Ya existe un usuario con este RUT');
    }

    int totalUsuarios;
    try {
      final countSnap = await perfilesRef.count().get();
      totalUsuarios = countSnap.count ?? 0;
    } catch (_) {
      final snap = await perfilesRef.get();
      totalUsuarios = snap.docs.length;
    }

    final rol = totalUsuarios < 2 ? 'admin' : 'usuario';

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await perfilesRef.doc(cred.user!.uid).set({
      'nombre': capitalizeWords(nombre),
      'cargo': capitalizeWords(cargo),
      'rutFormateado': formatRut(rutFormateado),
      'email': email,
      'rol': rol,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> loginUserFlexible({
    required String userInput,
    required String password,
  }) async {
    String emailFinal;
    if (_isValidEmail(userInput)) {
      emailFinal = userInput;
    } else if (_isValidRut(userInput)) {
      final snapshot = await db
          .collection('perfiles')
          .where('rutFormateado', isEqualTo: formatRut(userInput))
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        throw Exception('No existe un usuario con ese RUT');
      }
      emailFinal = snapshot.docs.first['email'];
    } else {
      throw Exception('Debes ingresar un correo válido o un RUT válido');
    }
    return loginUser(email: emailFinal, password: password);
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    if (!_isValidEmail(email)) {
      throw Exception('El correo electrónico no es válido');
    }
    if (!_isValidPassword(password)) {
      throw Exception('La contraseña debe tener al menos 8 caracteres, incluyendo letras y números');
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

  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    if (!_isValidEmail(email)) {
      throw Exception('El correo electrónico no es válido');
    }
    await _auth.sendPasswordResetEmail(email: email);
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool _isValidRut(String rut) {
    final cleanRut = rut.replaceAll('.', '').replaceAll('-', '').toUpperCase();
    if (cleanRut.length < 2) return false;
    final body = cleanRut.substring(0, cleanRut.length - 1);
    final dv = cleanRut.substring(cleanRut.length - 1);
    if (!RegExp(r'^\d+$').hasMatch(body)) return false;
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
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$');
    return regex.hasMatch(password);
  }
}