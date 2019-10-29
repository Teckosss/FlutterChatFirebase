import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_firebase/Helper/ContactHelper.dart';
import 'package:flutter_chat_firebase/Helper/MessageHelper.dart';
import 'package:flutter_chat_firebase/Helper/RoomHelper.dart';
import 'package:flutter_chat_firebase/Helper/UserHelper.dart';
import 'package:flutter_chat_firebase/Models/User.dart';
import 'package:flutter_chat_firebase/Pages/AddContactsPage.dart';
import 'package:flutter_chat_firebase/Pages/MessagesPage.dart';
import 'package:flutter_chat_firebase/constants.dart';

class FriendsPage extends StatefulWidget {
  FriendsPage({this.userId, this.currentUser});

  final String userId;
  final User currentUser;

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  bool _isLoading;
  User currentUser;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    currentUser = widget.currentUser;
  }

  void _navigateToAddContactPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddContactsPage(
                  userId: widget.userId,
                )));
  }

  void _startChatWithContact(User userToChatWith) {
    print(userToChatWith.toString());
    print('Current user :${widget.currentUser.toString()}');

    String roomId;

    RoomHelper()
        .checkIfUserIsAlreadyInRoomWithSpecificUser(
            widget.userId, userToChatWith.userId)
        .then((results) {
      if (results.documents.length > 0) {
        // User is already in room chat with this user
        // Open the corresponding chat?
        print('These two users are already in chat rooms together');
        for (DocumentSnapshot document in results.documents) {
          roomId = document.documentID;
        }
      } else {
        print('These two users are NOT in chat rooms together');
        roomId = MessageHelper().createMessageDocument().documentID;
        print('room id $roomId');
        if (currentUser.rooms == null) {
          currentUser.rooms = Map<String, bool>();
        }
        if (userToChatWith.rooms == null) {
          userToChatWith.rooms = Map<String, bool>();
        }
        currentUser.rooms[roomId] = true;
        userToChatWith.rooms[roomId] = true;
        RoomHelper().createRoomForUser(widget.userId, userToChatWith, roomId);
        RoomHelper()
            .createRoomForUser(userToChatWith.userId, currentUser, roomId);

        UserHelper().updateUser(widget.userId, currentUser);
        UserHelper().updateUser(userToChatWith.userId, userToChatWith);

        ContactHelper().updateContact(widget.userId, userToChatWith);
        ContactHelper().updateContact(userToChatWith.userId, currentUser);
      }
      _navigateToMessagesPage(userToChatWith, roomId);
    });
  }

  void _navigateToMessagesPage(User userToChatWith, String roomId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MessagesPage(
                  currentUser: currentUser,
                  userToChat: userToChatWith,
                  roomId: roomId,
                )));
  }

  Widget _queryUserContact(userId) {
    _isLoading = true;
    return StreamBuilder<QuerySnapshot>(
        stream: ContactHelper().getUserContactCollection(userId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            _isLoading = false;
            return Text('Error : ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.none:
              print('Data none');
              return Text(
                  'Not able to fecth data, please check your internet connection');
            default:
              if (snapshot.data.documents.length > 0) {
                return Padding(
                    padding: EdgeInsets.all(PADDING_NORMAL_16),
                    child: ListView(
                      shrinkWrap: true,
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        print(
                            'Data received : ${snapshot.data.documents.length}');
                        _isLoading = false;
                        var imageUrl = document['userPicture'] == ""
                            ? null
                            : document['userPicture'];
                        return Card(
                            elevation: ELEVATION_5,
                            child: InkWell(
                                onTap: () {
                                  _startChatWithContact(User.fromMap(
                                      document.data, document.documentID));
                                },
                                child: Padding(
                                    padding: EdgeInsets.all(PADDING_SMALL_4),
                                    child: ListTile(
                                      leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          child: CachedNetworkImage(
                                            height: IMAGE_SIZE_SMALL,
                                            imageUrl: imageUrl == null
                                                ? NO_IMAGE_PROFILE // REPLACE THIS PLACEHOLDER
                                                : document['userPicture'],
                                            placeholder: (context, url) =>
                                                CircularProgressIndicator(),
                                            errorWidget: (context, url,
                                                    error) =>
                                                Image.asset(
                                                    'assets/images/ic_no_image_available.jpg'),
                                          )),
                                      title: Text(document['username']),
                                    ))));
                      }).toList(),
                    ));
              } else {
                print('Data received : ${snapshot.data.documents.length}');
                return Center(child: Text('You don\'t have any contact yet'));
              }
          }
        });
  }

  Widget _showFAB() {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(PADDING_NORMAL_16),
            child: FloatingActionButton(
              onPressed: () {
                _navigateToAddContactPage();
              },
              child: Icon(Icons.group_add),
            ),
          )
        ],
      )
    ]);
  }

  List<Widget> _buildBody() {
    var listWidget = List<Widget>();

    var listView = _queryUserContact(widget.userId);
    listWidget.add(listView);

    var fab = _showFAB();

    listWidget.add(fab);
    return listWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _buildBody(),
    );
  }
}
