import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthService {
  static const String _secretKey = 'your_secret_key';

  // Método para gerar um token JWT
  static String generateToken(String cpf) {
    final expirationTime =
        DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch;

    final jwt = JWT(
      {
        'cpf': cpf,
        'iat': DateTime.now().millisecondsSinceEpoch,
        'exp': expirationTime, // Expiração manual
      },
    );

    return jwt.sign(SecretKey(_secretKey));
  }

  // Método para verificar um token JWT
  static bool verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      final expiration = jwt.payload['exp'] as int;

      if (DateTime.now().millisecondsSinceEpoch < expiration) {
        return true; // Token válido
      } else {
        return false; // Token expirado
      }
    } catch (e) {
      print('Token inválido: $e');
      return false;
    }
  }

  // Método para verificar se o usuário está autenticado
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      return false; // Nenhum token armazenado
    }

    return verifyToken(token);
  }
}
