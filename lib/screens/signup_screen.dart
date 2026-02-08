import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final userC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool _isObscure = true;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', userC.text);
      await prefs.setString('email', emailC.text);
      await prefs.setString('password', passC.text);
      
      
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إنشاء حساب جديد"), 
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              
              
              const Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "انضم إلى ",
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          TextSpan(
                            text: "FLOW",
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color:Colors.indigo),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "يرجى إدخال بياناتك لإنشاء حساب إداري",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              
              TextFormField(
                controller: userC, 
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: "اسم المستخدم", 
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "الرجاء إدخال اسم المستخدم" : null,
              ),
              const SizedBox(height: 15),
              
              
              TextFormField(
                controller: emailC,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "البريد الإلكتروني", 
                  hintText: "example@gmail.com", 
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => !v!.endsWith("@gmail.com") 
                    ? "يجب أن ينتهي البريد بـ @gmail.com" 
                    : null,
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: passC,
                obscureText: _isObscure,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: "كلمة المرور", 
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility), 
                    onPressed: () => setState(() => _isObscure = !_isObscure)
                  ),
                ),
                validator: (v) => v!.length < 6 ? "كلمة المرور يجب أن تكون 6 خانات على الأقل" : null,
              ),
              const SizedBox(height: 40),
              
              
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _register, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("إنشاء الحساب", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("لديك حساب بالفعل؟ سجل دخولك"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}