import 'package:flutter/material.dart';
import 'package:mon_budget/services/db_service.dart';

class RevenuePage extends StatefulWidget {
  @override
  _RevenuePageState createState() => _RevenuePageState();
}

class _RevenuePageState extends State<RevenuePage> {
  List<Map<String, dynamic>> _revenues = [];
  List<Map<String, dynamic>> _filteredRevenues = [];
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalFiltered = 0.0;

  DateTime get _startOfMonth =>
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime get _endOfMonth =>
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  bool _isCustomFilter() {
    final now = DateTime.now();
    return !(_startDate?.year == now.year &&
        _startDate?.month == now.month &&
        _startDate?.day == 1 &&
        _endDate?.day == _endOfMonth.day);
  }

  Future<void> _loadData() async {
    _revenues = await DBService.getAll('revenues');
    _startDate = _startOfMonth;
    _endDate = _endOfMonth;
    _applyFilter();

    setState(() {});
  }

  void _applyFilter() {
    _filteredRevenues = _revenues.where((e) {
      final date = DateTime.parse(e['date']);
      return date.isAfter(_startDate!.subtract(Duration(days: 1))) &&
          date.isBefore(_endDate!.add(Duration(days: 1)));
    }).toList();
    _calculateTotal();
  }

  void _calculateTotal() {
    _totalFiltered = _filteredRevenues.fold(
        0.0, (sum, e) => sum + (e['amount'] as num).toDouble());
  }

  Future<void> _deleteRevenue(int id) async {
    await DBService.delete('revenues', id);
    _loadData();
  }

  Future<void> _editRevenue(Map<String, dynamic> r) async {
    final _formKey = GlobalKey<FormState>();
    final labelController = TextEditingController(text: r['label']);
    final amountController =
        TextEditingController(text: r['amount'].toString());
    final noteController = TextEditingController(text: r['note'] ?? '');
    DateTime selectedDate = DateTime.parse(r['date']);

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
                  Text('Modifier Revenu',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: labelController,
                    decoration: InputDecoration(labelText: 'Libellé'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Entrez un libellé' : null,
                  ),
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(labelText: 'Montant'),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Entrez un montant' : null,
                  ),
                  TextFormField(
                    controller: noteController,
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
                      setState(() {
                        selectedDate = picked;
                      });
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
                            await DBService.update('revenues', {
                              'id': r['id'],
                              'date': selectedDate.toIso8601String(),
                              'amount': double.tryParse(amountController.text
                                      .replaceAll(',', '.')) ??
                                  0.0,
                              'label': labelController.text,
                              'note': noteController.text,
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

  Future<void> _addRevenue() async {
    final _formKey = GlobalKey<FormState>();
    final labelController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Nouveau Revenu',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: labelController,
                      decoration: InputDecoration(labelText: 'Libellé'),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Entrez un libellé'
                          : null,
                    ),
                    TextFormField(
                      controller: amountController,
                      decoration: InputDecoration(labelText: 'Montant'),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Entrez un montant'
                          : null,
                    ),
                    TextFormField(
                      controller: noteController,
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
                          icon: Icon(Icons.save),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await DBService.insert('revenues', {
                                'date': selectedDate.toIso8601String(),
                                'amount': double.tryParse(amountController.text
                                        .replaceAll(',', '.')) ??
                                    0.0,
                                'label': labelController.text,
                                'note': noteController.text,
                              });
                              labelController.dispose();
                              amountController.dispose();
                              noteController.dispose();
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
        });
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
      appBar: AppBar(title: Text('Revenus')),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
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
                        _startDate = _startOfMonth;
                        _endDate = _endOfMonth;
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
              child: _filteredRevenues.isEmpty
                  ? Center(child: Text('Aucun revenu pour cette période.'))
                  : ListView.builder(
                      itemCount: _filteredRevenues.length,
                      itemBuilder: (context, index) {
                        final r = _filteredRevenues[index];
                        final date = DateTime.parse(r['date']);
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
                              '${r['label']} - ${r['amount']} FCFA',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                                'Date : ${date.toLocal().toString().split(" ")[0]}\n Note : ${r['note'] ?? '-'}'),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (DateTime.now().difference(date).inHours <
                                    24)
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editRevenue(r),
                                  ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Confirmation'),
                                        content: Text(
                                            'Voulez-vous vraiment supprimer ce revenu ?'),
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
                                      _deleteRevenue(r['id']);
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
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRevenue,
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
