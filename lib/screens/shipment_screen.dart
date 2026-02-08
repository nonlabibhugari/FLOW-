import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});
  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  List<Map<String, String>> _shipments = [];
  final trackC = TextEditingController();

  String selectedStatus = "في الطريق";
  final List<String> statusOptions = [
    "في الطريق",
    "تم الشحن",
    "تم الاستلام",
    "قيد المعالجة"
  ];

  @override
  void initState() {
    super.initState();
    _loadShipments();
  }

  _loadShipments() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('shipments_list');
    if (data != null) {
      setState(() {
        _shipments = List<Map<String, String>>.from(
            json.decode(data).map((item) => Map<String, String>.from(item)));
      });
    }
    await prefs.setInt('shipments_count', _shipments.length);
  }

  _saveAndRefresh() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('shipments_list', json.encode(_shipments));

    await prefs.setInt('shipments_count', _shipments.length);

    setState(() {});
  }

  void _addShipment() {
    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("إضافة شحنة جديدة", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: trackC,
                decoration: const InputDecoration(
                  labelText: "رقم التتبع",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: "حالة الشحنة",
                  border: OutlineInputBorder(),
                ),
                items: statusOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  setDialogState(() => selectedStatus = val!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c),
                child:
                    const Text("إلغاء", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                onPressed: () {
                  if (trackC.text.isNotEmpty) {
                    _shipments
                        .add({"id": trackC.text, "status": selectedStatus});
                    _saveAndRefresh();
                    trackC.clear();
                    Navigator.pop(c);
                  }
                },
                child: const Text("حفظ الشحنة",
                    style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text("إدارة الشحنات",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addShipment,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
      body: _shipments.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping_outlined,
                      size: 80, color: Colors.grey),
                  Text("لا توجد شحنات مسجلة حالياً",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _shipments.length,
              itemBuilder: (ctx, i) => Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    child:
                        const Icon(Icons.local_shipping, color: Colors.purple),
                  ),
                  title: Text(
                    "شحنة رقم: ${_shipments[i]['id']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      const Text("الحالة: "),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _shipments[i]['status'] == "في الطريق"
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${_shipments[i]['status']}",
                          style: TextStyle(
                              color: _shipments[i]['status'] == "في الطريق"
                                  ? Colors.orange
                                  : Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.red),
                    onPressed: () {
                      _shipments.removeAt(i);
                      _saveAndRefresh();
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
