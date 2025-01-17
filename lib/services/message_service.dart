// lib/services/message_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>> fetchMessages(int chatId) async {
  final response =
      await http.get(Uri.parse('http://seuservidor.com/mensagens/$chatId'));

  if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);
    return body.map((dynamic item) => item as Map<String, dynamic>).toList();
  } else {
    throw Exception('Failed to load messages');
  }
}
