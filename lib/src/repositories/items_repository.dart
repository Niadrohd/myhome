import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myhome/src/models/item.dart';

class ItemsRepository {
  ItemsRepository(this._fs);
  final FirebaseFirestore _fs;

  CollectionReference<Map<String, dynamic>> _itemsRef(String householdId) =>
      _fs.collection('households').doc(householdId).collection('items');

  Stream<List<Item>> watchItems(String householdId) {
    return _itemsRef(householdId)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => _fromDoc(d)).toList());
  }

  Future<void> addItem(
    String householdId, {
    required String name,
    int quantity = 0,
    String details = '',
    String unit = 'pcs',
  }) {
    debugPrint('Adding item: $name, $quantity, $details, $unit');
    return _itemsRef(householdId).add({
      'name': name.trim(),
      'quantity': quantity,
      'details': details.trim(),
      'unit': unit.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> changeQuantity(
    String householdId,
    String itemId,
    int delta,
  ) async {
    final ref = _itemsRef(householdId).doc(itemId);
    await _fs.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data()!;
      final current = (data['quantity'] as num?)?.toInt() ?? 0;
      final next = (current + delta).clamp(0, 999999);
      tx.update(ref, {
        'quantity': next,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> deleteItem(String householdId, String itemId) {
    return _itemsRef(householdId).doc(itemId).delete();
  }

  Item _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data()!;
    return Item(
      id: d.id,
      name: (data['name'] as String?) ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unit: (data['unit'] as String?) ?? 'pcs',
      details: (data['details'] as String?) ?? '',
    );
  }
}
