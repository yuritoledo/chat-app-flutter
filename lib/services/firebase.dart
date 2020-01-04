import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignIn = GoogleSignIn();
final auth = FirebaseAuth.instance;

Future<Null> ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) user = await googleSignIn.signInSilently();
  if (user == null) user = await googleSignIn.signIn();

  if (await auth.currentUser() == null) {
    final credentials = await user.authentication;
    await auth.signInWithCredential(GoogleAuthProvider.getCredential(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    ));
  }
}

sendToFirebase({String text, String imageUrl}) async {
  await ensureLoggedIn();

  Firestore.instance.collection('messages').add({
    'senderName': googleSignIn.currentUser.displayName,
    'senderPhoto': googleSignIn.currentUser.photoUrl,
    'textMessage': text,
    'imageUrl': imageUrl
  });
}
