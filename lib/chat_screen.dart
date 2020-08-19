import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/text_composer.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //Fazer login com google
  final GoogleSignIn googleSignIn = GoogleSignIn();

  FirebaseUser _currentUser;


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    //sempre que houver alteração, atualiza user logado ou null
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      _currentUser = user;
    });
  }

  Future<FirebaseUser> _getUser() async {

    if(_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();

      //pegar dados do googleSingin e colocar no google singin authentication]
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      //conectando com firebase
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      //fazendo login no firebase
      //signInWithCredential funciona tanto para google, face entre outros. Muda apenas o Provider
      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);


      //pegando o user do firebase
      final FirebaseUser user = authResult.user;

      return user;

    } catch (error) {
      return null;
    }
  }

  //funcao que será chamada ao digitar em enviar, em TextComposer
  //entre chaves para deixar opcional
  void _sendMessage({String text, File file}) async {

    final FirebaseUser user = await _getUser();

    if(user == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Não foi possível fazer o login. Tente novamente'),
          backgroundColor: Colors.red,
        )
      );
    }

    Map<String, dynamic> data = {
      'uid': user.uid,
      'sendername': user.displayName,
      'senderPhotoUrl': user.photoUrl
    };

    //obtem ref do firebaseStorage
    // .child pode ser usado para criar pastas e para dar nome ao arquivo
    if (file != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(file);

      StorageTaskSnapshot snapshot = await task.onComplete;
      String url = await snapshot.ref.getDownloadURL();
      data['imgUrl'] = url;
      print(url);
    }

    if (text != null) data['text'] = text;

    Firestore.instance.collection("messages").add(data);
  }

  //StreamBuilder stream retorna sempre que houver alteração

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Oi'),
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      List<DocumentSnapshot> documents =
                          snapshot.data.documents.reversed.toList();

                      return ListView.builder(
                          itemCount: documents.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                              return ChatMessage(documents[index].data, true);
                          });
                  }
                },
              ),
            ),
            TextComposer(_sendMessage),
          ],
        ));
  }
}
