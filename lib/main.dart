import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Login App',
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String get baseUrl {
    if (kIsWeb) {
      return 'http://192.168.1.14:3000';
    } else {
      return 'http://10.0.2.2:3000';
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        Map<String, String> data = {
          "email": _usernameController.text,
          "password": _passwordController.text,
        };

        print('Attempting login with:');
        print('Email: ${_usernameController.text}');
        print('Password: ${_passwordController.text}');
        print('Full request data: ${json.encode(data)}');
        print('Request URL: ${baseUrl}/api/auth/login');

        final response = await http.post(
          Uri.parse('$baseUrl/api/auth/login'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(data),
        );

        print('Response status code: ${response.statusCode}');
        print('Response headers: ${response.headers}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);
          String message = responseData['message'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          
          if (responseData['token'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', responseData['token']);
          }
        } else {
          Map<String, dynamic> errorData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login Gagal: ${errorData['message'] ?? response.body}")),
          );
        }
      } catch (e) {
        print('Error during login: $e'); // Debug print
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Login",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email tidak boleh kosong";
                  }
                  if (!value.contains('@')) {
                    return "Format email tidak valid";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password tidak boleh kosong";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
