import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logic_networks/screens/about_screen.dart';
import 'package:logic_networks/services/database_service.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/author_dashboard_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/update_profile_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/error_screen.dart';
import 'screens/book_details_screen.dart';
import 'screens/book_read_screen.dart';
import 'screens/book_review_screen.dart';
import 'screens/author_profile_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/author_dashboard_screen.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      print('Flutter Error: ${details.exceptionAsString()}');
      print('Flutter Error Stack: ${details.stack}');
    };

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(MyApp());
    } catch (e) {
      print('Error initializing Firebase: $e');
      runApp(ErrorApp(errorMessage: 'Firebase başlatılamadı: $e'));
    }
  }, (error, stack) {
    print('Unhandled Exception: $error');
    print('Stack Trace: $stack');
  });
}

class ErrorApp extends StatelessWidget {
  final String errorMessage;

  const ErrorApp({Key? key, required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hata: $errorMessage'),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        title: 'Book App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthenticationWrapper(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/home':
              return MaterialPageRoute(builder: (context) => HomeScreen());
            case '/login':
              return MaterialPageRoute(builder: (context) => LoginScreen());
            case '/register':
              return MaterialPageRoute(builder: (context) => RegisterScreen());
            case '/author-dashboard':
              return MaterialPageRoute(
                  builder: (context) => AuthorDashboardScreen());
            case '/user-dashboard':
              return MaterialPageRoute(
                  builder: (context) => UserDashboardScreen());
            case '/admin-dashboard':
              return MaterialPageRoute(
                  builder: (context) => AdminDashboardScreen());
            case '/forgot-password': // Yeni rota
              return MaterialPageRoute(
                  builder: (context) => ForgotPasswordScreen());
            case '/profile':
              return _handleProfileRoute(context);
            case '/update-profile':
              return _handleUpdateProfileRoute(context);
            case '/about':
              return MaterialPageRoute(builder: (context) => AboutScreen());
            case '/book-details':
              return _handleBookDetailsRoute(settings);
            case '/book-read':
              return _handleBookReadRoute(settings);
            case '/book-review':
              return _handleBookReviewRoute(settings);
            case '/author-profile':
              return _handleAuthorProfileRoute(settings);
            default:
              return MaterialPageRoute(
                  builder: (context) =>
                      ErrorScreen(errorMessage: 'Sayfa bulunamadı'));
          }
        },
      ),
    );
  }

  MaterialPageRoute _handleProfileRoute(BuildContext context) {
    return MaterialPageRoute(
      builder: (context) {
        final authService = Provider.of<AuthService>(context, listen: false);
        final userId = authService.currentUser?.uid;
        if (userId == null) {
          return ErrorScreen(errorMessage: 'Kullanıcı ID\'si eksik.');
        }
        return ProfileScreen(userId: userId);
      },
    );
  }

  MaterialPageRoute _handleUpdateProfileRoute(BuildContext context) {
    return MaterialPageRoute(
      builder: (context) {
        final authService = Provider.of<AuthService>(context, listen: false);
        final userId = authService.currentUser?.uid;
        if (userId == null) {
          return ErrorScreen(errorMessage: 'Kullanıcı ID\'si eksik.');
        }
        return EditProfileScreen(userId: userId);
      },
    );
  }

  MaterialPageRoute _handleBookDetailsRoute(RouteSettings settings) {
    final bookId = settings.arguments as String?;
    if (bookId == null) {
      return MaterialPageRoute(
          builder: (context) =>
              ErrorScreen(errorMessage: 'Kitap ID\'si eksik.'));
    }
    return MaterialPageRoute(
        builder: (context) => BookDetailsScreen(bookId: bookId));
  }

  MaterialPageRoute _handleBookReadRoute(RouteSettings settings) {
    final bookId = settings.arguments as String?;
    if (bookId == null) {
      return MaterialPageRoute(
          builder: (context) =>
              ErrorScreen(errorMessage: 'Kitap ID\'si eksik.'));
    }
    return MaterialPageRoute(
        builder: (context) => BookReadScreen(bookId: bookId));
  }

  MaterialPageRoute _handleBookReviewRoute(RouteSettings settings) {
    final bookId = settings.arguments as String?;
    if (bookId == null) {
      return MaterialPageRoute(
          builder: (context) =>
              ErrorScreen(errorMessage: 'Kitap ID\'si eksik.'));
    }
    return MaterialPageRoute(
        builder: (context) => BookReviewScreen(bookId: bookId));
  }
}

MaterialPageRoute _handleAuthorProfileRoute(RouteSettings settings) {
  final userId = settings.arguments as String?;
  if (userId == null) {
    return MaterialPageRoute(
        builder: (context) => ErrorScreen(errorMessage: 'Yazar ID\'si eksik.'));
  }
  return MaterialPageRoute(
      builder: (context) => AuthorProfileScreen(userId: userId));
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user != null) {
      return FutureBuilder<String?>(
        future: authService.getUserRole(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error fetching user role: ${snapshot.error}');
            return ErrorScreen(errorMessage: 'Kullanıcı rolü alınamadı');
          } else {
            final role = snapshot.data ?? 'user';
            switch (role) {
              case 'admin':
                return AdminDashboardScreen();
              case 'author':
                return AuthorDashboardScreen();
              case 'user':
              default:
                return UserDashboardScreen();
            }
          }
        },
      );
    } else {
      return LoginScreen();
    }
  }
}
