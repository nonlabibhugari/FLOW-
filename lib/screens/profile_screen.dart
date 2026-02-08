import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  File? _imageFile;
  bool _isEditing = false;
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('email') ?? "";
      phoneController.text = prefs.getString('phone') ?? "";
      passwordController.text = prefs.getString('password') ?? "";
      String? path = prefs.getString('profile_image');
      if (path != null) _imageFile = File(path);
    });
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', emailController.text);
    await prefs.setString('phone', phoneController.text);
    await prefs.setString('password', passwordController.text);
    if (_imageFile != null) await prefs.setString('profile_image', _imageFile!.path);
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), backgroundColor: Colors.indigo,
        actions: [IconButton(icon: Icon(_isEditing ? Icons.check : Icons.edit), onPressed: () => _isEditing ? _saveData() : setState(() => _isEditing = true))]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                if(!_isEditing) return;
                final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (img != null) setState(() => _imageFile = File(img.path));
              },
              child: CircleAvatar(radius: 60, backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
              child: _imageFile == null ? const Icon(Icons.camera_alt, size: 40) : null),
            ),
            const SizedBox(height: 25),
            _buildField(Icons.email, "Email", emailController),
            const SizedBox(height: 15),
            _buildField(Icons.phone, "Phone", phoneController),
            const SizedBox(height: 15),
            _buildField(Icons.lock, "Password", passwordController, isPass: true),
          ],
        ),
      ),
    );
  }

  Widget _buildField(IconData icon, String label, TextEditingController controller, {bool isPass = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: _isEditing 
        ? TextFormField(
            controller: controller, 
            obscureText: isPass ? _obscurePass : false,
            decoration: InputDecoration(
              labelText: label,
              suffixIcon: isPass ? IconButton(icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off), 
              onPressed: () => setState(()=> _obscurePass = !_obscurePass)) : null))
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(isPass ? "********" : controller.text, style: const TextStyle(fontSize: 16)),
          ]),
    );
  }
}