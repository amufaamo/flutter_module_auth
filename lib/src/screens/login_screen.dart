// lib/src/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ⬅️ Web判定(kIsWeb)のために追加
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_sign_in/google_sign_in.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final String emailLinkUrl;

  const LoginScreen({
    super.key,
    required this.emailLinkUrl,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;
  bool _isEmailSent = false;

  // --- メールリンクでのログイン（送信） ---
  Future<void> _sendLoginLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address.';
      });
      return;
    }

    try {
      setState(() {
        _errorMessage = '';
        _isLoading = true;
      });

      // ActionCodeSettingsの設定
      // Webのみの運用の場合は、Android/iOSの設定を外すことでFDL(Firebase Dynamic Links)のエラーを回避できる場合があります。
      var acs = ActionCodeSettings(
        // URL: 認証完了後に開くURL。HostingのURLに合わせます。
        url: widget.emailLinkUrl,
        handleCodeInApp: true,
        // Webのみの場合は以下をコメントアウトまたは削除
        // iOSBundleId: 'com.example.testAuthApp',
        // androidPackageName: 'com.example.test_auth_app',
        // androidInstallApp: true,
        // androidMinimumVersion: '12',
      );

      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: acs,
      );

      // メールアドレスをローカルに保存（リンク踏んだ時に使う）
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isEmailSent = true;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message ?? "An error occurred";
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  // --- 🆕 Googleログイン（Web対応・修正版） ---
  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _errorMessage = '';
        _isLoading = true;
      });

      if (kIsWeb) {
        // 🌐【Webの場合】
        // ポップアップブロックやdeprecatedエラーを回避するため、
        // google_sign_in パッケージではなく、Firebase標準のポップアップを使います。
        GoogleAuthProvider authProvider = GoogleAuthProvider();

        // 必要に応じてログインのヒントなどを設定できます
        authProvider.setCustomParameters({'login_hint': 'user@example.com'});

        await _auth.signInWithPopup(authProvider);
      } else {
        // 📱【スマホアプリの場合】
        // Android/iOSは従来通り GoogleSignIn パッケージを使います。
        // クライアントIDは google-services.json / GoogleService-Info.plist から
        // 自動的に読み込まれるため、ここに書かなくても大丈夫です。
        // final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
        // final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        throw UnimplementedError('Google Sign In temporarily disabled');

        // if (googleUser == null) {
        //   // キャンセルされた場合
        //   setState(() => _isLoading = false);
        //   return;
        // }

        // // 認証情報を取得
        // final GoogleSignInAuthentication googleAuth =
        //     await googleUser.authentication;

        // // Firebase用クレデンシャル作成
        // final OAuthCredential credential = GoogleAuthProvider.credential(
        //   accessToken: null,
        //   idToken: googleAuth.idToken,
        // );

        // // Firebaseにサインイン
        // await _auth.signInWithCredential(credential);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message ?? "Google Sign-In failed";
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Use Theme Primary Color
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor =
        const Color(0xFF1E1E1E); // Slightly lighter dark background for card
    final inputFillColor = const Color(0xFF2C2C2C);

    return Scaffold(
      backgroundColor: Colors.black, // Dark background for the whole page
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420), // Slightly wider
            child: Card(
              elevation: 8, // Add some shadow for depth
              shadowColor: Colors.black54,
              color: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24), // More rounded
                side: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 40.0, horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // 3. Title Update
                    Text(
                      'Get Started',
                      style: GoogleFonts.notoSans(
                        fontSize: 32, // Larger font
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40), // More space

                    // --- Google Login (Moved to Top) ---
                    _isLoading
                        ? const SizedBox
                            .shrink() // Hide if loading (optional, or disable)
                        : OutlinedButton(
                            onPressed: _isLoading ? null : _signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors
                                  .white, // White background for Google button
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              foregroundColor: Colors.black, // Text color black
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://fonts.gstatic.com/s/i/productlogos/googleg/v6/24px.svg',
                                  height: 24,
                                  width: 24,
                                  // No color filter to show original Google colors
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.login,
                                          color: Colors.blue),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Sign in with Google',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                    if (!_isLoading) ...[
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade700)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OR",
                              style: GoogleFonts.notoSans(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade700)),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],

                    if (_isEmailSent) ...[
                      Icon(Icons.mark_email_read,
                          size: 72, color: primaryColor), // Larger icon
                      const SizedBox(height: 24),
                      Text(
                        'Login link sent!',
                        style: GoogleFonts.notoSans(
                          fontSize: 24, // Larger
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Check your email (${_emailController.text}) and click the link to sign in.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSans(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEmailSent = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Back to Login',
                          style: GoogleFonts.notoSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else ...[
                      // --- Email Form ---
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _emailController,
                        builder: (context, value, child) {
                          final isEmailValid = value.text.contains('@') &&
                              value.text.contains('.');
                          return TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: GoogleFonts.notoSans(
                                  color: Colors.grey.shade400),
                              hintText: 'name@example.com',
                              hintStyle: GoogleFonts.notoSans(
                                  color: Colors.grey.shade600),
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: Colors.white70),
                              suffixIcon: isEmailValid
                                  ? Icon(Icons.check_circle,
                                      color: primaryColor)
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: primaryColor, width: 2),
                              ),
                              filled: true,
                              fillColor: inputFillColor,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                            ),
                            style: GoogleFonts.notoSans(
                              color: Colors.white,
                              fontSize: 18, // Larger input text
                            ),
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isLoading,
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      Text(
                        'No password required. We will send you a login link.',
                        style: GoogleFonts.notoSans(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.left,
                      ),

                      const SizedBox(height: 32),

                      // --- Error Message ---
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Text(
                            _errorMessage,
                            style: GoogleFonts.notoSans(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // --- Send Link Button ---
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _sendLoginLink,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20), // Taller button
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                'Send Login Link',
                                style: GoogleFonts.notoSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ],
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
