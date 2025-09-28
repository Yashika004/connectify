import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  final AuthService _authService = AuthService();
  String? _userName;

  // get saved theme mode
  void getThemeMode() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      setState(() {
        isDarkMode = true;
      });
    } else {
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void initState() {
    _loadUserName();
    getThemeMode();
    super.initState();
  }

  Future<void> _logout() async {
    final AuthService authService = AuthService();
    try {
      await authService.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    }
  }

  Future<void> _loadUserName() async {
    if (FirebaseAuth.instance.currentUser != null) {
      Map<String, dynamic>? profile = await _authService.getUserProfile(
        FirebaseAuth.instance.currentUser!.uid,
      );
      if (mounted) {
        setState(() {
          _userName = profile?['name'] ?? 'Anonymous';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                _userName?.substring(0, 1).toUpperCase() ?? '?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50, color: const Color.fromARGB(255, 171, 30, 77)),
              ),
            ),

            SizedBox(height: 8.0),

            Text(_userName ?? 'User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),

            SizedBox(height: 10.0),

            Card(
              child: SwitchListTile(
                title: const Text("Change Theme"),
                secondary: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  child: Icon(
                    isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });

                  if (value) {
                    AdaptiveTheme.of(context).setDark();
                  } else {
                    AdaptiveTheme.of(context).setLight();
                  }
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
