// lib/src/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  String _message = '';
  bool _isLoading = false;
  bool _isSuccess = false;

  Future<void> _sendPasswordResetEmail() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _message = 'Please enter your email address.';
        _isSuccess = false;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _message = '';
    });
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _message = 'Password reset email sent. Please check your inbox.';
        _isSuccess = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_message),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      // Make Firebase error messages user-friendly
      String displayMessage;
      switch (e.code) {
        case 'invalid-email':
          displayMessage = 'The email address format is invalid.';
          break;
        case 'user-not-found':
          displayMessage = 'No user found for that email.';
          break;
        case 'too-many-requests':
          displayMessage = 'Too many requests. Try again later.';
          break;
        default:
          displayMessage = e.message ?? 'An error occurred.';
      }
      setState(() {
        _message = displayMessage;
        _isSuccess = false;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'An unexpected error occurred.';
        _isSuccess = false;
        _isLoading = false;
      });
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//        title: const Text('Reset Password'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Enter your registered email address. We\'ll send you a link to reset your password.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 24),
                    if (_message.isNotEmpty && !_isLoading && !_isSuccess) // Display error here, success is shown in SnackBar
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _sendPasswordResetEmail,
                            child: const Text('Send Link', style: TextStyle(fontSize: 16)),
                          ),
                    const SizedBox(height: 12),
                     TextButton(
                       onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                       child: const Text('Back to Log in'),
                     )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}