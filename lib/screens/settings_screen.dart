import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController();
  final _tokenController = TextEditingController();
  final _sessionController = TextEditingController();
  final _intervalController = TextEditingController();
  final _storageService = StorageService();

  bool _isLoading = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final settings = await _storageService.loadSettings();
    if (settings != null) {
      _serverUrlController.text = settings.serverUrl;
      _tokenController.text = settings.accessToken ?? '';
      _sessionController.text = settings.currentSession ?? 'default';
      _intervalController.text = settings.trackingIntervalSeconds.toString();
    } else {
      _sessionController.text = 'default';
      _intervalController.text = '60';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final settings = AppSettings(
      serverUrl: _serverUrlController.text.trim(),
      accessToken: _tokenController.text.trim(),
      currentSession: _sessionController.text.trim(),
      trackingIntervalSeconds: int.parse(_intervalController.text),
    );

    await _storageService.saveSettings(settings);

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _testConnection() async {
    if (_serverUrlController.text.isEmpty || _tokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter server URL and token first')),
      );
      return;
    }

    setState(() => _isTesting = true);

    final apiService = ApiService(
      baseUrl: _serverUrlController.text.trim(),
      accessToken: _tokenController.text.trim(),
    );

    final success = await apiService.testConnection();

    if (mounted) {
      setState(() => _isTesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Connection successful!'
              : 'Connection failed. Check your settings.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _tokenController.dispose();
    _sessionController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          if (_isTesting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.wifi),
              onPressed: _testConnection,
              tooltip: 'Test Connection',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _serverUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Server URL',
                        hintText: 'https://your-vibe-tracker.com',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter server URL';
                        }
                        if (!value.startsWith('http://') && !value.startsWith('https://')) {
                          return 'URL must start with http:// or https://';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tokenController,
                      decoration: const InputDecoration(
                        labelText: 'Access Token',
                        hintText: 'Your API token',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter access token';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sessionController,
                      decoration: const InputDecoration(
                        labelText: 'Session Name',
                        hintText: 'default',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter session name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _intervalController,
                      decoration: const InputDecoration(
                        labelText: 'Tracking Interval (seconds)',
                        hintText: '60',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter tracking interval';
                        }
                        final interval = int.tryParse(value);
                        if (interval == null || interval < 10) {
                          return 'Interval must be at least 10 seconds';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('Save Settings', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Note: You need to configure your Vibe Tracker server URL and access token before starting location tracking.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
