import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/request_model.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _userRole = ''; // Текущая роль пользователя
  String _currentUser = '';
  
  String get userRole => _userRole;
  String get currentUser => _currentUser;

  // Вход в систему (упрощенный, без пароля для примера)
  void login(String username, String role) {
    _currentUser = username;
    _userRole = role;
    notifyListeners(); // Уведомляем интерфейс об изменениях
  }

  // Получение списка заявок
  Stream<List<RequestModel>> getRequests() {
    // Stream автоматически обновляет данные при изменениях в базе
    return _firestore
        .collection('requests')
        .orderBy('dateReceived', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return RequestModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Добавление новой заявки
  Future<void> addRequest(RequestModel request) async {
    try {
      await _firestore.collection('requests').add(request.toMap());
    } catch (e) {
      throw Exception('Ошибка при добавлении заявки: $e');
    }
  }

  // Обновление заявки
  Future<void> updateRequest(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('requests').doc(id).update(updates);
    } catch (e) {
      throw Exception('Ошибка при обновлении заявки: $e');
    }
  }

  // Удаление заявки
  Future<void> deleteRequest(String id) async {
    try {
      await _firestore.collection('requests').doc(id).delete();
    } catch (e) {
      throw Exception('Ошибка при удалении заявки: $e');
    }
  }

  // Проверка прав на редактирование поля
  bool canEditField(String field) {
    if (_userRole == 'admin') return true;
    if (_userRole == 'operator') {
      return ['status', 'requestText'].contains(field);
    }
    if (_userRole == 'executor') {
      return ['status', 'comment'].contains(field);
    }
    return false;
  }
}