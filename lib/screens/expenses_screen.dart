import 'package:flutter/material.dart';
import 'package:mon_budget/services/db_service.dart';

class ExpensePage extends StatefulWidget {
  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _filteredExpenses = [];
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalFiltered = 0.0;

  final _labelController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  DateTime get _startOfWeek {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  bool _isCustomFilter() {
    final now = DateTime.now();
    return !(_startDate != null &&
        _endDate != null &&
        _startDate!.year == _startOfWeek.year &&
        _startDate!.month == _startOfWeek.month &&
        _startDate!.day == _startOfWeek.day &&
        _endDate!.year == now.year &&
        _endDate!.month == now.month &&
        _endDate!.day == now.day);
  }

  Future<void> _loadData() async {
    _expenses = await DBService.getAll('expenses');
    _categories = await DBService.getAll('categories');

    _startDate = _startOfWeek;
    _endDate = DateTime.now();

    _applyFilter();
    setState(() {});
  }

  void _applyFilter() {
    _filteredExpenses = _expenses.where((e) {
      final date = DateTime.parse(e['date']);
      return date.isAfter(_startDate!.subtract(Duration(days: 1))) &&
          date.isBefore(_endDate!.add(Duration(days: 1)));
    }).toList();
    _calculateTotal();
  }

  void _calculateTotal() {
    _totalFiltered = _filteredExpenses.fold(
        0.0, (sum, e) => sum + (e['amount'] as num).toDouble());
  }

  Future<void> _deleteExpense(int id) async {
    await DBService.delete('expenses', id);
    _loadData();
  }

  Future<void> _editExpense(Map<String, dynamic> expense) async {
    final _formKey = GlobalKey<FormState>();
    String? selectedCategoryId = expense['categoryId'].toString();
    _labelController.text = expense['label'];
    _amountController.text = expense['amount'].toString();
    _noteController.text = expense['note'] ?? '';
    DateTime selectedDate = DateTime.parse(expense['date']);

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
                  Text('Modifier Dépense',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _labelController,
                    decoration: InputDecoration(labelText: 'Libellé'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Entrez un libellé' : null,
                  ),
                  TextFormField(
                    controller: _amountController,
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
                  TextFormField(
                    controller: _noteController,
                    decoration:
                        InputDecoration(labelText: 'Observation (optionnel)'),
                  ),
                  SizedBox(height: 8),
                  datePickerRow(selectedDate, () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  }),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.edit),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await DBService.update('expenses', {
                              'id': expense['id'],
                              'date': selectedDate.toIso8601String(),
                              'categoryId': int.parse(selectedCategoryId!),
                              'amount': double.parse(_amountController.text),
                              'label': _labelController.text,
                              'note': _noteController.text,
                            });
                            Navigator.pop(context);
                            _loadData();
                          }
                        },
                        label: Text('Modifier'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addExpense() async {
    final _formKey = GlobalKey<FormState>();
    String? selectedCategoryId;
    _labelController.clear();
    _amountController.clear();
    _noteController.clear();
    DateTime selectedDate = DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Nouvelle Dépense',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextFormField(
                        controller: _labelController,
                        decoration: InputDecoration(labelText: 'Libellé'),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Entrez un libellé'
                            : null,
                      ),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(labelText: 'Montant'),
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.isEmpty
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
                        onChanged: (val) => selectedCategoryId = val,
                        validator: (val) =>
                            val == null ? 'Choisissez une catégorie' : null,
                      ),
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                            labelText: 'Observation (optionnel)'),
                      ),
                      SizedBox(height: 8),
                      datePickerRow(selectedDate, () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      }),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.save),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await DBService.insert('expenses', {
                                  'date': selectedDate.toIso8601String(),
                                  'categoryId': int.parse(selectedCategoryId!),
                                  'amount': double.tryParse(_amountController
                                          .text
                                          .replaceAll(',', '.')) ??
                                      0.0,
                                  'label': _labelController.text,
                                  'note': _noteController.text,
                                });
                                Navigator.pop(context);
                                _loadData();
                              }
                            },
                            label: Text('Ajouter'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
      appBar: AppBar(title: Text('Dépenses')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _startDate != null && _endDate != null
                            ? 'Total du ${_startDate!.toLocal().toString().split(" ")[0]} '
                                'au ${_endDate!.toLocal().toString().split(" ")[0]} :'
                            : 'Total général :',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        '${_totalFiltered.toStringAsFixed(2)} FCFA',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.blue),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked.start;
                        _endDate = picked.end;
                        _applyFilter();
                      });
                    }
                  },
                ),
                if (_isCustomFilter())
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _startDate = _startOfWeek;
                        _endDate = DateTime.now();
                        _applyFilter();
                      });
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: _filteredExpenses.isEmpty
                  ? Center(child: Text('Aucune dépense pour cette période.'))
                  : ListView.builder(
                      itemCount: _filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = _filteredExpenses[index];
                        final categoryName = _categories.firstWhere(
                            (c) => c['id'] == expense['categoryId'],
                            orElse: () => {'name': 'Inconnu'})['name'];
                        final date = DateTime.parse(expense['date']);
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: ListTile(
                            title: Text(
                              '${expense['label']} - ${expense['amount']} FCFA',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            subtitle: Text(
                                'Catégorie: $categoryName\n Date: ${date.toLocal().toString().split(" ")[0]}\n Note: ${expense['note'] ?? '-'}'),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (DateTime.now().difference(date).inHours <
                                    24)
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editExpense(expense),
                                  ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Confirmation'),
                                        content: Text(
                                            'Voulez-vous vraiment supprimer cette dépense ?'),
                                        actions: [
                                          TextButton(
                                              child: Text('Annuler'),
                                              onPressed: () => Navigator.pop(
                                                  context, false)),
                                          TextButton(
                                              child: Text('Supprimer'),
                                              onPressed: () =>
                                                  Navigator.pop(context, true)),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      _deleteExpense(expense['id']);
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: Icon(Icons.add),
        label: Text('Ajouter'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

Widget datePickerRow(DateTime selectedDate, VoidCallback onPick) {
  return Row(
    children: [
      Text('Date : ${selectedDate.toLocal().toString().split(" ")[0]}'),
      Spacer(),
      TextButton(
        onPressed: onPick,
        child: Text('Choisir la date'),
      ),
    ],
  );
}
