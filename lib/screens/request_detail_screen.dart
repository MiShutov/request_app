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
  late TextEditingController _phoneController;
  late TextEditingController _categoryController;
  late TextEditingController _streetController;
  late TextEditingController _houseController;
  late TextEditingController _apartmentController;
  late TextEditingController _textController;
  late TextEditingController _commentController;
  late String _status;
  late String _urgency;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.request.phoneNumber);
    _categoryController = TextEditingController(text: widget.request.category);
    _streetController = TextEditingController(text: widget.request.street);
    _houseController = TextEditingController(text: widget.request.house);
    _apartmentController = TextEditingController(text: widget.request.apartment);
    _textController = TextEditingController(text: widget.request.requestText);
    _commentController = TextEditingController(text: widget.request.comment);
    _status = widget.request.status;
    _urgency = widget.request.urgency;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _categoryController.dispose();
    _streetController.dispose();
    _houseController.dispose();
    _apartmentController.dispose();
    _textController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.watch<FirebaseService>();
    final isAdmin = firebaseService.userRole == 'admin';
    final isExecutor = firebaseService.userRole == 'executor';
    final canEdit = !isExecutor;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'Новая заявка' : 'Заявка'),
        actions: [
          if (isAdmin && !widget.isNew)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteRequest(firebaseService),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Дата получения (только просмотр)
            _buildInfoSection(
              'Дата получения',
              RequestModel.formatDateTime(widget.request.dateReceived),
            ),
            if (!widget.isNew && widget.request.dateCompleted != null)
              _buildInfoSection(
                'Дата выполнения',
                RequestModel.formatDateTime(widget.request.dateCompleted),
              ),
            const Divider(),
            
            // Номер телефона
            _buildTextField(
              label: 'Номер телефона заявителя',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              enabled: canEdit,
              hint: '+7 (999) 123-45-67',
            ),
            const SizedBox(height: 16),
            
            // Категория заявки
            _buildTextField(
              label: 'Категория заявки',
              controller: _categoryController,
              enabled: canEdit,
              hint: 'Например: Сантехника, Электрика, Уборка',
            ),
            const SizedBox(height: 16),
            
            // Срочность
            _buildUrgencySelector(enabled: canEdit),
            const SizedBox(height: 16),
            
            // Адрес
            Text('Адрес', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    label: 'Улица',
                    controller: _streetController,
                    enabled: canEdit,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    label: 'Дом',
                    controller: _houseController,
                    enabled: canEdit,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    label: 'Кв.',
                    controller: _apartmentController,
                    enabled: canEdit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Текст заявки
            _buildTextField(
              label: 'Текст заявки',
              controller: _textController,
              maxLines: 3,
              enabled: canEdit || firebaseService.userRole == 'operator',
            ),
            const SizedBox(height: 16),
            
            // Комментарий
            _buildTextField(
              label: 'Комментарий',
              controller: _commentController,
              maxLines: 2,
              enabled: firebaseService.canEditField('comment') || isAdmin,
            ),
            const SizedBox(height: 16),
            
            // Статус
            _buildStatusSelector(enabled: firebaseService.canEditField('status') || isAdmin),
            const SizedBox(height: 30),
            
            // Кнопка сохранения
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _saveRequest(firebaseService),
                icon: const Icon(Icons.save),
                label: const Text('Сохранить'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildUrgencySelector({required bool enabled}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Срочность', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildUrgencyChip('не срочно', Colors.green, enabled),
            const SizedBox(width: 8),
            _buildUrgencyChip('срочно', Colors.orange, enabled),
            const SizedBox(width: 8),
            _buildUrgencyChip('очень срочно', Colors.red, enabled),
          ],
        ),
      ],
    );
  }

  Widget _buildUrgencyChip(String label, Color color, bool enabled) {
    final isSelected = _urgency == label;
    return GestureDetector(
      onTap: enabled
          ? () => setState(() => _urgency = label)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSelector({required bool enabled}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Статус', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _status,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'принята', child: Text('Принята')),
            DropdownMenuItem(value: 'исполнена', child: Text('Исполнена')),
          ],
          onChanged: enabled
              ? (value) => setState(() => _status = value!)
              : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool enabled = true,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      enabled: enabled,
      keyboardType: keyboardType,
    );
  }

  Future<void> _saveRequest(FirebaseService firebaseService) async {
    try {
      // Определяем, меняется ли статус на "исполнена"
      final isCompleting = _status == 'исполнена' && widget.request.status != 'исполнена';
      
      final requestData = {
        'phoneNumber': _phoneController.text,
        'category': _categoryController.text,
        'urgency': _urgency,
        'street': _streetController.text,
        'house': _houseController.text,
        'apartment': _apartmentController.text,
        'requestText': _textController.text,
        'comment': _commentController.text,
        'status': _status,
        // Автоматически проставляем дату выполнения при изменении статуса
        if (isCompleting) 'dateCompleted': DateTime.now().toIso8601String(),
      };

      if (widget.isNew) {
        final newRequest = RequestModel(
          dateReceived: DateTime.now(),
          phoneNumber: _phoneController.text,
          category: _categoryController.text,
          urgency: _urgency,
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
        await firebaseService.updateRequest(widget.request.id!, requestData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заявка сохранена'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
            const SnackBar(
              content: Text('Заявка удалена'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Ошибка: $e')),
          );
        }
      }
    }
  }
}