import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/env.dart';
import '../../../core/widgets/scholera_scaffold.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const routeName = 'login';
  static const routePath = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final env = ref.watch(appEnvProvider);
    final isConfigured = authState.value?.isSupabaseConfigured ?? false;
    final isLoading = authState.isLoading;

    return ScholeraScaffold(
      title: 'Scholera',
      children: [
        Text(
          'Sign in',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Use your university account to open the right Scholera workspace.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        if (!isConfigured) ...[
          _SetupRequiredMessage(env: env),
          const SizedBox(height: 24),
        ],
        if (authState.hasError) ...[
          _AuthErrorMessage(message: authState.error.toString()),
          const SizedBox(height: 16),
        ],
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                enabled: isConfigured && !isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return 'Enter an email address.';
                  }

                  if (!email.contains('@')) {
                    return 'Enter a valid email address.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                enabled: isConfigured && !isLoading,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Password'),
                onFieldSubmitted: (_) => _submit(isConfigured),
                validator: (value) {
                  if ((value ?? '').isEmpty) {
                    return 'Enter a password.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: isConfigured && !isLoading
                    ? () => _submit(isConfigured)
                    : null,
                child: isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submit(bool isConfigured) {
    if (!isConfigured || !_formKey.currentState!.validate()) {
      return;
    }

    ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }
}

class _SetupRequiredMessage extends StatelessWidget {
  const _SetupRequiredMessage({required this.env});

  final AppEnv env;

  @override
  Widget build(BuildContext context) {
    final missing = <String>[
      if (env.supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (env.supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supabase setup needed',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Create the Supabase project, run the schema, then launch with ${missing.join(' and ')}.',
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthErrorMessage extends StatelessWidget {
  const _AuthErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }
}
