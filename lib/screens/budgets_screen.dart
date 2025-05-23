import 'package:flutter/material.dart';
import 'package:mon_budget/services/db_service.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  List<Map<String, dynamic>> _budgets = [];
  List<Map<String, dynamic>> _categories = [];

  Future<void> _loadData() async {
    // _expenses = await DBService.getAll('expenses');
    _budgets = await DBService.getAll('budgets');
    _categories = await DBService.getAll('categories');
    setState(() {});
  }

  Future<void> _deleteBudget(int id) async {
    await DBService.delete('budgets', id);
    _loadData();
  }

  Future<void> _editBudget(Map<String, dynamic> budget) async {
    final _formKey = GlobalKey<FormState>();
    String? selectedPeriod = budget['period'];
    String? selectedCategoryId = budget['categoryId'].toString();
    final amountController =
        TextEditingController(text: budget['amount'].toString());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Modifier Budget',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: selectedPeriod,
                    decoration: InputDecoration(labelText: 'Périodicité'),
                    items: ['Hebdomadaire', 'Mensuel', 'Trimestriel', 'Annuel']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) => selectedPeriod = val,
                    validator: (val) =>
                        val == null ? 'Choisissez une périodicité' : null,
                  ),
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(labelText: 'Montant'),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Entrez un montant' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: InputDecoration(labelText: 'Catégorie'),
                    items: _categories
                        .map((cat) => DropdownMenuItem(
                              value: cat['id'].toString(),
                              child: Text(cat['name']),
                            ))
                        .toList(),
                    onChanged: (val) => selectedCategoryId = val,
                    validator: (val) =>
                        val == null ? 'Choisissez une catégorie' : null,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final duplicate = _budgets
                            .where((b) =>
                                b['period'] == selectedPeriod &&
                                b['id'] != budget['id'])
                            .toList();
                        if (duplicate.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Attention'),
                              content: Text(
                                  'Un autre budget avec cette périodicité existe déjà.'),
                              actions: [
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () => Navigator.pop(context),
                                )
                              ],
                            ),
                          );
                          return;
                        }
                        await DBService.update('budgets', {
                          'id': budget['id'],
                          'period': selectedPeriod,
                          'amount': double.parse(amountController.text),
                          'categoryId': int.parse(selectedCategoryId!),
                        });
                        Navigator.pop(context);
                        _loadData();
                      }
                    },
                    child: Text('Modifier'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addBudget() async {
    final _formKey = GlobalKey<FormState>();
    String? selectedPeriod;
    String? selectedCategoryId;
    final amountController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Nouveau Budget',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Périodicité'),
                    items: ['Hebdomadaire', 'Mensuel', 'Trimestriel', 'Annuel']
                        .map((period) => DropdownMenuItem(
                            value: period, child: Text(period)))
                        .toList(),
                    onChanged: (value) => selectedPeriod = value,
                    validator: (value) =>
                        value == null ? 'Choisissez une périodicité' : null,
                  ),
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(labelText: 'Montant'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Entrez un montant'
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Catégorie'),
                    items: _categories
                        .map((cat) => DropdownMenuItem(
                              value: cat['id'].toString(),
                              child: Text(cat['name']),
                            ))
                        .toList(),
                    onChanged: (value) => selectedCategoryId = value,
                    validator: (value) =>
                        value == null ? 'Choisissez une catégorie' : null,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final existing = _budgets
                            .where((b) => b['period'] == selectedPeriod)
                            .toList();
                        if (existing.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Attention'),
                              content: Text(
                                  'Un autre budget avec cette périodicité existe déjà.'),
                              actions: [
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () => Navigator.pop(context),
                                )
                              ],
                            ),
                          );
                          return;
                        }
                        await DBService.insert('budgets', {
                          'period': selectedPeriod,
                          'amount': double.parse(amountController.text),
                          'categoryId': int.parse(selectedCategoryId!),
                        });
                        Navigator.pop(context);
                        _loadData();
                      }
                    },
                    child: Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budgets')),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: _budgets.length,
          itemBuilder: (context, index) {
            final budget = _budgets[index];
            final categoryName = _categories.firstWhere(
                (c) => c['id'] == budget['categoryId'],
                orElse: () => {'name': 'Inconnu'})['name'];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: ListTile(
                title: Text('${budget['period']} - ${budget['amount']} FCFA'),
                subtitle: Text('Catégorie : $categoryName'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editBudget(budget),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirmation'),
                            content: Text(
                                'Voulez-vous vraiment supprimer ce budget ?'),
                            actions: [
                              TextButton(
                                  child: Text('Annuler'),
                                  onPressed: () =>
                                      Navigator.pop(context, false)),
                              TextButton(
                                  child: Text('Supprimer'),
                                  onPressed: () =>
                                      Navigator.pop(context, true)),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          _deleteBudget(budget['id']);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBudget,
        child: Icon(Icons.add),
      ),
    );
  }
}
