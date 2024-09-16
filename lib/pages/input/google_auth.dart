// ignore_for_file: prefer_final_fields, unused_local_variable, use_build_context_synchronously, prefer_const_constructors, empty_catches, prefer_function_declarations_over_variables, non_constant_identifier_names, avoid_types_as_parameter_names

import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_todo/pages/homepage.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_reccuring_reminder/pages/home/home_page.dart';
import 'package:flutter_reccuring_reminder/pages/home/signin.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthClass extends ChangeNotifier {
  // GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: [
  //     'email',
  //     'https://www.googleapis.com/auth/contacts.readonly',
  //   ],
  // );

  FirebaseAuth auth = FirebaseAuth.instance;
  bool circular = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final storage = new FlutterSecureStorage();
  // Future<void> googleSignIn(BuildContext context) async {
  //   try {
  //     GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
  //     if (googleSignInAccount != null) {
  //       GoogleSignInAuthentication googleSignInAuthentication =
  //           await googleSignInAccount.authentication;

  //       AuthCredential credential = GoogleAuthProvider.credential(
  //           idToken: googleSignInAuthentication.idToken,
  //           accessToken: googleSignInAuthentication.accessToken);
  //       try {
  //         UserCredential userCredential =
  //             await auth.signInWithCredential(credential);
  //         storeTokenAndData(userCredential);
  //         notifyListeners();
  //         Navigator.pushAndRemoveUntil(
  //             context,
  //             MaterialPageRoute(builder: (builder) => HomePage()),
  //             (route) => false);
  //       } catch (e) {
  //         final snackbar = SnackBar(content: Text(e.toString()));
  //         ScaffoldMessenger.of(context).showSnackBar(snackbar);
  //       }
  //     } else {
  //       final snackbar =
  //           SnackBar(content: Text("UNABLE TO SIGN IN WITH GOOGLE"));
  //       ScaffoldMessenger.of(context).showSnackBar(snackbar);
  //     }
  //   } catch (e) {
  //     final snackbar = SnackBar(content: Text(e.toString()));
  //     ScaffoldMessenger.of(context).showSnackBar(snackbar);
  //   }
  // }

  Future<void> storeTokenAndData(UserCredential userCredential) async {
    await storage.write(
        key: "token", value: userCredential.credential?.token.toString());
    await storage.write(
        key: "userCredential", value: userCredential.toString());
  }

  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  Future<void> logOut(BuildContext context) async {
    try {
      // await _googleSignIn.signOut();
      await auth.signOut();
      await storage.delete(key: "token");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => SignInPage()),
          (route) => false);
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  // Future<void> verifyPhoneNumber(
  //     String phoneNumber, BuildContext context, Function setData) async {
  //   PhoneVerificationCompleted verificationCompleted =
  //       (PhoneAuthCredential phoneAuthCredential) async {};
  //   PhoneVerificationFailed verificationFailed =
  //       (FirebaseAuthException exception) {
  //     showSnackbar(context, exception.toString());
  //   };
  //   PhoneCodeSent codeSent =
  //       (String verificationID, [int? forceResendingToken]) {
  //     showSnackbar(context, "Code sent on the phone number");
  //     setData(verificationID);
  //   };
  //   PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
  //       (String verificationID) {
  //     showSnackbar(context, "Timeout");
  //   };
  //   try {
  //     await auth.verifyPhoneNumber(
  //         phoneNumber: phoneNumber,
  //         verificationCompleted: verificationCompleted,
  //         verificationFailed: verificationFailed,
  //         codeSent: codeSent,
  //         codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  //   } catch (e) {
  //     showSnackbar(context, e.toString());
  //   }
  // }

  void showSnackbar(BuildContext context, String text) {
    final snackbar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  Future<void> signInwithPhoneNumber(
      String verificationId, String smsCode, BuildContext context) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      UserCredential userCredential =
          await auth.signInWithCredential(credential);
      storeTokenAndData(userCredential);
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (builder) => Home()), (route) => false);
      showSnackbar(context, "Logged In");
    } catch (e) {
      showSnackbar(context, e.toString());
    }
  }

  createUser() async {
    // setState(() {
    circular = true;
    notifyListeners();
    // });
    // try {
    firebase_auth.UserCredential userCredential = await firebase_auth
        .FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
    print(userCredential.user!.email);
    // setState(() {
    circular = false;
    // });
    // } catch (e) {

    // setState(() {
    circular = false;
    notifyListeners();
    // });
    // }
  }
}
