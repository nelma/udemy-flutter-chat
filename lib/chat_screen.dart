import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/text_composer.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  //funcao que será chamada ao digitar em enviar, em TextComposer
  void _sendMessage(String text) {
    Firestore.instance.collection("messages").add({
      'text': text
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oi'),
        elevation: 0,
      ),
      body: TextComposer(_sendMessage()),
    );
  }
}
