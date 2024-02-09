import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecoeco/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shake/shake.dart';
import 'package:vibration/vibration.dart';

import '../res/custom_colors.dart';
import '../utils/authentication.dart';
import 'package:flutter/services.dart';
import '../widgets/app_bar_title.dart';
import 'sign_in_screen.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late User _user;
  bool _isSigningOut = false;
  bool _isFirst = false;
  int phoneShakes = 0;

  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  CollectionReference _userScoreCollection =
      FirebaseFirestore.instance.collection("UserScore");
  late DocumentSnapshot snapshot;
  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void setFirstData() async {
    FirebaseFirestore.instance
        .collection('UserScore')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        print(element.id);
        if (element.id == _user!.uid) {
          print(element.id);
        }
      });
    });
  }

  void setData() async {
    final CollectionReference firestoreInstance =
        FirebaseFirestore.instance.collection('UserScore');
    await firestoreInstance.doc(_user.uid).get().then((event) async {
      setState(() {
        phoneShakes = event['score'] + 1;
        // print((event.data() as dynamic)['score']);
      });
    });
    await _userScoreCollection.doc(_user.uid).set({
      "uid": _user.uid,
      "name": _user.displayName,
      "email": _user.email,
      "imgUrl": _user.photoURL,
      "score": phoneShakes,
    });
  }

  void getData() async {
    final CollectionReference firestoreInstance =
        FirebaseFirestore.instance.collection('UserScore');
    await firestoreInstance.doc(_user.uid).get().then((event) async {
      setState(() {
        _isFirst = event['_isFirst'];
        phoneShakes = event['score'];
        print((event.data() as dynamic)['score']);
      });
    });
  }

  @override
  void initState() {
    super.initState();

    // ShakeDetector detector = ShakeDetector.waitForStart(onPhoneShake: () async {
    //   await _userScoreCollection.doc(_user.uid).set({
    //     "uid": _user.uid,
    //     "name": _user.displayName,
    //     "email": _user.email,
    //     "imgUrl": _user.photoURL,
    //     "score": phoneShakes,
    //   });

    //   Vibration.vibrate(
    //     pattern: [0, 10],
    //   );
    // });

    // detector.startListening();

    _user = widget._user;
  }

  @override
  Widget build(BuildContext context) {
    final items = List<String>.generate(10000, (i) => "Item $i");
    getData();
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "No.1 $phoneShakes",
                    style:
                        TextStyle(color: Colors.black, fontFamily: "sov_340"),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  _user.photoURL != null
                      ? GestureDetector(
                          onTap: () {
                            setData();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            20.0)), //this right here
                                    child: Container(
                                      height: 300,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            _user.photoURL != null
                                                ? ClipOval(
                                                    child: Material(
                                                      color: CustomColors
                                                          .firebaseGrey
                                                          .withOpacity(0.3),
                                                      child: Image.network(
                                                        _user.photoURL!,
                                                        fit: BoxFit.fitHeight,
                                                      ),
                                                    ),
                                                  )
                                                : ClipOval(
                                                    child: Material(
                                                      color: CustomColors
                                                          .firebaseGrey
                                                          .withOpacity(0.3),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 60,
                                                          color: CustomColors
                                                              .firebaseGrey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              _user.displayName!,
                                              style: TextStyle(
                                                color:
                                                    CustomColors.firebaseYellow,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            _isSigningOut
                                                ? const CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  )
                                                : ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                        Colors.redAccent,
                                                      ),
                                                      shape:
                                                          MaterialStateProperty
                                                              .all(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      setState(() {
                                                        _isSigningOut = true;
                                                      });
                                                      await Authentication
                                                          .signOut(
                                                              context: context);
                                                      setState(() {
                                                        _isSigningOut = false;
                                                      });

                                                      // ignore: use_build_context_synchronously
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const HomePage(),
                                                              maintainState:
                                                                  true),
                                                          (Route<dynamic>
                                                                  route) =>
                                                              false);
                                                      // Navigator.of(context)
                                                      //     .pushReplacement(
                                                      //         _routeToSignInScreen());
                                                    },
                                                    child: const Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 8.0,
                                                          bottom: 8.0),
                                                      child: Text(
                                                        'ออกจากระบบ',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          letterSpacing: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: ClipOval(
                            child: Material(
                              color: CustomColors.firebaseGrey.withOpacity(0.3),
                              child: Image.network(
                                _user.photoURL!,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        )
                      : ClipOval(
                          child: Material(
                            color: CustomColors.firebaseGrey.withOpacity(0.3),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: CustomColors.firebaseGrey,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "อันดับสูงสุด",
                        style: TextStyle(
                            color: Colors.black, fontFamily: "sov_340"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text("คะแนนของคุณ",
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                              fontFamily: "sov_340")),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "$phoneShakes",
                          style: TextStyle(
                              fontSize: 42,
                              fontFamily: "sov_340",
                              color: Colors.black),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _isFirst == false
                          ? Container(
                              child: ElevatedButton(
                                  onPressed: () {
                                    setFirstData();
                                  },
                                  child: Text("press")),
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
                                child: Container(
                                    width: 100.0,
                                    height: 100.0,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius:
                                            BorderRadius.circular(160.0)),
                                    child: Icon(
                                      Iconsax.microphone,
                                      color: Colors.white,
                                      size: 50,
                                    )),
                              ),
                            )
                    ]),
              ),
            ),
          ),
        ));
  }
}
