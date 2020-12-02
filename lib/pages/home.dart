import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_auth/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

UserModel currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isAuth = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final userRef = Firestore.instance.collection("users");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print("Error Signing In: $err");
    });

    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }, onError: (err) {
      print("Error Signing In: $err");
    });
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      print("User Signed -In $account");
      createUserInFirestore();
      setState(() {
        _isAuth = true;
      });
    } else {
      setState(() {
        _isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    //1) Check if user exists in user collection in database according to their id
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.document(user.id).get();

    if (!doc.exists) {
      //2) If the user doesn't exist then create it.
      userRef.document(user.id).setData({
        "id": user.id,
        "displayName": user.displayName,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "timestamp": DateTime.now()
      });

      doc = await userRef.document(user.id).get();
    }

    currentUser = UserModel.fromDocument(doc);
    print(currentUser.displayName);
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return _isAuth == true ? buildAuthScreen() : buildUnAuthScreen();
  }

  Widget buildAuthScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              child: Text("LogOut"),
              onPressed: logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.green, Colors.orange]),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Google Auth",
              style: TextStyle(
                  fontSize: 50,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                            "https://lh3.googleusercontent.com/proxy/Y3obITkQLJhiIP7gxsmJeip8pKgEQYWLfs98_fj5a-LmtFyhqG878zGu2XEhpuJDmOGFlaRoLau4cegk5bIDMfcOFO7licTN2lyiRyi_goGTWYU6ePy_K0xTloVCIZ4Dh3mo0AgkmxB4rc00qT5gAwgbIXD8PLXr1lmi9P2oCWmQYmdo"),
                        fit: BoxFit.cover)),
              ),
              onTap: login,
            )
          ],
        ),
      ),
    );
  }
}
