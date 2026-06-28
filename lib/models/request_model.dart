class RequestModel {
  String? id; // ID будет автоматически от Firebase
  DateTime dateReceived;
  String street;
  String house;
  String apartment;
  String requestText;
  String comment;
  String status; // 'принята' или 'исполнена'
  String createdBy;

  RequestModel({
    this.id,
    required this.dateReceived,
    required this.street,
    required this.house,
    required this.apartment,
    required this.requestText,
    this.comment = '',
    this.status = 'принята',
    required this.createdBy,
  });

  // Преобразование в Map для отправки в Firebase
  Map<String, dynamic> toMap() {
    return {
      'dateReceived': dateReceived.toIso8601String(),
      'street': street,
      'house': house,
      'apartment': apartment,
      'requestText': requestText,
      'comment': comment,
      'status': status,
      'createdBy': createdBy,
    };
  }

  // Создание объекта из Map (получение из Firebase)
  factory RequestModel.fromMap(Map<String, dynamic> map, String id) {
    return RequestModel(
      id: id,
      dateReceived: DateTime.parse(map['dateReceived']),
      street: map['street'] ?? '',
      house: map['house'] ?? '',
      apartment: map['apartment'] ?? '',
      requestText: map['requestText'] ?? '',
      comment: map['comment'] ?? '',
      status: map['status'] ?? 'принята',
      createdBy: map['createdBy'] ?? '',
    );
  }
}