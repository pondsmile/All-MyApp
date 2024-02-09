import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:unicons/unicons.dart';

import '../screens/user_info_screen.dart';
import '../utils/authentication.dart';

class GoogleSignInButton extends StatefulWidget {
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton>
    with TickerProviderStateMixin {
  bool _isSigningIn = false;
  late AnimationController rippleController;
  late AnimationController scaleController;

  late Animation<double> rippleAnimation;
  late Animation<double> scaleAnimation;


  
  @override
  void initState() {
    super.initState();

    rippleController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    scaleController =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..addStatusListener((status) async {
            if (status == AnimationStatus.completed) {
              scaleController.reverse();

              setState(() {
                _isSigningIn = true;
              });
              User? user =
                  await Authentication.signInWithGoogle(context: context);

              setState(() {
                _isSigningIn = false;
              });

              if (user != null) {
                scaleController.forward();
                Future.delayed(Duration(milliseconds: 1000), () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => UserInfoScreen(
                        user: user,
                      ),
                    ),
                  );
                });
              }
            }
          });
    rippleAnimation =
        Tween<double>(begin: 180.0, end: 90.0).animate(rippleController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              rippleController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              rippleController.forward();
            }
          });
    scaleAnimation =
        Tween<double>(begin: 1.0, end: 30.0).animate(scaleController);

    rippleController.forward();

    ShakeDetector detector = ShakeDetector.waitForStart(onPhoneShake: () {
      print("object");
      scaleController.forward();
    });

    detector.startListening();
  }

  @override
  void dispose() {
    rippleController.dispose();
    scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _isSigningIn
            ? AvatarGlow(
                startDelay: Duration(milliseconds: 1000),
                glowColor: Colors.black,
                endRadius: 160.0,
                duration: Duration(milliseconds: 2000),
                repeat: true,
                showTwoGlows: true,
                repeatPauseDuration: Duration(milliseconds: 100),
                child: Container(
                  height: 100,
                  width: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(160.0)),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : AvatarGlow(
                startDelay: Duration(milliseconds: 1000),
                glowColor: Colors.black,
                endRadius: 160.0,
                duration: Duration(milliseconds: 2000),
                repeat: true,
                showTwoGlows: true,
                repeatPauseDuration: Duration(milliseconds: 100),
                child: MaterialButton(
                  onPressed: () async {},
                  elevation: 20.0,
                  shape: CircleBorder(),
                  child: AnimatedBuilder(
                    animation: rippleAnimation,
                    builder: (context, child) => Container(
                      width: rippleAnimation.value,
                      height: rippleAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.4)),
                        child: AnimatedBuilder(
                            animation: scaleAnimation,
                            builder: (context, child) => Transform.scale(
                                  scale: scaleAnimation.value,
                                  child: Container(
                                    margin: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black),
                                    child: Icon(
                                      UniconsLine.mobile_vibrate,
                                      size: 35,
                                    ),
                                  ),
                                )),
                      ),
                    ),
                  ),
                ),
              ));
  }
}
