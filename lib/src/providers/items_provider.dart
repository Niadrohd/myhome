import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myhome/src/models/item.dart';
import 'package:myhome/src/repositories/items_repository.dart';
import 'firebase_providers.dart';
import 'household_providers.dart';

final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  return ItemsRepository(ref.watch(firestoreProvider));
});

final itemsProvider = StreamProvider<List<Item>>((ref) {
  final hidAsync = ref.watch(currentHouseholdIdProvider);
  final repo = ref.watch(itemsRepositoryProvider);

  return hidAsync.when(
    data: (hid) =>
        hid == null ? const Stream.empty() : repo.watchItems(hid),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});
