import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:can_scan/Pages/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  _login createState() => _login();
}

class _login extends State<Login> {
  // Variables to store input
  String email = '';
  String password = '';
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Login', style: TextStyle(fontFamily: 'BaskervvilleSC')),
      ),

      bottomNavigationBar: BottomAppBar(
        elevation: 5,
        shape: const CircularNotchedRectangle(),
        color: Color(0xFFAD88C6),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                // Add navigation to signup page here
                // For example:
                // Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
              },
              child: Text(
                "Don't Have An Account? Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ),

      body:
      Column(
        mainAxisAlignment: MainAxisAlignment.start ,
        children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 25)),
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: Image.asset('assets/floating_icon.png',height: 130,width: 130)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                // Add login logic here
                print('Email: $email');
                print('Password: $password');

                // Example of how to use the stored values:
                // performLogin(email, password);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                child: Text('Login'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Example login function
  void performLogin(String email, String password) async {
    try {
      // Add your login API call here
      // Example:
      // final response = await http.post(
      //   Uri.parse('your-api-endpoint'),
      //   body: {
      //     'email': email,
      //     'password': password,
      //   },
      // );

      // if (response.statusCode == 200) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => HomePage()),
      //   );
      // }
    } catch (e) {
      print('Error during login: $e');
    }
  }
}