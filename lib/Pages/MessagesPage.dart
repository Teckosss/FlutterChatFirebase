import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_firebase/Models/User.dart';

class MessagesPage extends StatefulWidget {
  MessagesPage({this.currentUser, this.userToChat});

  final User currentUser;
  final User userToChat;

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<Widget> _buildBody() {
    var listWidget = List<Widget>();
    var text = Container(
        child: Text(
            'Chat between ${widget.currentUser.username} and ${widget.userToChat.username}'));
    listWidget.add(text);
    return listWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.userToChat.username),
          automaticallyImplyLeading: true,
          leading: Platform.isAndroid
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context))
              : IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context))),
      body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: _buildBody(),
          )),
    );
  }
}
