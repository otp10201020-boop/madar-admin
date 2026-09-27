import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ضع رابط السيرفر/الاستضافة الخاص بك هنا
const String baseUrl = "https://your-domain.com/api.php";

void main() {
  runApp(const MadarAdminApp());
}

class MadarAdminApp extends StatefulWidget {
  const MadarAdminApp({super.key});

  @override
  State<MadarAdminApp> createState() => _MadarAdminAppState();
}

class _MadarAdminAppState extends State<MadarAdminApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'المدار الرئيسي - الإدارة العليا',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        primaryColor: const Color(0xFF06B6D4),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        primaryColor: const Color(0xFF10B981),
      ),
      home: AdminAppScreen(onToggleTheme: _toggleTheme),
    );
  }
}

class AdminAppScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const AdminAppScreen({super.key, required this.onToggleTheme});

  @override
  State<AdminAppScreen> createState() => _AdminAppScreenState();
}

class _AdminAppScreenState extends State<AdminAppScreen> {
  List pendingRequests = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse('$baseUrl?action=get_pending_requests'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'success') {
          setState(() => pendingRequests = data['requests']);
        }
      }
    } catch (_) {
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المدار الرئيسي - الإدارة'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchRequests),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'طلبات التفعيل المعلقة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF10B981) : const Color(0xFF06B6D4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: pendingRequests.isEmpty
                        ? const Center(child: Text('لا توجد طلبات تفعيل معلقة'))
                        : ListView.builder(
                            itemCount: pendingRequests.length,
                            itemBuilder: (context, index) {
                              final req = pendingRequests[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  title: Text(req['name'] ?? ''),
                                  subtitle: Text('@${req['username']}'),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                                    onPressed: () {},
                                    child: const Text('موافقة + كود', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
