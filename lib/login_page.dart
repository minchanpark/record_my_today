import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String uid;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? currentUser = FirebaseAuth.instance.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) return Future.error('No user selected');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      await _firestore.collection('user').doc(currentUser.uid).set({
        'email': currentUser.email,
        'name': currentUser.displayName,
        'uid': currentUser.uid,
      });
    }

    return userCredential;
  }

  Future<UserCredential> signInAnonymously() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      currentUser = userCredential.user;
      await _firestore.collection('user').doc(currentUser!.uid).set({
        'uid': currentUser!.uid,
      });
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: height * (200 / 852)),
          Center(
            child: Text(
              'Record My day',
              style: TextStyle(
                fontSize: width * (18 / 320),
                fontFamily: 'Ribeye',
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: height * (200 / 852)),
          SizedBox(
            width: 150,
            height: 40,
            child: ElevatedButton(
              style: const ButtonStyle(
                elevation: MaterialStatePropertyAll(0),
                backgroundColor: MaterialStatePropertyAll(
                  Color.fromRGBO(1, 1, 1, 0.1),
                ),
              ),
              child: Text(
                'Google login',
                style: TextStyle(
                  fontSize: width * (12 / 320),
                  fontFamily: 'Ribeye',
                  color: Color.fromARGB(255, 45, 45, 45),
                ),
              ),
              onPressed: () async {
                try {
                  await signInWithGoogle();

                  Navigator.pushNamed(context, '/record_my_day');
                } catch (e) {
                  print('Error signing in with Google: $e');
                }
              },
            ),
          ),
          SizedBox(height: height * (10 / 852)),
          ElevatedButton(
            style: const ButtonStyle(
              elevation: MaterialStatePropertyAll(0),
              backgroundColor: MaterialStatePropertyAll(
                Color.fromRGBO(1, 1, 1, 0.1),
              ),
            ),
            onPressed: () async {
              await signInAnonymously();

              Navigator.pushNamed(context, '/record_my_day');
            },
            child: Text(
              'Guest login',
              style: TextStyle(
                fontSize: width * (12 / 320),
                fontFamily: 'Ribeye',
                color: Color.fromARGB(255, 45, 45, 45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
