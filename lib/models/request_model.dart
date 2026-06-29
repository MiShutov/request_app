import 'package:flutter/material.dart';


class RequestModel {
  String? id;
  DateTime dateReceived;      // Дата и время получения
  String street;
  String house;
  String apartment;
  String phoneNumber;         // Номер телефона заявителя
  String category;            // Категория заявки
  String urgency;             // Срочность: "не срочно", "срочно", "очень срочно"
  String requestText;
  String comment;
  String status;
  DateTime? dateCompleted;    // Дата и время выполнения (null пока не выполнена)
  String createdBy;

  RequestModel({
    this.id,
    required this.dateReceived,
    required this.street,
    required this.house,
    required this.apartment,
    this.phoneNumber = '',
    this.category = '',
    this.urgency = 'не срочно',
    required this.requestText,
    this.comment = '',
    this.status = 'принята',
    this.dateCompleted,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'dateReceived': dateReceived.toIso8601String(),
      'street': street,
      'house': house,
      'apartment': apartment,
      'phoneNumber': phoneNumber,
      'category': category,
      'urgency': urgency,
      'requestText': requestText,
      'comment': comment,
      'status': status,
      'dateCompleted': dateCompleted?.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map, String id) {
    return RequestModel(
      id: id,
      dateReceived: DateTime.parse(map['dateReceived'] ?? DateTime.now().toIso8601String()),
      street: map['street'] ?? '',
      house: map['house'] ?? '',
      apartment: map['apartment'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      category: map['category'] ?? '',
      urgency: map['urgency'] ?? 'не срочно',
      requestText: map['requestText'] ?? '',
      comment: map['comment'] ?? '',
      status: map['status'] ?? 'принята',
      dateCompleted: map['dateCompleted'] != null 
          ? DateTime.tryParse(map['dateCompleted']) 
          : null,
      createdBy: map['createdBy'] ?? '',
    );
  }
  
  // Вспомогательный метод для получения цвета срочности
  static Color getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'очень срочно':
        return Colors.red;
      case 'срочно':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
  
  // Вспомогательный метод для форматирования даты
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '—';
    return '${dateTime.day.toString().padLeft(2, '0')}.'
        '${dateTime.month.toString().padLeft(2, '0')}.'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}