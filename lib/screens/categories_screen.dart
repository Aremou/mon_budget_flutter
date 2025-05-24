import 'package:flutter/material.dart';
import 'package:mon_budget/models/category.dart';
import 'package:mon_budget/services/db_service.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _nameController = TextEditingController();
  List<Category> _categories = [];

  Future<void> _loadCategories() async {
    final data = await DBService.getAll('categories');
    setState(() {
      _categories = data.map((e) => Category.fromMap(e)).toList();
    });
  }

  Future<void> _addCategory(String name) async {
    await DBService.insert('categories', {'name': name});
    _loadCategories();
  }

  Future<void> _deleteCategory(int id) async {
    await DBService.delete('categories', id);
    _loadCategories();
  }

  Future<void> _editCategory(Category category) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: category.name);
        return AlertDialog(
          title: Text('Modifier la catégorie'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Nom'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler')),
            TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text('Enregistrer')),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      await DBService.update(
          'categories', {'id': category.id, 'name': newName});
      _loadCategories();
    }
  }

  void _openAddModal() {
    final _formKey = GlobalKey<FormState>();
    final _controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nouvelle Catégorie',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Nom'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Veuillez entrer un nom'
                        : null,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.save),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _addCategory(_controller.text);
                            Navigator.pop(context);
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
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Catégories'.toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.white,
        child: _categories.isEmpty
            ? Center(child: Text('Aucune catégorie pour le moment.'))
            : ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: Icon(Icons.label, color: Colors.blueAccent),
                      title: Text(cat.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editCategory(cat),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirmation'),
                                  content: Text(
                                      'Voulez-vous vraiment supprimer cette catégorie ?'),
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
                                _deleteCategory(cat.id!);
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
        onPressed: _openAddModal,
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
