import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pengaduan.dart';

class ApiService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<void> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register');
    }
  }

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['token'];
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<List<Pengaduan>> getPengaduan(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pengaduan/pengaduan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Pengaduan.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load pengaduan');
    }
  }

  Future<void> createPengaduan(
      String token, String kategoriMasalah, String deskripsi) async {
    final response = await http.post(
      Uri.parse('${baseUrl}/pengaduan/pengaduan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: jsonEncode({
        'kategori_masalah': kategoriMasalah,
        'deskripsi': deskripsi,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create pengaduan: ${response.body}');
    }
  }
  Future<void> deletePengaduan(String token, int id) async {
    final response = await http.delete(
      Uri.parse('${baseUrl}/pengaduan/pengaduan/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete pengaduan');
    }
  }
}

