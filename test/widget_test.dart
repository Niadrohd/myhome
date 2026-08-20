import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myhome/app.dart';
import 'package:myhome/src/pages/auth_page.dart';
import 'package:myhome/src/providers/firebase_providers.dart';
import 'package:myhome/src/providers/household_providers.dart';

Widget wrapApp(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: EasyDynamicThemeWidget(
      initialThemeMode: ThemeMode.light,
      child: const MyHomeApp(),
    ),
  );
}

void main() {
  testWidgets('Signed-out user sees the auth page', (tester) async {
    await tester.pumpWidget(wrapApp([
      authStateProvider.overrideWith((ref) => Stream.value(null)),
      firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
    ]));
    await tester.pumpAndSettle();

    expect(find.byType(AuthPage), findsOneWidget);
  });

  testWidgets('Signed-in user lands on their todo lists', (tester) async {
    final mockUser = MockUser(uid: 'test-uid');

    await tester.pumpWidget(wrapApp([
      authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
      firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
      currentHouseholdIdProvider.overrideWith(
        (ref) => Stream.value('household-1'),
      ),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Todo Lists'), findsOneWidget);
    expect(
      find.text('No todo lists yet. Create one to get started!'),
      findsOneWidget,
    );
  });
}
