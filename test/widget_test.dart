import 'package:flutter_test/flutter_test.dart';
import 'package:found_loss_app/models/item_model.dart';

void main() {
  group('ItemModel Tests', () {
    test('toMap and fromMap serialization', () {
      final date = DateTime(2026, 6, 27);
      final item = ItemModel(
        id: '123',
        type: 'lost',
        name: 'iPhone 15',
        category: 'Electronics',
        description: 'Black color, cracked screen',
        date: date,
        location: 'Library Second Floor',
        contactNumber: '1234567890',
        imagePath: 'path/to/image.jpg',
        status: 'Lost',
      );

      final map = item.toMap();
      expect(map['id'], '123');
      expect(map['type'], 'lost');
      expect(map['name'], 'iPhone 15');
      expect(map['category'], 'Electronics');
      expect(map['description'], 'Black color, cracked screen');
      expect(map['date'], date.toIso8601String());
      expect(map['location'], 'Library Second Floor');
      expect(map['contactNumber'], '1234567890');
      expect(map['imagePath'], 'path/to/image.jpg');
      expect(map['status'], 'Lost');

      final fromMap = ItemModel.fromMap(map);
      expect(fromMap.id, '123');
      expect(fromMap.type, 'lost');
      expect(fromMap.name, 'iPhone 15');
      expect(fromMap.category, 'Electronics');
      expect(fromMap.description, 'Black color, cracked screen');
      expect(fromMap.date, date);
      expect(fromMap.location, 'Library Second Floor');
      expect(fromMap.contactNumber, '1234567890');
      expect(fromMap.imagePath, 'path/to/image.jpg');
      expect(fromMap.status, 'Lost');
    });

    test('copyWith copies properties correctly', () {
      final item = ItemModel(
        id: '123',
        type: 'lost',
        name: 'iPhone 15',
        category: 'Electronics',
        description: 'Black color',
        date: DateTime.now(),
        location: 'Library',
        contactNumber: '1234567890',
        status: 'Lost',
      );

      final updated = item.copyWith(status: 'Matched');
      expect(updated.id, '123');
      expect(updated.status, 'Matched');
      expect(updated.name, 'iPhone 15');
    });
  });
}
