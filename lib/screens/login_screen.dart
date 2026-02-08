import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool obscurePass = true;

  void login() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUser = prefs.getString('username');
    String? savedPass = prefs.getString('password');

    if (userController.text == savedUser && passController.text == savedPass) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()));
    } else {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text("خطأ", textAlign: TextAlign.right),
                content: const Text("اسم المستخدم أو كلمة المرور غير صحيحة",
                    textAlign: TextAlign.right),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("حسناً"))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.inventory_2, size: 100, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text("FLOW",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo)),
              const Text("تسجيل الدخول",
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 40),
              TextField(
                controller: userController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: "اسم المستخدم",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passController,
                obscureText: obscurePass,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: "كلمة المرور",
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                      icon: Icon(obscurePass
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => obscurePass = !obscurePass)),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: login,
                      child: const Text("تسجيل الدخول",
                          style: TextStyle(fontSize: 18)))),
              const SizedBox(height: 10),
              TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const SignUpScreen())),
                  child: const Text("ليس لديك حساب؟ سجل الآن")),
            ],
          ),
        ),
      ),
    );
  }
}
