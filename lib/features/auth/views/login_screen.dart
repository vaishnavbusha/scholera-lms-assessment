import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/env.dart';
import '../../../app/theme/palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
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
  bool _obscure = true;

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
    // Whether Supabase is configured is derived from the env (static at app
    // launch), not from the async auth state. Pulling it from env keeps the
    // login form stable across loading transitions.
    final isConfigured = env.hasSupabaseConfig;
    final isLoading = authState.isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xl,
                vertical: Spacing.xxl,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - Spacing.xxl * 2,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Brandmark(),
                      const SizedBox(height: Spacing.xxxl),
                      Text(
                        'Welcome back',
                        style: theme.textTheme.displayMedium,
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        'Sign in to open the Scholera workspace for your role.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: Spacing.xl),
                      if (!isConfigured) ...[
                        _SetupRequiredNotice(env: env),
                        const SizedBox(height: Spacing.lg),
                      ],
                      if (authState.hasError) ...[
                        _AuthErrorNotice(
                          message: friendlyErrorMessage(authState.error!),
                        ),
                        const SizedBox(height: Spacing.md),
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
                              autocorrect: false,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'you@university.edu',
                              ),
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: Spacing.md),
                            TextFormField(
                              controller: _passwordController,
                              enabled: isConfigured && !isLoading,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              onFieldSubmitted: (_) => _submit(isConfigured),
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: Spacing.xl),
                            FilledButton(
                              onPressed: isConfigured && !isLoading
                                  ? () => _submit(isConfigured)
                                  : null,
                              child: isLoading
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Palette.surface,
                                      ),
                                    )
                                  : const Text('Sign in'),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                      const SizedBox(height: Spacing.xl),
                      _FooterMark(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter an email address.';
    if (!email.contains('@')) return 'Enter a valid email address.';
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Enter a password.';
    return null;
  }

  void _submit(bool isConfigured) {
    if (!isConfigured || !(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }
}

class _Brandmark extends StatelessWidget {
  const _Brandmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Palette.ink,
            borderRadius: Radii.card,
          ),
          alignment: Alignment.center,
          child: Text(
            'S',
            style: GoogleFonts.plusJakartaSans(
              color: Palette.paper,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: Spacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scholera',
              style: GoogleFonts.plusJakartaSans(
                color: Palette.ink,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Learning management, native.',
              style: GoogleFonts.plusJakartaSans(
                color: Palette.inkMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FooterMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Built for Scholera · Mobile companion',
        style: GoogleFonts.plusJakartaSans(
          color: Palette.inkSubtle,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SetupRequiredNotice extends StatelessWidget {
  const _SetupRequiredNotice({required this.env});

  final AppEnv env;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final missing = <String>[
      if (env.supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (env.supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
    ];

    return _Notice(
      background: theme.colorScheme.primaryContainer,
      border: theme.colorScheme.primary.withValues(alpha: 0.25),
      title: 'Supabase setup needed',
      titleColor: theme.colorScheme.onPrimaryContainer,
      message:
          'Launch with ${missing.join(' and ')} set via --dart-define-from-file=.env.',
      messageColor: theme.colorScheme.onPrimaryContainer,
    );
  }
}

class _AuthErrorNotice extends StatelessWidget {
  const _AuthErrorNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _Notice(
      background: Palette.errorContainer,
      border: Palette.error.withValues(alpha: 0.3),
      title: 'Couldn\u2019t sign you in',
      titleColor: Palette.error,
      message: message,
      messageColor: Palette.error,
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.background,
    required this.border,
    required this.title,
    required this.titleColor,
    required this.message,
    required this.messageColor,
  });

  final Color background;
  final Color border;
  final String title;
  final Color titleColor;
  final String message;
  final Color messageColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: Radii.card,
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(color: titleColor),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: messageColor),
            ),
          ],
        ),
      ),
    );
  }
}
