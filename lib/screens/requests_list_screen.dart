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
    final urgencyColor = RequestModel.getUrgencyColor(request.urgency);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ExpansionTile(
        leading: Container(
          width: 8,
          height: 80,
          decoration: BoxDecoration(
            color: urgencyColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          request.requestText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${request.street}, д.${request.house}, кв.${request.apartment}',
              style: const TextStyle(fontSize: 13),
            ),
            if (request.phoneNumber.isNotEmpty)
              Text(
                request.phoneNumber,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            if (request.category.isNotEmpty)
              Text(
                request.category,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: request.status == 'принята' ? Colors.orange : Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                request.status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Получено', RequestModel.formatDateTime(request.dateReceived)),
                if (request.dateCompleted != null)
                  _buildInfoRow('Выполнено', RequestModel.formatDateTime(request.dateCompleted)),
                _buildInfoRow('Срочность', request.urgency),
                if (request.comment.isNotEmpty)
                  _buildInfoRow('Комментарий', request.comment),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestDetailScreen(request: request),
                        ),
                      );
                    },
                    child: const Text('Подробнее'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
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