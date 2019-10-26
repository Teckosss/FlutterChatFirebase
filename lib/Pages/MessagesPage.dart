import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_firebase/Helper/MessageHelper.dart';
import 'package:flutter_chat_firebase/Models/Message.dart';
import 'package:flutter_chat_firebase/Models/User.dart';
import 'package:flutter_chat_firebase/const.dart';
import 'package:intl/intl.dart';

class MessagesPage extends StatefulWidget {
  MessagesPage({this.currentUser, this.userToChat, this.roomId});

  final User currentUser;
  final User userToChat;
  final String roomId;

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _sendMessage(String messageText) {
    if (messageText.trim() != '') {
      _textEditingController.clear();
      MessageHelper().createNewMessage(
          widget.roomId, messageText, widget.currentUser.userId);
    }
  }

  Widget _displayBottomBar() {
    return Container(
      child: Row(
        children: <Widget>[
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child:
                  IconButton(icon: Icon(Icons.add_a_photo), onPressed: () {}),
            ),
            color: Colors.white,
          ),
          Flexible(
              child: Container(
                  child: TextField(
            controller: _textEditingController,
            decoration:
                InputDecoration.collapsed(hintText: 'Type your message'),
          ))),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _sendMessage(_textEditingController.text),
              ),
            ),
            color: Colors.white,
          )
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget _displayListView() {
    return Flexible(
        child: StreamBuilder(
      stream: MessageHelper().getAllMessagesInRoom(widget.roomId),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error retrieving data'));
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          default:
            if (snapshot.data.documents.length > 0) {
              return ListView.builder(
                shrinkWrap: true,
                reverse: true,
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) => _buildItem(index,
                    Message.fromMap(snapshot.data.documents[index].data)),
                itemCount: snapshot.data.documents.length,
              );
            } else {
              return Center(
                child: Text('Start the conversation!'),
              );
            }
        }
      },
    ));
  }

  Widget _buildItem(int index, Message message) {
    //print("BuildItem message data : $message");
    if (widget.currentUser.userId == message.fromUser) {
      // Current user is sender, need to align RIGHT
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                flex: 3,
                child: Container(),
              ),
              Flexible(
                  flex: 7,
                  child: Container(
                      child: Text(
                        message.messageText,
                        style: TextStyle(color: Colors.white),
                      ),
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      margin: EdgeInsets.only(bottom: 5.0),
                      decoration: BoxDecoration(
                          color: Colors.blue[400],
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0),
                              bottomLeft: Radius.circular(8.0))))),
            ],
            mainAxisAlignment: MainAxisAlignment.end,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  _displayDateTime(message.sendAt),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                ),
              )
            ],
          )
        ],
      );
    } else {
      // Current user is NOT sender, need to align LEFT
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                flex: 7,
                child: Container(
                    child: Text(message.messageText),
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    margin: EdgeInsets.only(bottom: 5.0),
                    decoration: BoxDecoration(
                        color: liteGreyColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0)))),
              ),
              Flexible(
                flex: 3,
                child: Container(),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  _displayDateTime(message.sendAt),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                ),
              )
            ],
          )
        ],
      );
    }
  }

  String _displayDateTime(Timestamp timestamp) {
    DateFormat dateFormat = DateFormat(
      "dd/MM/yy HH:mm",
    );
    return dateFormat.format(timestamp.toDate());
  }

  List<Widget> _buildBody() {
    var _listWidget = List<Widget>();

    var _messages = _displayListView();
    _listWidget.add(_messages);

    var _bottomBar = _displayBottomBar();
    _listWidget.add(_bottomBar);

    return _listWidget;
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
      body: Stack(children: <Widget>[Column(children: _buildBody())]),
    );
  }
}
