import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mon_budget/services/db_service.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _budgets = [];
  List<Map<String, dynamic>> _categories = [];
  String _selectedPeriod = 'Mensuel';

  final List<Color> pieColors = [
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.teal,
    Colors.purpleAccent,
    Colors.amber,
    Colors.lightGreen,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _expenses = await DBService.getAll('expenses');
    _budgets = await DBService.getAll('budgets');
    _categories = await DBService.getAll('categories');
    setState(() {});
  }

  bool _matchPeriod(DateTime date, String period) {
    final now = DateTime.now();
    switch (period) {
      case 'Hebdomadaire':
        return now.difference(date).inDays <= 7;
      case 'Mensuel':
        return date.month == now.month && date.year == now.year;
      case 'Trimestriel':
        final quarter = ((now.month - 1) ~/ 3) + 1;
        final startMonth = (quarter - 1) * 3 + 1;
        return date.month >= startMonth &&
            date.month < startMonth + 3 &&
            date.year == now.year;
      case 'Annuel':
        return date.year == now.year;
      default:
        return true;
    }
  }

  Map<String, double> _getExpensesByCategory() {
    final Map<String, double> data = {};
    for (final e in _expenses) {
      final date = DateTime.parse(e['date']);
      if (_matchPeriod(date, _selectedPeriod)) {
        final cat = _categories.firstWhere((c) => c['id'] == e['categoryId'],
            orElse: () => {'name': 'Inconnu'});
        data[cat['name']] = (data[cat['name']] ?? 0) + e['amount'];
      }
    }
    return data;
  }

  List<BarChartGroupData> _buildBudgetComparisonChart() {
    List<BarChartGroupData> bars = [];
    int index = 0;
    for (final cat in _categories) {
      final catId = cat['id'];
      final budget = _budgets.firstWhere((b) => b['categoryId'] == catId,
          orElse: () => {'amount': 0.0});
      final double budgetAmount = budget['amount']?.toDouble() ?? 0.0;
      final double spent = _expenses
          .where((e) =>
              e['categoryId'] == catId &&
              _matchPeriod(DateTime.parse(e['date']), _selectedPeriod))
          .fold(0.0, (sum, e) => sum + e['amount']);

      bars.add(BarChartGroupData(x: index++, barRods: [
        BarChartRodData(toY: spent, color: Colors.redAccent, width: 8),
        BarChartRodData(toY: budgetAmount, color: Colors.blueAccent, width: 8),
      ]));
    }
    return bars;
  }

  @override
  Widget build(BuildContext context) {
    final expenseData = _getExpensesByCategory();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Row(
          children: [
            // Icon(Icons.pie_chart),
            SizedBox(width: 8),
            Text(
              'Dashboard'.toUpperCase(),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text('Période : ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        value: _selectedPeriod,
                        underline: SizedBox(),
                        items: [
                          'Hebdomadaire',
                          'Mensuel',
                          'Trimestriel',
                          'Annuel'
                        ]
                            .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p, style: TextStyle(fontSize: 14))))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedPeriod = val!),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Dépenses par catégorie ($_selectedPeriod)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: PieChart(PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: expenseData.entries.map((e) {
                            int index =
                                expenseData.keys.toList().indexOf(e.key);
                            return PieChartSectionData(
                              title: '',
                              value: e.value,
                              radius: 60,
                              color: pieColors[index % pieColors.length],
                            );
                          }).toList(),
                        )),
                      ),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: expenseData.keys.map((name) {
                          int index = expenseData.keys.toList().indexOf(name);
                          return Chip(
                            label: Text(name),
                            backgroundColor:
                                pieColors[index % pieColors.length],
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text('Comparaison Dépenses vs Budgets',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.square, color: Colors.redAccent, size: 16),
                          SizedBox(width: 4),
                          Text("Dépenses"),
                          SizedBox(width: 16),
                          Icon(Icons.square,
                              color: Colors.blueAccent, size: 16),
                          SizedBox(width: 4),
                          Text("Budgets"),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 300,
                        child: BarChart(BarChartData(
                          barGroups: _buildBudgetComparisonChart(),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 42,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 &&
                                      index < _categories.length) {
                                    return Text(
                                      _categories[index]['name'],
                                      style: TextStyle(fontSize: 10),
                                    );
                                  }
                                  return SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true, reservedSize: 40),
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
