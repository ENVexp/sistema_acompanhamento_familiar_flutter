// lib/platforms/shared/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static String? EMAIL_RECUPERADO;

  // Salva o email do usuário
  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuarioEmail', email);
    EMAIL_RECUPERADO = email;
  }

  // Retorna o email salvo do usuário
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    EMAIL_RECUPERADO = prefs.getString('usuarioEmail');
    return EMAIL_RECUPERADO;
  }

  // Remove o email do usuário
  Future<void> removeUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuarioEmail');
    EMAIL_RECUPERADO = null;
  }

  // Verifica se o email do usuário está salvo
  Future<bool> hasUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('usuarioEmail');
  }
}
