/// Widget test for the Notes application.
///
/// This is a placeholder test that verifies the app can start.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kemir_project/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: NotesApp()));

    // Verify that the app starts without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
