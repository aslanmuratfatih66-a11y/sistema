// Аккаунт: сервер, регистрация/вход, TOTP по QR, сброс пароля, состояние синхронизации (SPEC §10).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/sync/http_auth_service.dart';
import '../../core/sync/sync_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'sync_indicator.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  String _server = '';
  String _name = '';
  String _password = '';
  String _totp = '';
  String _newPassword = '';
  bool _resetMode = false;
  bool _needTotp = false;
  bool _busy = false;
  String? _error;
  String? _info;
  TotpSetup? _setup;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authServiceProvider);
    _server = auth is HttpAuthService ? auth.lastServerUrl : defaultServerUrl;
  }

  String _errorText(AppLocalizations l, Object e) {
    if (e is InvalidNameException) return l.synErrInvalidName;
    if (e is AuthException) {
      return switch (e.error) {
        AuthError.network => l.synErrNetwork,
        AuthError.invalidCredentials => l.synErrCredentials,
        AuthError.totpRequired => l.synTotpNeeded,
        AuthError.invalidTotp => l.synErrTotp,
        AuthError.nameTaken => l.synErrNameTaken,
        AuthError.weakPassword => l.synErrWeakPassword,
        AuthError.rateLimited => e.retryAfter == null
            ? l.synErrRateLimited
            : '${l.synErrRateLimited} (${e.retryAfter!.inSeconds} s)',
        AuthError.server => l.synErrServer,
      };
    }
    return l.synErrServer;
  }

  Future<void> _run(Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await action();
    } on AuthException catch (e) {
      if (e.error == AuthError.totpRequired) _needTotp = true;
      _error = _errorText(l, e);
    } catch (e) {
      _error = _errorText(l, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _filled(AppLocalizations l) {
    if (_server.trim().isEmpty || _name.trim().isEmpty || _password.isEmpty) {
      setState(() => _error = l.synErrFill);
      return false;
    }
    return true;
  }

  void _login(AppLocalizations l) {
    if (!_filled(l)) return;
    _run(() async {
      await ref.read(authServiceProvider).login(
            serverUrl: _server,
            name: _name,
            password: _password,
            totp: _needTotp ? _totp : null,
          );
      _password = _totp = '';
      _needTotp = false;
    });
  }

  void _register(AppLocalizations l) {
    if (!_filled(l)) return;
    _run(() async {
      await ref.read(authServiceProvider).register(serverUrl: _server, name: _name, password: _password);
      _password = '';
    });
  }

  void _reset(AppLocalizations l) {
    if (_server.trim().isEmpty || _name.trim().isEmpty || _totp.trim().isEmpty || _newPassword.isEmpty) {
      setState(() => _error = l.synErrFill);
      return;
    }
    _run(() async {
      await ref
          .read(authServiceProvider)
          .resetPassword(serverUrl: _server, name: _name, totp: _totp, newPassword: _newPassword);
      _resetMode = false;
      _totp = _newPassword = '';
      _info = l.synResetDone;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final account = ref.watch(accountProvider).value;
    return Scaffold(
      backgroundColor: SysColors.background,
      body: SystemBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  const SysBackButton(),
                  Expanded(child: Text(l.synTitle.toUpperCase(), style: SysText.heading)),
                  const SyncIndicator(),
                ],
              ),
              const SizedBox(height: 8),
              if (_error != null) _Message(text: _error!, color: SysColors.dangerLight),
              if (_info != null) _Message(text: _info!, color: SysColors.success),
              if (account == null)
                (_resetMode ? _resetPanel(l) : _loginPanel(l))
              else ...[
                _accountPanel(l, account),
                const SizedBox(height: 16),
                _totpPanel(l, account),
              ],
              const SizedBox(height: 16),
              _SyncPanel(enabled: account != null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginPanel(AppLocalizations l) => SysPanel(
        title: l.synSectionLogin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SysTextField(
              value: _server,
              label: l.synServer,
              hint: 'https://',
              keyboardType: TextInputType.url,
              textCapitalization: TextCapitalization.none,
              onChanged: (v) => _server = v,
            ),
            const SysFieldGap(),
            SysTextField(
              value: _name,
              label: l.synName,
              textCapitalization: TextCapitalization.none,
              onChanged: (v) => _name = v,
            ),
            const SysFieldGap(),
            _PasswordField(label: l.synPassword, onChanged: (v) => _password = v),
            if (_needTotp) ...[
              const SysFieldGap(),
              _CodeField(label: l.synTotpCode, onChanged: (v) => _totp = v),
            ],
            const SizedBox(height: 16),
            SysButton.primary(label: l.synLogin, expand: true, onPressed: _busy ? null : () => _login(l)),
            const SizedBox(height: 8),
            SysButton.secondary(label: l.synRegister, expand: true, onPressed: _busy ? null : () => _register(l)),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _resetMode = true;
                        _error = _info = null;
                      }),
              child: Text(l.synForgot, style: SysText.secondary.copyWith(color: SysColors.accentLight)),
            ),
          ],
        ),
      );

  Widget _resetPanel(AppLocalizations l) => SysPanel(
        title: l.synReset,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.synResetHint, style: SysText.caption),
            const SysFieldGap(),
            SysTextField(
              value: _server,
              label: l.synServer,
              keyboardType: TextInputType.url,
              textCapitalization: TextCapitalization.none,
              onChanged: (v) => _server = v,
            ),
            const SysFieldGap(),
            SysTextField(
              value: _name,
              label: l.synName,
              textCapitalization: TextCapitalization.none,
              onChanged: (v) => _name = v,
            ),
            const SysFieldGap(),
            _CodeField(label: l.synTotpCode, onChanged: (v) => _totp = v),
            const SysFieldGap(),
            _PasswordField(label: l.synNewPassword, onChanged: (v) => _newPassword = v),
            const SizedBox(height: 16),
            SysButton.primary(label: l.synReset, expand: true, onPressed: _busy ? null : () => _reset(l)),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _resetMode = false;
                        _error = null;
                      }),
              child: Text(l.synBackToLogin, style: SysText.secondary.copyWith(color: SysColors.accentLight)),
            ),
          ],
        ),
      );

  Widget _accountPanel(AppLocalizations l, Account a) => SysPanel(
        title: l.synTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.synSignedInAs(a.name), style: SysText.body),
            const SizedBox(height: 4),
            Text(a.serverUrl, style: SysText.caption),
            const SizedBox(height: 12),
            SysButton.danger(
              label: l.synLogout,
              expand: true,
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        await ref.read(authServiceProvider).logout();
                        _setup = null;
                      }),
            ),
          ],
        ),
      );

  Widget _totpPanel(AppLocalizations l, Account a) {
    final setup = _setup;
    return SysPanel(
      title: l.synSectionTotp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(a.totpEnabled ? l.synTotpOn : l.synTotpOff,
              style: SysText.secondary.copyWith(color: a.totpEnabled ? SysColors.success : SysColors.gold)),
          if (!a.totpEnabled && setup == null) ...[
            const SizedBox(height: 12),
            SysButton.primary(
              label: l.synTotpSetup,
              expand: true,
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        final s = await ref.read(authServiceProvider).beginTotp();
                        if (mounted) setState(() => _setup = s);
                      }),
            ),
          ],
          if (!a.totpEnabled && setup != null) ...[
            const SizedBox(height: 12),
            Text(l.synTotpScan, style: SysText.caption),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: QrImageView(data: setup.uri, size: 200, backgroundColor: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: SelectableText(setup.secret, style: SysText.mono)),
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: setup.secret));
                    if (!mounted) return;
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.synCopied)));
                  },
                  child: Text(l.synCopy, style: SysText.secondary.copyWith(color: SysColors.accentLight)),
                ),
              ],
            ),
            const SysFieldGap(),
            _CodeField(label: l.synTotpCode, onChanged: (v) => _totp = v),
            const SizedBox(height: 12),
            SysButton.primary(
              label: l.synTotpConfirm,
              expand: true,
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        await ref.read(authServiceProvider).confirmTotp(_totp);
                        _setup = null;
                        _totp = '';
                        _info = l.synTotpEnabled;
                      }),
            ),
          ],
        ],
      ),
    );
  }
}

