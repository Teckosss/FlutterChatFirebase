import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_firebase/Helper/ContactHelper.dart';
import 'package:flutter_chat_firebase/Helper/UserHelper.dart';
import 'package:flutter_chat_firebase/Models/User.dart';
import 'package:flutter_chat_firebase/constants.dart';

class AddContactsPage extends StatefulWidget {
  AddContactsPage({this.userId});

  final String userId;

  @override
  _AddContactsPageState createState() => _AddContactsPageState();
}

class _AddContactsPageState extends State<AddContactsPage> {
  String _username;

  bool _isPerformingSearch;

  final _queryController = TextEditingController();
  Timer _debounce;

  @override
  void initState() {
    super.initState();
    _username = "";
    _isPerformingSearch = false;
    _queryController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _queryController.removeListener(_onSearchChanged);
    _queryController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _username = _queryController.text;
      if (_username.length > 3) {
        print('Username : $_username');
        setState(() {
          _isPerformingSearch = true;
        });
      }
    });
  }

  void _addUserContact(User userToAdd) {
    print('userId : ${widget.userId}');
    print(userToAdd.toString());
    ContactHelper().createUserContact(widget.userId, userToAdd);
    UserHelper().getUser(widget.userId).then((document) {
      ContactHelper().createUserContact(
          userToAdd.userId, User.fromMap(document.data, document.documentID));
    });
  }

  Widget _searchUser(username) {
    return StreamBuilder<QuerySnapshot>(
        stream: UserHelper().getUserByUsername(username).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
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
                    padding: EdgeInsets.only(top: PADDING_SMALL_8),
                    child: ListView(
                      shrinkWrap: true,
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        print(
                            'Data received : ${snapshot.data.documents.length}');
                        if (document['uid'] == widget.userId ||
                            document['uid'].toString().isEmpty) {
                          return Center(
                              child: Padding(
                                  padding:
                                      EdgeInsets.only(top: 30.0),
                                  child: Text('No results')));
                        }

                        var imageUrl = document['userPicture'] == ""
                            ? null
                            : document['userPicture'];
                        return StreamBuilder<QuerySnapshot>(
                            stream: ContactHelper()
                                .getSpecificContactForUser(
                                    widget.userId, document['uid'])
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> contact) {
                              if (!(contact.hasError)) {
                                switch (contact.connectionState) {
                                  case ConnectionState.waiting:
                                    return Center(
                                        child: CircularProgressIndicator());
                                  default:
                                    bool _isFriend =
                                        contact.data.documents.length > 0;
                                    return Card(
                                        elevation: ELEVATION_5,
                                        child: Padding(
                                          padding: EdgeInsets.all(PADDING_SMALL_4),
                                          child: ListTile(
                                            leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                child: CachedNetworkImage(
                                                  height: IMAGE_SIZE_SMALL,
                                                  imageUrl: imageUrl == null
                                                      ? 'https://picsum.photos/250?image=9' // REPLACE THIS PLACEHOLDER
                                                      : document['userPicture'],
                                                  placeholder: (context, url) =>
                                                      CircularProgressIndicator(),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Image.asset(
                                                          'assets/images/ic_no_image_available.jpg'),
                                                )),
                                            title: Text(document['username'],
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                            trailing: _displayFriendButton(
                                                _isFriend, document),
                                          ),
                                        ));
                                }
                              } else {
                                return Center(
                                    child: Padding(
                                        padding: EdgeInsets.only(top: 30.0),
                                        child: Text('No results')));
                              }
                            });
                      }).toList(),
                    ));
              } else {
                return Center(
                    child: Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Text('No results')));
              }
          }
        });
  }

  Widget _displayFriendButton(bool isFriend, DocumentSnapshot document) {
    if (isFriend) {
      return IconButton(
        icon: Icon(Icons.check),
        color: Colors.green,
        onPressed: () {},
      );
    } else {
      return IconButton(
        icon: Icon(Icons.person_add),
        color: Colors.deepPurple,
        onPressed: () {
          _addUserContact(User.fromMap(document.data, document.documentID));
        },
      );
    }
  }

  Widget _showSearchField() {
    return Card(
      elevation: ELEVATION_5,
      child: Padding(
          padding: EdgeInsets.all(PADDING_SMALL_8),
          child: TextField(
            controller: _queryController,
            autocorrect: false,
            autofocus: true,
            decoration: InputDecoration(
                hintText: 'Find a friend', icon: Icon(Icons.search)),
          )),
    );
  }

  List<Widget> _buildBody() {
    var listWidget = List<Widget>();

    var searchField = _showSearchField();
    listWidget.add(searchField);

    if (_isPerformingSearch) {
      var searchResult = _searchUser(_username);
      listWidget.add(searchResult);
    }

    return listWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Add Contact'),
          automaticallyImplyLeading: true,
          leading: Platform.isAndroid
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context))
              : IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context))),
      body: Padding(
          padding: EdgeInsets.all(PADDING_NORMAL_16),
          child: Column(
            children: _buildBody(),
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _searchUser(_username),
        child: Icon(Icons.search),
      ),
    );
  }
}
