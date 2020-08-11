import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/text_composer.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  //funcao que será chamada ao digitar em enviar, em TextComposer
  //entre chaves para deixar opcional
  void _sendMessage({String text, File file}) async {

    Map<String, dynamic> data = {};

    //obtem ref do firebaseStorage
    // .child pode ser usado para criar pastas e para dar nome ao arquivo
    if(file != null) {
      StorageUploadTask task = FirebaseStorage.instance.ref().child(
        DateTime.now().millisecondsSinceEpoch.toString()
      ).putFile(file);


      StorageTaskSnapshot snapshot = await task.onComplete;
      String url = await snapshot.ref.getDownloadURL();
      data['imgUrl'] = url;
      print(url);
    }

    if(text != null) data['text'] = text;

    Firestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oi'),
        elevation: 0,
      ),
      body: TextComposer(_sendMessage),
    );
  }
}
