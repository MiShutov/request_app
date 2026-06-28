import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/request_model.dart';

class RequestDetailScreen extends StatefulWidget {
  final RequestModel request;
  final bool isNew;

  const RequestDetailScreen({
    super.key,
    required this.request,
    this.isNew = false,
  });

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late TextEditingController _streetController;
  late TextEditingController _houseController;
  late TextEditingController _apartmentController;
  late TextEditingController _textController;
  late TextEditingController _commentController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController(text: widget.request.street);
    _houseController = TextEditingController(text: widget.request.house);
    _apartmentController = TextEditingController(text: widget.request.apartment);
    _textController = TextEditingController(text: widget.request.requestText);
    _commentController = TextEditingController(text: widget.request.comment);
    _status = widget.request.status;
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.watch<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'Новая заявка' : 'Заявка'),
        actions: [
          // Кнопка удаления (только для админа)
          if (firebaseService.userRole == 'admin' && !widget.isNew)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteRequest(firebaseService),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Поле "Улица"
            _buildTextField(
              label: 'Улица',
              controller: _streetController,
              enabled: firebaseService.userRole != 'executor',
            ),
            const SizedBox(height: 10),
            
            // Поле "Дом"
            _buildTextField(
              label: 'Дом',
              controller: _houseController,
              enabled: firebaseService.userRole != 'executor',
            ),
            const SizedBox(height: 10),
            
            // Поле "Квартира"
            _buildTextField(
              label: 'Квартира',
              controller: _apartmentController,
              enabled: firebaseService.userRole != 'executor',
            ),
            const SizedBox(height: 10),
            
            // Поле "Текст заявки"
            _buildTextField(
              label: 'Текст заявки',
              controller: _textController,
              maxLines: 3,
              enabled: firebaseService.canEditField('requestText'),
            ),
            const SizedBox(height: 10),
            
            // Поле "Комментарий"
            _buildTextField(
              label: 'Комментарий',
              controller: _commentController,
              maxLines: 2,
              enabled: firebaseService.canEditField('comment'),
            ),
            const SizedBox(height: 20),
            
            // Выбор статуса
            Row(
              children: [
                const Text('Статус: ', style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  value: _status,
                  onChanged: firebaseService.canEditField('status')
                      ? (value) => setState(() => _status = value!)
                      : null,
                  items: const [
                    DropdownMenuItem(value: 'принята', child: Text('Принята')),
                    DropdownMenuItem(value: 'исполнена', child: Text('Исполнена')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Кнопка сохранения
            ElevatedButton(
              onPressed: () => _saveRequest(firebaseService),
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  // Вспомогательный метод для создания полей ввода
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      enabled: enabled,
    );
  }

  // Сохранение заявки
  Future<void> _saveRequest(FirebaseService firebaseService) async {
    try {
      final requestData = {
        'street': _streetController.text,
        'house': _houseController.text,
        'apartment': _apartmentController.text,
        'requestText': _textController.text,
        'comment': _commentController.text,
        'status': _status,
      };

      if (widget.isNew) {
        // Создаем новую заявку
        final newRequest = RequestModel(
          dateReceived: DateTime.now(),
          street: _streetController.text,
          house: _houseController.text,
          apartment: _apartmentController.text,
          requestText: _textController.text,
          comment: _commentController.text,
          status: _status,
          createdBy: firebaseService.currentUser,
        );
        await firebaseService.addRequest(newRequest);
      } else {
        // Обновляем существующую
        await firebaseService.updateRequest(widget.request.id!, requestData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заявка сохранена')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  // Удаление заявки
  Future<void> _deleteRequest(FirebaseService firebaseService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить заявку?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await firebaseService.deleteRequest(widget.request.id!);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Заявка удалена')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: $e')),
          );
        }
      }
    }
  }
}