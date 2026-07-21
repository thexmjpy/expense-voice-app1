import 'package:flutter/material.dart';
import 'screens/voice_entry_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const ExpenseVoiceApp());
}

class ExpenseVoiceApp extends StatelessWidget {
  const ExpenseVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مدیریت هزینه صوتی',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final _screens = const [
    VoiceEntryScreen(),
    DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'ثبت'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'داشبورد'),
        ],
      ),
    );
  }
}
