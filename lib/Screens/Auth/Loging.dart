import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../component/auth.dart'; // Custom authentication service
import '../../component/shimer.dart'; // Custom shimmer loading effect
import 'Register.dart';
import 'forgetPassword.dart';
import '../home.dart';

class Loging extends StatefulWidget {
  const Loging({super.key});

  @override
  State<Loging> createState() => _LogingState();
}

class _LogingState extends State<Loging> {
  bool _obscureText = true;
  bool isLoading = false;

  final TextEditingController _emailController =
      TextEditingController(text: 'vimukthi200020@gmail.com');
  final TextEditingController _passwordController =
      TextEditingController(text: '123456789');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF14142B),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              left: 20, right: 20, top: MediaQuery.of(context).size.height / 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Hero(
                tag: 'logo',
                child: Center(
                  child: Image.asset(
                    'assets/images/Lucid.png',
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.height / 5.3,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Logging',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 45),
              ),
              const SizedBox(height: 30),
              
              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Email",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter your Email Address",
                      suffixIcon: _emailController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _emailController.clear();
                              },
                            )
                          : null,
                      hintStyle: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                      filled: true,
                      fillColor: const Color(0xFF24263a),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 15),
                      enabledBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide:
                            const BorderSide(color: Color(0xFF73FA92), width: 1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide:
                            const BorderSide(color: Color(0xFF73FA92), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 3),
                    child: Text(
                      'Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: "Enter your Password",
                      hintStyle: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                      filled: true,
                      fillColor: const Color(0xFF24263a),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 15),
                      enabledBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide:
                            const BorderSide(color: Color(0xFF73FA92), width: 1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide:
                            const BorderSide(color: Color(0xFF73FA92), width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              // Forgot Password Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                             ForgotPasswordPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var tween = Tween(begin: 0.0, end: 1.0).chain(
                            CurveTween(curve: Curves.easeInOut),
                          );
                          return FadeTransition(
                            opacity: animation.drive(tween),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 700),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              
              // Loading Indicator or Login Button
              isLoading
                  ? Shimer.buildShimmerLoadingforPie()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        foregroundColor: const Color(0xFF14142B),
                        backgroundColor: const Color(0xFF73FA92),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          User? user = await Authservice().loginWithEmail(
                            _emailController.text,
                            _passwordController.text,
                            // context,
                          );
                          if (user != null) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setBool('isLoggedIn', true); // Save login status

                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation,
                                        secondaryAnimation) =>
                                    homePage(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  var tween = Tween(begin: 0.0, end: 1.0)
                                      .chain(CurveTween(curve: Curves.easeInOut));
                                  return FadeTransition(
                                    opacity: animation.drive(tween),
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 700),
                              ),
                            );
                          }
                        } catch (e) {
                          // Handle login error
                          print("Login Error: $e");
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: const Text('Login'),
                    ),
              const SizedBox(height: 20),
              
              // Register Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don’t have an account? ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 15,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const Register(),
                          transitionsBuilder: (context, animation,
                              secondaryAnimation, child) {
                            var tween = Tween(begin: 0.0, end: 1.0).chain(
                              CurveTween(curve: Curves.easeInOut),
                            );
                            return FadeTransition(
                              opacity: animation.drive(tween),
                              child: child,
                            );
                          },
                          transitionDuration:
                              const Duration(milliseconds: 700),
                        ),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Color(0xFF73FA92),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
