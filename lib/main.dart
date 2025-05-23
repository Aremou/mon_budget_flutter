import 'package:flutter/material.dart';
import 'package:mon_budget/screens/home_screen.dart';
import 'package:mon_budget/services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await DBService.init();
  // await DBService.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Budget',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // theme: ThemeData(primarySwatch: Colors.teal),
      home: HomeScreen(),
    );
  }
}
