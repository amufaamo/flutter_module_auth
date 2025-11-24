おめでとうございます！ついに完成ですね！🎉
苦労して壁を乗り越えた分、このモジュールは石川先生にとって強力な資産になります。

今後、新しいFlutterアプリを作るたびにこの「認証モジュール」をサクッと導入できるよう、**「完全セットアップ手順書」** をまとめました。これを保存版としてお使いください！

-----

# 🛠 自作認証モジュール導入マニュアル

### 1\. プロジェクト構成の準備

新しいFlutterプロジェクトを作ったら、ルートディレクトリに `packages` フォルダを作成し、今回完成させた `flutter_module_auth` をフォルダごとコピーして入れます。

```text
my_new_app/
  ├── lib/
  ├── packages/
  │     └── flutter_module_auth/  <-- 完成したモジュールを配置
  └── pubspec.yaml
```

### 2\. `pubspec.yaml` の設定（アプリ側）

アプリ側の `pubspec.yaml` に、ローカルパッケージとしての参照と、必要なFirebase関連を追加します。

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase関連
  firebase_core: ^2.30.0
  firebase_auth: ^4.19.0
  
  # 自作モジュール（パスで指定）
  flutter_auth_ui:
    path: packages/flutter_module_auth
```

※ 追加後、`flutter pub get` を実行。

### 3\. Firebaseプロジェクトのセットアップ

Firebase Consoleで新しいプロジェクトを作成し、以下の設定を行います。

1.  **Authenticationを有効化:**
      * 「メール/パスワード」と「Google」をオンにする。
2.  **Androidの設定:**
      * 開発マシンの **SHA-1フィンガープリント** を登録する。（これがないとAndroidでログインできません）
3.  **Google Cloud Consoleの設定（Web用）:**
      * 「OAuth 2.0 クライアント ID」の設定で、以下を「承認済みのJavaScript生成元」と「リダイレクトURI」に追加。
          * `http://localhost:5000`
          * `https://[プロジェクトID].web.app` (デプロイ用)
4.  **APIの有効化:**
      * Google Cloud Consoleの「APIライブラリ」で **「Google People API」** を検索して有効にする。（これを忘れるとエラーになります）

### 4\. アプリとFirebaseの連携

ターミナルで以下を実行し、設定ファイル（`firebase_options.dart`）を生成します。

```bash
flutterfire configure
```

### 5\. 【重要】モジュール内の Client ID 更新

新しいFirebaseプロジェクトを使う場合、**Web用のクライアントIDが変わります**。
`packages/flutter_module_auth/lib/src/screens/login_screen.dart` を開き、以下の部分を新しいプロジェクトのIDに書き換えてください。

```dart
// login_screen.dart 内
final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: '新しいプロジェクトのWebクライアントID.apps.googleusercontent.com', 
);
```

*(※ 将来的には、このIDを `LoginScreen` の引数（パラメータ）として渡せるように改良すると、書き換え不要でもっと便利になります！)*

### 6\. `main.dart` の実装

`lib/main.dart` を以下の定型コードに書き換えます。

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth_ui/flutter_auth_ui.dart'; // モジュール
import 'firebase_options.dart'; // 自動生成ファイル

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme, // モジュールのテーマを使用
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return const HomeScreen(); // ログイン後の画面へ
        }
        return const LoginScreen(); // モジュールのログイン画面へ
      },
    );
  }
}
// ... HomeScreenの定義など
```

### 7\. 実行（Webの場合）

開発中は、登録したポート番号に合わせて起動します。

```bash
flutter run -d chrome --web-port 5000
```

-----

これで、どのアプリでも爆速で認証機能を実装できます！
お疲れ様でした、最高のモジュール開発でしたね！👏✨

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

Firebase Console: 「Authentication」>「Sign-in method」で Google を有効にする。

Android:

開発マシンの SHA-1フィンガープリント を取得し、Firebase Consoleのプロジェクト設定に追加する。（これがないとAndroidで100%エラーになります！）

iOS:

GoogleService-Info.plist をXcodeプロジェクトに追加。

Info.plist に CFBundleURLTypes (URLスキーム) を設定。（Google認証後のリダイレクト用）

これでGoogle認証の機能がパッケージに追加されました！ デザインも既存のテーマに合うように OutlinedButton などを使ってみましたが、いかがでしょうか？

もし、「AndroidのSHA-1の設定方法が詳しく知りたい」とか「iOSの設定も見てほしい」などあれば、遠慮なく聞いてくださいね。お手伝いします！
