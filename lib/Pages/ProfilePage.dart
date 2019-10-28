import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_firebase/Models/User.dart';
import 'package:flutter_chat_firebase/constants.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({this.signOut, this.currentUser});

  final VoidCallback signOut;
  final User currentUser;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Widget _showImageProfile() {
    String _imageUrl = widget.currentUser.userPicture == ""
        ? NO_IMAGE_PROFILE
        : widget.currentUser.userPicture;
    return Card(
        elevation: ELEVATION_5,
        child: InkWell(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.only(
                  top: PADDING_SMALL_8, bottom: PADDING_SMALL_8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: CachedNetworkImage(
                  height: IMAGE_SIZE_BIG,
                  imageUrl: _imageUrl,
                ),
              ),
            )));
  }

  Widget _showUsername() {
    return Card(
      elevation: ELEVATION_5,
      child: InkWell(
        onTap: () {},
        child: ListTile(
          leading: Icon(Icons.person),
          title: Text(widget.currentUser.username),
        ),
      ),
    );
  }

  Widget _showSignOutButton() {
    return Card(
      elevation: ELEVATION_5,
      child: InkWell(
        onTap: () {
          _showAlertDialog(context);
        },
        child: ListTile(
          leading: Icon(Icons.cancel),
          title: Text("Sign out"),
        ),
      ),
    );
  }

  _showAlertDialog(BuildContext context) {
    Widget _noButton = FlatButton(
      child: Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget _yesButton = FlatButton(
      child: Text("Yes"),
      onPressed: () {
        widget.signOut();
        Navigator.of(context).pop();
      },
    );

    AlertDialog alertDialog = AlertDialog(
      title: Text("Confirmation"),
      content: Text("Do you really want to sign out?"),
      actions: <Widget>[_noButton, _yesButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  /*Widget _showSignOutButton() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: MaterialButton(
          elevation: 5.0,
          height: 42.0,
          color: Colors.blue,
          minWidth: 200.0,
          child: Text(
            'Sign Out',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            widget.signOut();
          },
        ));
  }*/

  List<Widget> _buildBody() {
    var listWidgets = List<Widget>();

    var _imageProfile = _showImageProfile();
    listWidgets.add(_imageProfile);

    var _username = _showUsername();
    listWidgets.add(_username);

    var _signOutButton = _showSignOutButton();
    listWidgets.add(_signOutButton);

    return listWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildBody(),
        ));
  }

  @override
  void initState() {
    super.initState();
    print("Current user : ${widget.currentUser}");
  }
}
