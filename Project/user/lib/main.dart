
import 'package:flutter/material.dart';
 
 import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/homepage.dart';
 
import 'package:user/skipscreen.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://vnhidcntaifzfvgtztkn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZuaGlkY250YWlmemZ2Z3R6dGtuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcxNzY1MDksImV4cCI6MjA1Mjc1MjUwOX0.CagAb3Yg4dWdXiWBq4CEpff5xRyhvhjWbEK6nbIwWT8',
  );
  runApp(MainApp());
}

final supabase = Supabase.instance.client;
 
 
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
    home: AuthWrapper(), // Use AuthWrapper as the home widget
    );
  }
}

class AuthWrapper extends StatelessWidget {

  const AuthWrapper({super.key});



  @override

  Widget build(BuildContext context) {

    // Check if the user is logged in

    final session = supabase.auth.currentSession;



    // Navigate to the appropriate screen based on the authentication state

    if (session != null) {

      return  Homepagescreen();// Replace with your home screen widget

    } else {

      return   Skipscreen();// Replace with your auth page widget

    }

  }

}

