 
 
import 'package:admin/homepage.dart';
 
 
 
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      home:Homepage(
         
      ),
    );
  }
}
