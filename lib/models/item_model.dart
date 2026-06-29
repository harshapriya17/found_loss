class ItemModel {
  final String id;
  final String type; // 'lost' or 'found'
  final String name;
  final String category;
  final String description;
  final DateTime date;
  final String location;
  final String contactNumber;
  final String? imagePath;
  final String status; // 'Lost'/'Matched'/'Returned' for lost, 'Found'/'Claimed'/'Returned' for found

  ItemModel({
    required this.id,
    required this.type,
    required this.name,
    required this.category,
    required this.description,
    required this.date,
    required this.location,
    required this.contactNumber,
    this.imagePath,
    required this.status,
  });

  ItemModel copyWith({
    String? id,
    String? type,
    String? name,
    String? category,
    String? description,
    DateTime? date,
    String? location,
    String? contactNumber,
    String? imagePath,
    String? status,
  }) {
    return ItemModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      contactNumber: contactNumber ?? this.contactNumber,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'contactNumber': contactNumber,
      'imagePath': imagePath,
      'status': status,
    };
  }

  factory ItemModel.fromMap(Map<dynamic, dynamic> map) {
    return ItemModel(
      id: map['id'] as String,
      type: map['type'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      location: map['location'] as String,
      contactNumber: map['contactNumber'] as String,
      imagePath: map['imagePath'] as String?,
      status: map['status'] as String,
    );
  }
}
