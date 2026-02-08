import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});
  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  List<Map<String, String>> _suppliers = [];
  final nameC = TextEditingController();
  final phoneC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  _loadSuppliers() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('suppliers_list');
    if (data != null) {
      setState(() {
        _suppliers = List<Map<String, String>>.from(json.decode(data).map((item) => Map<String, String>.from(item)));
      });
    }
    await prefs.setInt('suppliers_count', _suppliers.length);
  }

  _saveAndRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('suppliers_list', json.encode(_suppliers));
    await prefs.setInt('suppliers_count', _suppliers.length);
    setState(() {}); 
  }

  void _addSupplier() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("إضافة مورد جديد"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: "اسم المورد"), textAlign: TextAlign.right),
            TextField(controller: phoneC, decoration: const InputDecoration(labelText: "رقم الهاتف"), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
          ElevatedButton(onPressed: () {
            if (nameC.text.isNotEmpty && phoneC.text.isNotEmpty) {
              _suppliers.add({"name": nameC.text, "phone": phoneC.text});
              _saveAndRefresh();
              nameC.clear(); phoneC.clear();
              Navigator.pop(c);
            }
          }, child: const Text("حفظ")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("دليل الموردين"), backgroundColor: Colors.green),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSupplier,
        backgroundColor: Colors.green,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: _suppliers.isEmpty
          ? const Center(child: Text("لا يوجد موردين مضافين"))
          : ListView.builder(
              itemCount: _suppliers.length,
              itemBuilder: (ctx, i) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.business, color: Colors.white)),
                  title: Text(_suppliers[i]['name']!),
                  subtitle: Text(_suppliers[i]['phone']!),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _suppliers.removeAt(i);
                      _saveAndRefresh();
                    },
                  ),
                ),
              ),
            ),
    );
  }
}