class _SyncPanel extends ConsumerWidget {
  const _SyncPanel({required this.enabled});
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(syncStatusProvider).value ?? SyncStatus.off;
    final last = s.lastSyncAt;
    return SysPanel(
      title: l.synSectionSync,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SyncIndicator(onTap: () {}),
              Expanded(
                child: Text(SyncIndicator.labelOf(l, s.phase),
                    style: SysText.body.copyWith(color: SyncIndicator.colorOf(s.phase))),
              ),
            ],
          ),
          if (last != null)
            Text(l.synLastSync(DateFormat.MMMd(l.localeName).add_Hm().format(last)), style: SysText.caption),
          if (s.pending > 0) Text(l.synPending(s.pending), style: SysText.caption),
          if (s.phase == SyncPhase.error && s.message != null) Text(s.message!, style: SysText.caption),
          const SizedBox(height: 12),
          SysButton.secondary(
            label: l.synSyncNow,
            expand: true,
            onPressed: enabled && s.phase != SyncPhase.syncing ? () => ref.read(syncServiceProvider).syncNow() : null,
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: SysText.body.copyWith(color: color)),
      );
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({required this.label, required this.onChanged});
  final String label;
  final ValueChanged<String> onChanged;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) => TextField(
        obscureText: _hidden,
        autocorrect: false,
        enableSuggestions: false,
        onChanged: widget.onChanged,
        style: SysText.body,
        cursorColor: SysColors.accentLight,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: SysIconButton(
            glyph: _hidden ? SysGlyph.eye : SysGlyph.eyeOff,
            tooltip: _hidden ? AppLocalizations.of(context).polShowPassword : AppLocalizations.of(context).polHidePassword,
            color: SysColors.textCaption,
            size: 20,
            onPressed: () => setState(() => _hidden = !_hidden),
          ),
        ),
      );
}

class _CodeField extends StatelessWidget {
  const _CodeField({required this.label, required this.onChanged});
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
        onChanged: onChanged,
        style: SysText.mono.copyWith(fontSize: 18, letterSpacing: 4),
        cursorColor: SysColors.accentLight,
        decoration: InputDecoration(labelText: label),
      );
}
