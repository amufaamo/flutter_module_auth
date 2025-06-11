# 使い方
1. flutter create 〇〇 であらたにプロジェクトを作る
2. そのディレクトリの中にpackagesというディレクトリを作る
3. packagesの中にこのflutter_module_authを入れる
4. pubspec.ymlを以下のように編集


flutter:
  sdk: flutter

flutter_auth_ui:
  path: packages/flutter_module_auth

5. flutter pub add firebase_core firebase_auth
6. flutterfire configure
7. dartを以下のように書き換え
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- 1. exampleディレクトリに生成されたfirebase_options.dartをインポート ---
import 'firebase_options.dart';

// --- 2. 作成したパッケージをインポート ---
import 'package:flutter_auth_ui/flutter_auth_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // --- 3. exampleアプリとしてFirebaseを初期化 ---
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- 4. パッケージのテーマを使ってみる ---
    return MaterialApp(
      title: 'Flutter Auth UI Example',
      theme: AppTheme.lightTheme, // パッケージから提供されたテーマ
      darkTheme: AppTheme.darkTheme, // パッケージから提供されたテーマ
      themeMode: ThemeMode.system, // ここはシンプルにsystem固定などでもOK
      home: const AuthGate(),
    );
  }
}

// --- 5. 認証状態を監視して画面を振り分けるウィジェット ---
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 接続待機中はインジケーターを表示
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // ログインしている場合
        if (snapshot.hasData) {
          // ログイン後のホーム画面を表示（このHomeScreenはexample内に定義）
          return const HomeScreen();
        }

        // ログインしていない場合
        // --- 6. パッケージが提供するログイン画面を呼び出す！ ---
        return const LoginScreen();
      },
    );
  }
}


// --- 7. ログイン後の画面（exampleアプリ内に作るダミー画面） ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            Text(user?.email ?? 'No email found'),
          ],
        ),
      ),
    );
  }
}
```
# Flutter Auth UI

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Firebase Authenticationのための、美しくカスタマイズ可能なUIコンポーネントを提供するFlutterパッケージです。

このパッケージを使えば、ログイン、新規登録、パスワードリセットといった認証画面を、あなたのアプリに素早く組み込むことができます。

## ✨ 特徴

- ログイン画面 (`LoginScreen`)
- 新規登録画面 (`SignUpScreen`)
- パスワードリセット画面 (`ForgotPasswordScreen`)
- `AppTheme` による簡単なテーマのカスタマイズ

## 🚀 使い方

### 1. インストール
`pubspec.yaml` の `dependencies` に以下を追加してください。

```yaml
dependencies:
  flutter_auth_ui:
    git:
      url: [https://github.com/YOUR_USERNAME/flutter_auth_ui.git](https://github.com/YOUR_USERNAME/flutter_auth_ui.git)
      ref: main
````

（`YOUR_USERNAME` の部分は、あなたのGitHubユーザー名に置き換えてください）

### 2\. 基本的な使用例

`FirebaseAuth.instance.authStateChanges()` をリッスンし、認証状態に応じて画面を切り替えるのが基本的な使い方です。

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth_ui/flutter_auth_ui.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ログインしている場合
        if (snapshot.hasData) {
          return const HomeScreen(); // あなたのアプリのホーム画面
        }
        // ログインしていない場合
        return const LoginScreen(); // このパッケージが提供するログイン画面
      },
    );
  }
}
```

## ライセンス

このプロジェクトはMITライセンスです。

```

#### 2. `LICENSE` ファイルの作成
誰でも安心して使えるように、ライセンス（使用許諾）を明記します。`flutter_auth_ui` フォルダの直下に `LICENSE` という名前のファイル（拡張子なし）を作成し、以下の内容を貼り付けます。これは一般的な `MIT License` というもので、とても自由度の高いライセンスです。

```

MIT License

Copyright (c) 2025 YOUR\_NAME

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

````
（`2025 YOUR_NAME` の部分は、現在の年とあなたのお名前に書き換えてくださいね）

#### 3. `CHANGELOG.md` の更新
`flutter_auth_ui` フォルダの直下にある `CHANGELOG.md` を開き、最初のバージョン情報を記録します。

```markdown
## 1.0.0

- Initial version of the package.
- Provides LoginScreen, SignUpScreen, and ForgotPasswordScreen.
````
