
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  DocumentReference _userRef;
  Future<bool> login() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    _user = (await _auth.signInWithCredential(credential)).user;
    
    if(_user == null) return false;
    _userRef = Firestore.instance.collection('user').document(_user.uid);
    _userRef.setData({
      'uid':_user.uid,
      'name': _user.displayName,
      'photo': _user.photoUrl,
      'call': _user.phoneNumber,
      'email':_user.email,
    });
    return true;
  }

  void logout(){
    _googleSignIn.disconnect();
    _user = null;
  }
  DocumentReference getRef(){
    return _userRef;
  }
  String getName() {
    return _user.displayName;
  }
  String getUid(){
    return _user.uid;
  }
  String getPhoto() {
    return _user.photoUrl;
  }
  String getPhoneNumber(){
    return _user.phoneNumber;
  }
  String getEmail(){
    return _user.email;
  }
}

final Store user = Store();