import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_firebase/Helper/RoomHelper.dart';
import 'package:flutter_chat_firebase/Models/User.dart';

class ChatsPage extends StatefulWidget {
  ChatsPage({this.currentUser});

  final User currentUser;

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  Widget _buildListView() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          RoomHelper().getRoomsForUser(widget.currentUser.userId).asStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error retrieving chats');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            if (snapshot.data.documents.length > 0) {
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: ListView(
                  shrinkWrap: true,
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    var imageUrl = document['userPicture'] == ""
                        ? null
                        : document['userPicture'];
                    return Card(
                      elevation: 2.0,
                      child: InkWell(
                        onTap: () {},
                        child: ListTile(
                          leading: ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: CachedNetworkImage(
                                height: 50.0,
                                imageUrl: imageUrl == null
                                    ? 'https://picsum.photos/250?image=9' // REPLACE THIS PLACEHOLDER
                                    : document['userPicture'],
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Image.asset(
                                    'assets/images/ic_no_image_available.jpg'),
                              )),
                          title: Text(document['username']),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('You don\'t any chats yet'),
              );
            }
        }
      },
    );
  }

  List<Widget> _buildBody() {
    var listWidget = List<Widget>();

    var listViewChats = _buildListView();
    listWidget.add(listViewChats);

    return listWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _buildBody(),
    );
  }
}
