import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 
import '../controller/db_helper.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => isLoading = true);
    List<Map<String, dynamic>> temp = [];

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> hiddenIds = await DbHelper.getHiddenNotifications();

      
      final products = await DbHelper.getProducts();
      for (var p in products) {
        String currentId = "low_${p.id}";
        if (p.quantity < 10 && !hiddenIds.contains(currentId)) {
          temp.add({
            "id": currentId,
            "title": "نقص في المخزون ⚠️",
            "body": "المنتج (${p.name}) الكمية المتبقية ${p.quantity}",
            "icon": Icons.inventory_2_outlined,
            "color": Colors.orange,
          });
        }
      }

      
      String? shipmentsData = prefs.getString('shipments_list');
      if (shipmentsData != null) {
        List<dynamic> shipmentsList = json.decode(shipmentsData);
        for (var s in shipmentsList) {
          
          if (s['status'] == "في الطريق" && !hiddenIds.contains("ship_${s['id']}")) {
            temp.add({
              "id": "ship_${s['id']}",
              "title": "شحنة قادمة 🚚",
              "body": "الشحنة رقم (${s['id']}) هي الآن في الطريق إليك",
              "icon": Icons.local_shipping_outlined,
              "color": Colors.purple,
            });
          }
        }
      }

    } catch (e) {
      debugPrint("خطأ في جلب التنبيهات: $e");
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notifications_count', temp.length);

    setState(() {
      notifications = temp;
      isLoading = false;
    });
  }

  Future<void> _deleteNotification(int index) async {
    String idToDelete = notifications[index]['id'];
    await DbHelper.hideNotification(idToDelete);

    setState(() {
      notifications.removeAt(index);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notifications_count', notifications.length);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم حذف التنبيه نهائياً")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text("التنبيهات", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text("لا توجد تنبيهات حالياً"))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: n['color'].withOpacity(0.1),
                          child: Icon(n['icon'], color: n['color']),
                        ),
                        title: Text(n['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(n['body']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNotification(index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}