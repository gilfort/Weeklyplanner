import 'package:flutter/material.dart';

import '../providers/storage_config_provider.dart';
import '../repositories/webdav_storage_backend.dart';

enum WebDavPreset { oneDrive, nextcloud, filen, custom }

class WebDavFormResult {
  final StorageConfig config;
  final String password;
  WebDavFormResult(this.config, this.password);
}

/// Reusable form for WebDAV configuration. Used by setup and settings screens.
///
/// Returns `(StorageConfig, password)` via [onSubmit] when the user confirms.
/// Caller is responsible for persisting the config and saving the password
/// via `WebDavCredentialsService`.
class WebDavConfigForm extends StatefulWidget {
  final StorageConfig? initial;
  final String? initialPassword;
  final void Function(WebDavFormResult) onSubmit;
  final String submitLabel;

  const WebDavConfigForm({
    super.key,
    this.initial,
    this.initialPassword,
    required this.onSubmit,
    this.submitLabel = 'Speichern',
  });

  @override
  State<WebDavConfigForm> createState() => _WebDavConfigFormState();
}

class _WebDavConfigFormState extends State<WebDavConfigForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlCtrl;
  late final TextEditingController _userCtrl;
  late final TextEditingController _passCtrl;
  late final TextEditingController _prefixCtrl;

  WebDavPreset _preset = WebDavPreset.custom;
  bool _obscurePassword = true;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _urlCtrl = TextEditingController(text: init?.webdavUrl ?? '');
    _userCtrl = TextEditingController(text: init?.webdavUsername ?? '');
    _passCtrl = TextEditingController(text: widget.initialPassword ?? '');
    _prefixCtrl = TextEditingController(
        text: init?.webdavPathPrefix ?? '/MealPlanner');
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _prefixCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(WebDavPreset p) {
    setState(() {
      _preset = p;
      switch (p) {
        case WebDavPreset.oneDrive:
          if (_urlCtrl.text.isEmpty) {
            _urlCtrl.text = 'https://d.docs.live.net/<CID>/';
          }
          break;
        case WebDavPreset.nextcloud:
          if (_urlCtrl.text.isEmpty) {
            _urlCtrl.text = 'https://<host>/remote.php/dav/files/<user>/';
          }
          break;
        case WebDavPreset.filen:
          // No template — Filen requires self-hosted server.
          break;
        case WebDavPreset.custom:
          break;
      }
    });
  }

  String? _validateUrl(String? v) {
    if (v == null || v.trim().isEmpty) return 'URL erforderlich';
    final uri = Uri.tryParse(v.trim());
    if (uri == null || !uri.hasScheme || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return 'Ungültige URL (http/https)';
    }
    if (v.contains('<') || v.contains('>')) {
      return 'Platzhalter ersetzen';
    }
    return null;
  }

  String? _validateRequired(String? v) {
    if (v == null || v.trim().isEmpty) return 'Erforderlich';
    return null;
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _testing = true);
    final backend = WebDavStorageBackend(
      baseUrl: _urlCtrl.text.trim(),
      username: _userCtrl.text.trim(),
      password: _passCtrl.text,
      pathPrefix: _prefixCtrl.text.trim().isEmpty
          ? '/MealPlanner'
          : _prefixCtrl.text.trim(),
    );
    String message;
    bool ok = false;
    try {
      await backend.ping();
      ok = true;
      message = 'Verbindung erfolgreich';
    } on WebDavException catch (e) {
      message = e.message;
    } catch (e) {
      message = 'Fehler: $e';
    }
    if (!mounted) return;
    setState(() => _testing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final config = StorageConfig(
      type: StorageType.webdav,
      webdavUrl: _urlCtrl.text.trim(),
      webdavUsername: _userCtrl.text.trim(),
      webdavPathPrefix: _prefixCtrl.text.trim().isEmpty
          ? '/MealPlanner'
          : _prefixCtrl.text.trim(),
    );
    widget.onSubmit(WebDavFormResult(config, _passCtrl.text));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<WebDavPreset>(
              initialValue: _preset,
              decoration: const InputDecoration(labelText: 'Anbieter'),
              items: const [
                DropdownMenuItem(
                    value: WebDavPreset.custom, child: Text('Benutzerdefiniert')),
                DropdownMenuItem(
                    value: WebDavPreset.oneDrive, child: Text('OneDrive')),
                DropdownMenuItem(
                    value: WebDavPreset.nextcloud, child: Text('Nextcloud')),
                DropdownMenuItem(
                    value: WebDavPreset.filen, child: Text('Filen')),
              ],
              onChanged: (v) {
                if (v != null) _applyPreset(v);
              },
            ),
            const SizedBox(height: 12),
            if (_preset == WebDavPreset.oneDrive)
              const _HelpCard(
                'OneDrive: Die CID findest du in der OneDrive-Web-URL nach '
                '`?cid=` (z. B. `https://onedrive.live.com/?cid=ABCDEF...`). '
                'Setze die CID in `<CID>` ein. Anmeldung: dein Microsoft-Konto.',
              ),
            if (_preset == WebDavPreset.nextcloud)
              const _HelpCard(
                'Nextcloud: <host> ist deine Nextcloud-Domain, <user> dein '
                'Login-Name. Verwende ein App-Passwort '
                '(Einstellungen → Sicherheit → App-Passwort), nicht dein '
                'Hauptpasswort.',
              ),
            if (_preset == WebDavPreset.filen)
              const _HelpCard(
                'Filen bietet KEINEN gehosteten WebDAV-Endpoint (auch nicht '
                'in Pro-Plänen). Nutzbar nur, wenn du auf einem 24/7-Server '
                'oder NAS `filen webdav --w-user … --w-password … --w-https` '
                '(oder die Desktop-App) laufen lässt und den Server vom '
                'Handy aus erreichbar machst (Heimnetz + DynDNS/Port-'
                'Forwarding oder VPN). URL und Credentials sind die des '
                'Self-Hosted-Servers, NICHT dein Filen-Account.',
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _urlCtrl,
              decoration: const InputDecoration(
                labelText: 'WebDAV-URL',
                hintText: 'https://...',
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
              validator: _validateUrl,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _userCtrl,
              decoration: const InputDecoration(labelText: 'Benutzername'),
              autocorrect: false,
              validator: _validateRequired,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passCtrl,
              decoration: InputDecoration(
                labelText: 'Passwort',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              autocorrect: false,
              validator: _validateRequired,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _prefixCtrl,
              decoration: const InputDecoration(
                labelText: 'Ordner-Prefix',
                hintText: '/MealPlanner',
              ),
              autocorrect: false,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _testing ? null : _testConnection,
                    icon: _testing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.wifi_tethering),
                    label: const Text('Verbindung testen'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save),
                    label: Text(widget.submitLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final String text;
  const _HelpCard(this.text);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}
