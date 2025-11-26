import 'package:flutter/material.dart';

//  Task 1

class Calculator {
  int add(int a, int b) => a + b;
}

//  Task 4

abstract class AuthService {
  Future<bool> signIn(String email, String password);
}

class FakeAuthService implements AuthService {
  @override
  Future<bool> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return password == 'password123';
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthService _authService = FakeAuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Testing Task (1–5)',
      theme: ThemeData(useMaterial3: true),
      home: RootMenuScreen(authService: _authService),
    );
  }
}

class RootMenuScreen extends StatelessWidget {
  final AuthService authService;

  const RootMenuScreen({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks 1–5 Menu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CounterScreen()),
                );
              },
              child: const Text('Task 2: Counter Screen'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(authService: authService),
                  ),
                );
              },
              child: const Text('Task 3–5: Login Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

//  Task 2

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Text(
          '$_counter',
          key: const Key('counterText'),
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('incrementButton'),
        onPressed: _increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}

//  Task 3, 4, 5

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  bool _isSubmitting = false;
  String? _submitError;

  bool get _isFormValid => _email.isNotEmpty && _password.isNotEmpty;

  String? _validateEmail(String? value) {
    final email = value ?? '';
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 chars';
    return null;
  }

  void _onEmailChanged(String value) {
    setState(() {
      _email = value;
      _submitError = null;
    });
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _password = value;
      _submitError = null;
    });
  }

  Future<void> _submit() async {
    // Task 5
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      setState(() {
        _submitError = 'Fix form errors';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      // Task 4
      final success = await widget.authService.signIn(_email, _password);

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() {
          _submitError = 'Invalid credentials';
        });
      }
    } catch (e) {
      setState(() {
        _submitError = 'Unexpected error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _isFormValid && !_isSubmitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                key: const Key('emailField'),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                onChanged: _onEmailChanged,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('passwordField'),
                obscureText: true,
                validator: _validatePassword,
                onChanged: _onPasswordChanged,
              ),
              const SizedBox(height: 24),
              if (_submitError != null)
                Text(
                  _submitError!,
                  key: const Key('submitErrorText'),
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                key: const Key('submitButton'),
                onPressed: canSubmit ? _submit : null,
                child: _isSubmitting
                    ? const SizedBox(
                      width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Text(
          'Home Screen',
          key: Key('homeScreenText'),
        ),
      ),
    );
  }
}