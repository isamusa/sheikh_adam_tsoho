// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart'; // Import your main screen

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false; // For showing loading state

  void _submitAuthForm() async {
    print("AuthScreen: Authentication process started...");
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields!')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        print("AuthScreen: signInWithEmailAndPassword successful");
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        print("AuthScreen: createUserWithEmailAndPassword successful");
      }

      // On success, clear fields
      print("AuthScreen: Navigation to MainScreen initiated");
      _emailController.clear();
      _passwordController.clear();

      // Navigate to main screen after successful auth
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => MainScreen()), // Navigate to MainScreen
      );
      print("AuthScreen: Navigation should have occurred");
    } catch (error) {
      print("AuthScreen: Authentication error: ${error.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Use theme background color
      appBar: AppBar(
        backgroundColor: Theme.of(context)
            .appBarTheme
            .backgroundColor, // Theme-aware AppBar color
        title: Text(_isLogin ? 'Login' : 'Sign Up',
            style: Theme.of(context)
                .appBarTheme
                .titleTextStyle), // Theme-aware title text
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Removed hardcoded text color and used theme
              TextField(
                controller: _emailController,
                keyboardType:
                    TextInputType.emailAddress, // Specify email keyboard
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.labelMedium?.color),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.tealAccent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    // Add focused border color
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.labelMedium?.color),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).textTheme.bodyLarge?.color ??
                              Colors.tealAccent)),
                  focusedBorder: UnderlineInputBorder(
                    // Add focused border color
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.secondary),
                    )
                  : ElevatedButton(
                      onPressed: _submitAuthForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondary, // Use theme button color
                      ),
                      child: Text(_isLogin ? 'Login' : 'Sign Up',
                          style: TextStyle(color: Colors.white)),
                    ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin ? 'Create an account' : 'Already have an account?',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary), // Use theme text button color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
