import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax/iconsax.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unicons/unicons.dart';

import '../res/custom_colors.dart';
import '../utils/authentication.dart';
import '../widgets/google_sign_in_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final items = List<String>.generate(10000, (i) => "Item $i");
  GoogleSignInAccount? _userObj;
  GoogleSignIn _googleSignIn = GoogleSignIn();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(
          top: 120.0,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Shake POP",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 42,
                    fontFamily: "sov_340",
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 8,
              ),
              BlinkText(
                "Shake To Play",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontFamily: "sov_340",
                ),
              ),
              SizedBox(
                height: 8,
              ),
              FutureBuilder(
                future: Authentication.initializeFirebase(context: context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error initializing Firebase');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return GoogleSignInButton();
                  }
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CustomColors.firebaseOrange,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
