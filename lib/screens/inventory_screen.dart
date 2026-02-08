import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../controller/db_helper.dart'; 
import '../models/product_model.dart'; 

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final nameC = TextEditingController();
  final qtyC = TextEditingController();
  File? selectedImage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _updateDashboardCount() async {
    final prefs = await SharedPreferences.getInstance();
    final products = await DbHelper.getProducts();
    await prefs.setInt('products_count', products.length);
  }

  void addProduct() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("إضافة منتج جديد", textAlign: TextAlign.right),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, decoration: const InputDecoration(labelText: "اسم المنتج"), textAlign: TextAlign.right),
              TextField(controller: qtyC, decoration: const InputDecoration(labelText: "الكمية"), keyboardType: TextInputType.number, textAlign: TextAlign.right),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (img != null) setState(() => selectedImage = File(img.path));
                },
                icon: const Icon(Icons.image),
                label: const Text("اختيار صورة"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              if (nameC.text.isNotEmpty && qtyC.text.isNotEmpty) {
                
                await DbHelper.insertProduct(Product(
                  name: nameC.text, 
                  quantity: int.tryParse(qtyC.text) ?? 0,
                  supplier: "المورد الرئيسي",
                  imagePath: selectedImage?.path ?? "",
                  status: "متوفر"
                ));

                
                await _updateDashboardCount();

            
                nameC.clear();
                qtyC.clear();
                selectedImage = null;
                
                Navigator.pop(ctx);
                setState(() {}); 
              }
            },
            child: const Text("حفظ"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المخزن"), centerTitle: true, backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton(onPressed: addProduct, backgroundColor: Colors.indigo, child: const Icon(Icons.add, color: Colors.white)),
      body: FutureBuilder<List<Product>>(
        future: DbHelper.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد منتجات حالياً"));
          }

          final prods = snapshot.data!;
          return ListView.builder(
            itemCount: prods.length,
            itemBuilder: (context, i) => ListTile(
              leading: prods[i].imagePath.isNotEmpty 
                  ? Image.file(File(prods[i].imagePath), width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.inventory_2, color: Colors.indigo),
              title: Text(prods[i].name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("الكمية: ${prods[i].quantity}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await DbHelper.deleteProduct(prods[i].id!);
                  await _updateDashboardCount(); 
                  setState(() {});
                },
              ),
            ),
          );
        },
      ),
    );
  }
}