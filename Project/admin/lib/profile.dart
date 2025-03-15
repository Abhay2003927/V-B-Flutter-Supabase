import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Form(
        child:Column(
          children: [
            Text('Profile'),
            TextFormField(
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,

              ),
            )

          ],

      )),
    );
  }
}