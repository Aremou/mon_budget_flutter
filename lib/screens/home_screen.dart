import 'package:flutter/material.dart';
import 'package:mon_budget/screens/budgets_screen.dart';
import 'package:mon_budget/screens/categories_screen.dart';
import 'package:mon_budget/screens/dashboard_screen.dart';
import 'package:mon_budget/screens/expenses_screen.dart';
import 'package:mon_budget/screens/revenues_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;

  final _pages = [
    CategoryPage(),
    BudgetPage(),
    DashboardPage(),
    ExpensePage(),
    RevenuePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Mon Budget")),
      backgroundColor: Colors.white, // Fond du body en blanc
      body: _pages[_currentIndex],

      // Bouton central : Dashboard
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _currentIndex = 2),
        backgroundColor: Colors.blueAccent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          Icons.bar_chart,
          size: 30,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Colors.blueAccent,
        notchMargin: 6,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.category, 'Catégories', 0),
              _buildNavItem(Icons.account_balance_wallet, 'Budgets', 1),
              SizedBox(width: 48),
              _buildNavItem(Icons.money_off, 'Dépenses', 3),
              _buildNavItem(Icons.attach_money, 'Revenus', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isSelected ? Colors.white : Colors.white60, size: 24),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
