import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wokr4ututor/splash_page.dart';
import 'package:wokr4ututor/ui/mobile/mob_main.dart';
import 'package:wokr4ututor/ui/web/admin/adminlogin.dart';
import 'package:wokr4ututor/ui/web/login/login.dart';
import 'package:wokr4ututor/ui/web/search_tutor/find_tutors.dart';
import 'package:wokr4ututor/ui/web/signup/student_signup.dart';
import 'package:wokr4ututor/ui/web/signup/tutor_signup.dart';
import 'package:wokr4ututor/ui/web/web_main.dart';

import 'routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    //final args = settings.arguments;

    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case Routes.mobMain:
        return MaterialPageRoute(builder: (_) => const MobMainPage());

      case Routes.webMain:
        return MaterialPageRoute(builder: (_) => const WebMainPage());

      case Routes.tutorSignup:
        return MaterialPageRoute(builder: (_) => const TutorSignup());

      case Routes.studentSignup:
        return MaterialPageRoute(builder: (_) => const StudentSignup());

      case Routes.adminLogin:
        return MaterialPageRoute(builder: (_) => const AdminLoginPage());

      case Routes.tutorList:
        return MaterialPageRoute(builder: (_) => const FindTutor());

      case Routes.deleteAccount:
        return MaterialPageRoute(builder: (_) => const FindTutor());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Error'),
        ),
      );
    });
  }
}
