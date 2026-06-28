import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import 'requests_list_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход в систему')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Выберите роль:',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 30),
            // Кнопка для входа как оператор
            ElevatedButton(
              onPressed: () => _login(context, 'Оператор', 'operator'),
              child: const Text('Оператор (создание заявок)'),
            ),
            const SizedBox(height: 20),
            // Кнопка для входа как исполнитель
            ElevatedButton(
              onPressed: () => _login(context, 'Исполнитель', 'executor'),
              child: const Text('Исполнитель (изменение статуса)'),
            ),
            const SizedBox(height: 20),
            // Кнопка для входа как администратор
            ElevatedButton(
              onPressed: () => _login(context, 'Администратор', 'admin'),
              child: const Text('Администратор (полный доступ)'),
            ),
          ],
        ),
      ),
    );
  }

  void _login(BuildContext context, String userName, String role) {
    final firebaseService = context.read<FirebaseService>();
    firebaseService.login(userName, role);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RequestsListScreen()),
    );
  }
}