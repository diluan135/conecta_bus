import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

// pages
import 'package:horarios_transporte/pages/home_page.dart';
import 'package:horarios_transporte/pages/linha_page.dart';
import 'package:horarios_transporte/pages/mapa_page.dart';
import 'package:horarios_transporte/pages/news_page.dart';
import 'package:horarios_transporte/pages/horario_page.dart';
import 'package:horarios_transporte/pages/ajuda_page.dart';
import 'package:horarios_transporte/pages/pagina_escuta.dart';
import 'package:horarios_transporte/pages/login_page.dart';
import 'package:horarios_transporte/pages/registro_page.dart';
import 'package:horarios_transporte/pages/sobdemanda_page.dart';
import 'package:horarios_transporte/pages/enquetes_page.dart'; // Importe o arquivo da página
import 'package:horarios_transporte/services/auth_service.dart';
import 'package:horarios_transporte/widgets/auth_guard.dart';
import 'package:geolocator/geolocator.dart';

// Caso esteja procurando, o card informando atualizações está no main_cards.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("favBoxApp");
  await Hive.openBox("rotasLocal");

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await _requestNotificationPermission();

  runApp(const MyApp());
}

Future<void> _requestNotificationPermission() async {
  PermissionStatus permissionStatus = await Permission.notification.status;
  if (permissionStatus.isDenied) {
    await Permission.notification.request();
  }
}

Future<void> _getUserLocation() async {
  // Verifica se as permissões estão concedidas
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    // Solicita permissão
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Se a permissão for negada, informe o usuário
      print('Permissão de localização negada.');
      return;
    }
  }

  // Agora que temos permissão, obtemos a localização
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  print('Localização: ${position.latitude}, ${position.longitude}');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/horarios': (context) => const PageHorarios(),
        '/linha': (context) => const LinhaPage(),
        '/news': (context) => const NewsPage(),
        '/map': (context) => const MapaPage(),
        '/ajuda': (context) => const AjudaPage(),
        '/paginaEscuta': (context) =>
            AuthGuard(child: const PaginaEscuta(), redirectRoute: '/login'),
        // Rotas de login e registro
        '/login': (context) => const LoginPage(nextRoute: '/paginaEscuta'),
        '/register': (context) => const RegisterPage(),
        // Rota de enquete
        '/enquetes': (context) => EnquetesPage(),
        '/sobdemanda': (context) => const SobDemanda(),
      },
    );
  }
}
