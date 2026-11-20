import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_swe_demo/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _registeredUser = User(
  id: 't09-registered-user',
  appMetadata: {},
  userMetadata: {},
  aud: 'authenticated',
  createdAt: '2026-01-01T00:00:00Z',
  email: 't09@example.test',
);
const _protectedContentKey = ValueKey('t09-protected-content');
const _incorrectCredentials = 'Invalid login credentials';

class _FakeAuth extends Fake implements GoTrueClient {
  final _authChanges = StreamController<AuthState>();
  final validPassword = 'fixture-for-${_registeredUser.id}';
  final attempts = <({String? email, String password})>[];
  int rejectedAttempts = 0;
  Session? _session;

  @override
  Session? get currentSession => _session;

  @override
  User? get currentUser => _session?.user;

  @override
  Stream<AuthState> get onAuthStateChange => _authChanges.stream;

  @override
  Future<AuthResponse> signInWithPassword({
    String? email,
    String? phone,
    required String password,
    String? captchaToken,
  }) async {
    attempts.add((email: email, password: password));
    if (email != _registeredUser.email || password != validPassword) {
      rejectedAttempts++;
      throw const AuthException(_incorrectCredentials);
    }

    final session = Session(
      accessToken: 'widget-test-token',
      tokenType: 'bearer',
      user: _registeredUser,
    );
    _session = session;
    _authChanges.add(AuthState(AuthChangeEvent.signedIn, session));
    return AuthResponse(session: session);
  }

  Future<void> close() => _authChanges.close();
}

final _submitButton = find.widgetWithText(ElevatedButton, 'Sign In');
final _protectedContent = find.byKey(_protectedContentKey);

Future<void> _openSignIn(WidgetTester tester, _FakeAuth auth) async {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await auth.close();
  });
  await tester.pumpWidget(
    MaterialApp(
      home: AuthGate(
        auth: auth,
        signedInBuilder: (_, user) =>
            Scaffold(body: Text(user.id, key: _protectedContentKey)),
      ),
    ),
  );
}

Future<void> _submitCredentials(WidgetTester tester, String password) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), _registeredUser.email!);
  await tester.enterText(fields.at(1), password);
  await tester.tap(_submitButton);
  await tester.pumpAndSettle();
}

void main() {
  // T09 traces to FR-08 and UC-05; the retry path comes from UC-05 A2.
  testWidgets('T09-valid grants protected access for the registered user', (
    tester,
  ) async {
    final auth = _FakeAuth();
    await _openSignIn(tester, auth);
    expect(auth.currentSession, isNull);
    expect(_protectedContent, findsNothing);

    await _submitCredentials(tester, auth.validPassword);

    expect(auth.attempts, [
      (email: _registeredUser.email, password: auth.validPassword),
    ]);
    expect(auth.currentSession?.user.id, _registeredUser.id);
    expect(_protectedContent, findsOneWidget);
    expect(tester.widget<Text>(_protectedContent).data, _registeredUser.id);
    expect(_submitButton, findsNothing);
  });

  testWidgets('T09-invalid denies access, shows feedback, and allows retry', (
    tester,
  ) async {
    final auth = _FakeAuth();
    await _openSignIn(tester, auth);
    final wrongPassword = '${auth.validPassword}-incorrect';

    await _submitCredentials(tester, wrongPassword);

    expect(auth.attempts, [
      (email: _registeredUser.email, password: wrongPassword),
    ]);
    expect(auth.rejectedAttempts, 1);
    expect(auth.currentSession, isNull);
    expect(auth.currentUser, isNull);
    expect(_protectedContent, findsNothing);
    expect(find.text(_incorrectCredentials), findsOneWidget);
    expect(_submitButton, findsOneWidget);
    expect(tester.widget<ElevatedButton>(_submitButton).onPressed, isNotNull);

    await _submitCredentials(tester, auth.validPassword);

    expect(auth.attempts, [
      (email: _registeredUser.email, password: wrongPassword),
      (email: _registeredUser.email, password: auth.validPassword),
    ]);
    expect(auth.rejectedAttempts, 1);
    expect(auth.currentSession?.user.id, _registeredUser.id);
    expect(tester.widget<Text>(_protectedContent).data, _registeredUser.id);
  });
}
