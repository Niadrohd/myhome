import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myhome/src/extensions/translations.dart';
import 'package:myhome/src/providers/firebase_providers.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = ref.read(firebaseAuthProvider);
    final email = _emailCtrl.text.trim();
    final password = _pwdCtrl.text;

    try {
      if (_isLogin) {
        await auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        await auth.createUserWithEmailAndPassword(
            email: email, password: password);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(firebaseAuthProvider);
    final str = context.l;

    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? str.login : str.register)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwdCtrl,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Mot de passe'),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: Text(_loading
                    ? '...'
                    : (_isLogin ? str.login : str.register)),
              ),
            ),
            TextButton(
              onPressed: _loading
                  ? null
                  : () => setState(() {
                        _isLogin = !_isLogin;
                        _error = null;
                      }),
              child: Text(_isLogin
                  ? "Je n'ai pas de compte"
                  : "J'ai déjà un compte"),
            ),
            const Spacer(),
            TextButton(
              onPressed: () async => auth.sendPasswordResetEmail(
                  email: _emailCtrl.text.trim()),
              child: const Text('Mot de passe oublié'),
            ),
          ],
        ),
      ),
    );
  }
}
