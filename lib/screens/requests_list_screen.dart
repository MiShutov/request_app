import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/request_model.dart';
import 'request_detail_screen.dart';

class RequestsListScreen extends StatelessWidget {
  const RequestsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.watch<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Заявки (${firebaseService.userRole})'),
        actions: [
          // Кнопка для возврата к выбору роли
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      // Кнопка добавления заявки (только для оператора и админа)
      floatingActionButton: (firebaseService.userRole == 'operator' || 
                            firebaseService.userRole == 'admin')
          ? FloatingActionButton(
              onPressed: () => _createNewRequest(context),
              child: const Icon(Icons.add),
            )
          : null,
      body: StreamBuilder<List<RequestModel>>(
        // Подключаемся к потоку данных из Firebase
        stream: firebaseService.getRequests(),
        builder: (context, snapshot) {
          // Показываем индикатор загрузки
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Обработка ошибок
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final requests = snapshot.data ?? [];

          // Если заявок нет
          if (requests.isEmpty) {
            return const Center(child: Text('Заявок пока нет'));
          }

          // Отображаем список заявок
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestCard(context, request);
            },
          );
        },
      ),
    );
  }

  // Карточка заявки
  Widget _buildRequestCard(BuildContext context, RequestModel request) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(request.requestText),
        subtitle: Text(
          '${request.street}, д.${request.house}, кв.${request.apartment}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: request.status == 'принята' ? Colors.orange : Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            request.status,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        onTap: () {
          // Переход к деталям заявки
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestDetailScreen(request: request),
            ),
          );
        },
      ),
    );
  }

  // Создание новой заявки
  void _createNewRequest(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();
    
    final newRequest = RequestModel(
      dateReceived: DateTime.now(),
      street: '',
      house: '',
      apartment: '',
      requestText: 'Новая заявка',
      createdBy: firebaseService.currentUser,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailScreen(
          request: newRequest,
          isNew: true,
        ),
      ),
    );
  }
}