import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

import 'inventory_screen.dart';
import 'suppliers_screen.dart';
import 'notification_screen.dart';
import 'shipment_screen.dart';
import 'profile_screen.dart';
import '../controller/db_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int prodCount = 0;
  int suppCount = 0;
  int shipCount = 0;
  int notificationCount = 0;

  String name = "";
  String email = "";
  String image = "";

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final prefs = await SharedPreferences.getInstance();

    final products = await DbHelper.getProducts();
    final hiddenIds = await DbHelper.getHiddenNotifications();

    int activeNotifications = 0;

    for (var p in products) {
      if (p.quantity < 10 && !hiddenIds.contains("low_${p.id}")) {
        activeNotifications++;
      }
    }

    String? shipmentsData = prefs.getString('shipments_list');
    if (shipmentsData != null) {
      List<dynamic> shipmentsList = json.decode(shipmentsData);
      for (var s in shipmentsList) {
        if (s['status'] == "في الطريق" &&
            !hiddenIds.contains("ship_${s['id']}")) {
          activeNotifications++;
        }
      }
    }

    setState(() {
      name = prefs.getString('username') ?? "المستخدم";
      email = prefs.getString('email') ?? "admin@corporate.com";
      image = prefs.getString('profile_image') ?? "";

      prodCount = products.length;
      suppCount = prefs.getInt('suppliers_count') ?? 0;
      shipCount =
          (shipmentsData != null) ? json.decode(shipmentsData).length : 0;

      notificationCount = activeNotifications;
    });

    await prefs.setInt('notifications_count', activeNotifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FLOW",
          style: TextStyle(
              color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.blue),
        actions: [
          // جرس الإشعارات العلوي
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 28),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationScreen()),
                  );
                  _refreshData();
                },
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    constraints:
                        const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              accountName: Text(name),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    image.isNotEmpty ? FileImage(File(image)) : null,
                child:
                    image.isEmpty ? const Icon(Icons.person, size: 40) : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("الرئيسية"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("الملف الشخصي"),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()));
                _refreshData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text("المخزون"),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const InventoryScreen()));
                _refreshData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text("الموردين"),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SuppliersScreen()));
                _refreshData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("التنبيهات"),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationScreen()));
                _refreshData();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("تسجيل الخروج"),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _card("المنتجات", prodCount, Icons.inventory_2, Colors.blue,
                () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const InventoryScreen()));
              _refreshData();
            }),
            _card("الموردين", suppCount, Icons.people, Colors.green, () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SuppliersScreen()));
              _refreshData();
            }),
            _card(
              "تنبيهات",
              notificationCount > 0 ? notificationCount : null,
              Icons.warning_amber_rounded,
              notificationCount > 0 ? Colors.red : Colors.orange,
              () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationScreen()));
                _refreshData();
              },
            ),
            _card("شحنات", shipCount, Icons.local_shipping, Colors.purple,
                () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ShipmentsScreen()));
              _refreshData();
            }),
          ],
        ),
      ),
    );
  }

  Widget _card(
      String title, int? count, IconData icon, Color col, VoidCallback action) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: col.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: col),
            const SizedBox(height: 6),
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            if (count != null)
              Text(
                count.toString(),
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: col),
              ),
          ],
        ),
      ),
    );
  }
}
