import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';

import 'features/welcome/welcome_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/planificacion/screens/crear_planificacion_screen.dart';
import 'features/planificacion/screens/historial_planificacion_screen.dart';
import 'features/planificacion/screens/duplicar_planificacion_screen.dart';
import 'features/reporte/screens/crear_reporte_screen.dart';
import 'features/reporte/screens/historial_reporte.screen.dart';
import 'features/users/screens/ver_usuarios_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es_CL', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestión de Riesgos',
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/planificacion': (context) => const CrearPlanificacionScreen(),
        '/historial_planificaciones': (context) => const HistorialPlanificacionesScreen(),
        '/duplicar_planificacion': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DuplicarPlanificacionScreen(
            data: args['data'],
            origenId: args['origenId'],
            planificacion: {},
          );
        },
        '/reporte': (context) => const CrearReporteScreen(),
        '/historial_reportes': (context) => const HistorialReportesScreen(),
        '/ver_usuarios': (context) => const VerUsuariosScreen(),
      },
    );
  }
}