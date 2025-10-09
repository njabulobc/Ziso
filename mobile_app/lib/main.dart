import 'package:flutter/material.dart';

import 'core/domain/entities.dart';
import 'core/services/auth_service.dart';
import 'core/utils/theme.dart';
import 'features/entities/entity_configuration.dart';
import 'features/entities/entity_list_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZisoApp());
}

class ZisoApp extends StatefulWidget {
  const ZisoApp({super.key});

  @override
  State<ZisoApp> createState() => _ZisoAppState();
}

class _ZisoAppState extends State<ZisoApp> {
  final _pinService = PinAuthService();
  final _themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
  bool _requiresPin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final hasPin = await _pinService.hasPin();
    setState(() {
      _requiresPin = hasPin;
      _loading = false;
    });
  }

  void _setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
  }

  Future<void> _lock() async {
    if (await _pinService.hasPin()) {
      setState(() {
        _requiresPin = true;
      });
    }
  }

  Future<void> _unlock() async {
    setState(() {
      _requiresPin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(
        theme: ZisoTheme.light(),
        darkTheme: ZisoTheme.dark(),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Ziso Mobile',
          theme: ZisoTheme.light(),
          darkTheme: ZisoTheme.dark(),
          themeMode: mode,
          home: _requiresPin
              ? PinEntryScreen(
                  pinService: _pinService,
                  onAuthenticated: _unlock,
                )
              : HomeScreen(
                  pinService: _pinService,
                  onLock: _lock,
                  onThemeChanged: _setThemeMode,
                  currentTheme: mode,
                ),
        );
      },
    );
  }
}

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key, required this.pinService, required this.onAuthenticated});

  final PinAuthService pinService;
  final VoidCallback onAuthenticated;

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final _pinController = TextEditingController();
  String? _error;

  Future<void> _submit() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _error = 'Enter PIN');
      return;
    }
    final valid = await widget.pinService.verifyPin(pin);
    if (valid) {
      widget.onAuthenticated();
    } else {
      setState(() => _error = 'Incorrect PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unlock')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _pinController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'PIN',
                errorText: _error,
              ),
              keyboardType: TextInputType.number,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submit,
              child: const Text('Unlock'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await widget.pinService.clearPin();
                widget.onAuthenticated();
              },
              child: const Text('Forgot PIN? Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.pinService,
    required this.onLock,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  final PinAuthService pinService;
  final Future<void> Function() onLock;
  final void Function(ThemeMode mode) onThemeChanged;
  final ThemeMode currentTheme;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final EntityConfigurations _configurations;
  late final List<_ModuleEntry> _modules;

  @override
  void initState() {
    super.initState();
    _configurations = EntityConfigurations();
    _modules = [
      _ModuleEntry(
        title: _configurations.employees.name,
        builder: () => EntityListPage<Employee>(configuration: _configurations.employees),
      ),
      _ModuleEntry(
        title: _configurations.nextOfKin.name,
        builder: () => EntityListPage<NextOfKin>(configuration: _configurations.nextOfKin),
      ),
      _ModuleEntry(
        title: _configurations.directors.name,
        builder: () => EntityListPage<Director>(configuration: _configurations.directors),
      ),
      _ModuleEntry(
        title: _configurations.companies.name,
        builder: () => EntityListPage<Company>(configuration: _configurations.companies),
      ),
      _ModuleEntry(
        title: _configurations.courtCases.name,
        builder: () => EntityListPage<CourtCase>(configuration: _configurations.courtCases),
      ),
      _ModuleEntry(
        title: _configurations.customers.name,
        builder: () => EntityListPage<Customer>(configuration: _configurations.customers),
      ),
      _ModuleEntry(
        title: _configurations.criminalRecords.name,
        builder: () => EntityListPage<CriminalRecord>(configuration: _configurations.criminalRecords),
      ),
      _ModuleEntry(
        title: _configurations.previousTransactions.name,
        builder: () => EntityListPage<PreviousTransaction>(configuration: _configurations.previousTransactions),
      ),
      _ModuleEntry(
        title: _configurations.employmentRecords.name,
        builder: () => EntityListPage<EmploymentRecord>(configuration: _configurations.employmentRecords),
      ),
    ];
  }

  Future<void> _promptSetPin() async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter PIN'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Confirm PIN'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
              FilledButton(
                onPressed: () async {
                  if (controller.text.trim() != confirmController.text.trim() || controller.text.trim().isEmpty) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('PINs do not match')),
                    );
                    return;
                  }
                await widget.pinService.setPin(controller.text.trim());
                if (mounted) {
                  Navigator.of(context).pop();
                  await widget.onLock();
                }
              },
              child: const Text('Save PIN'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ziso Mobile Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'light':
                  widget.onThemeChanged(ThemeMode.light);
                  break;
                case 'dark':
                  widget.onThemeChanged(ThemeMode.dark);
                  break;
                case 'system':
                  widget.onThemeChanged(ThemeMode.system);
                  break;
              }
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: 'light',
                checked: widget.currentTheme == ThemeMode.light,
                child: const Text('Light Mode'),
              ),
              CheckedPopupMenuItem(
                value: 'dark',
                checked: widget.currentTheme == ThemeMode.dark,
                child: const Text('Dark Mode'),
              ),
              CheckedPopupMenuItem(
                value: 'system',
                checked: widget.currentTheme == ThemeMode.system,
                child: const Text('System Default'),
              ),
            ],
            icon: const Icon(Icons.color_lens_outlined),
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Lock App',
            onPressed: widget.onLock,
          ),
          IconButton(
            icon: const Icon(Icons.password_outlined),
            tooltip: 'Set PIN',
            onPressed: _promptSetPin,
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: _modules.length,
        itemBuilder: (context, index) {
          final module = _modules[index];
          return _ModuleCard(
            title: module.title,
            icon: Icons.folder_open,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => module.builder(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.title, required this.icon, required this.onTap});

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.primaryContainer,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: theme.colorScheme.onPrimaryContainer),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleEntry {
  const _ModuleEntry({required this.title, required this.builder});

  final String title;
  final Widget Function() builder;
}
