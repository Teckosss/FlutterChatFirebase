import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_firebase/Helper/ContactHelper.dart';
import 'package:flutter_chat_firebase/Helper/RoomHelper.dart';
import 'package:flutter_chat_firebase/Helper/UserHelper.dart';
import 'package:flutter_chat_firebase/Models/User.dart';
import 'package:flutter_chat_firebase/UploadPicture.dart';
import 'package:flutter_chat_firebase/constants.dart';
import 'package:image_picker_modern/image_picker_modern.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({this.signOut, this.currentUser});

  final VoidCallback signOut;
  final User currentUser;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _downloadUrl;

  Future _selectImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print('Image selected : $image');
    if (image != null) {
      _downloadUrl =
          await Upload().uploadProfilePic(widget.currentUser.userId, image);
      print('URL received : $_downloadUrl');
      if (_downloadUrl != null) {
        widget.currentUser.userPicture = _downloadUrl;
        _updateEveryDocument(widget.currentUser);
      }
      setState(() {});
    }
  }

  Widget _showImageProfile() {
    var _imageUrl = widget.currentUser.userPicture == ""
        ? NO_IMAGE_PROFILE
        : widget.currentUser.userPicture;

    return Card(
        elevation: ELEVATION_5,
        child: InkWell(
            onTap: () {
              _selectImage();
            },
            child: Padding(
              padding: EdgeInsets.only(
                  top: PADDING_SMALL_8, bottom: PADDING_SMALL_8),
              child: Container(
                height: IMAGE_SIZE_BIG,
                child: CachedNetworkImage(
                  height: IMAGE_SIZE_BIG,
                  imageUrl: _downloadUrl == null ? _imageUrl : _downloadUrl,
                  placeholder: (context, url) => CircularProgressIndicator(),
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
        padding: EdgeInsets.all(PADDING_NORMAL_16),
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

  // This function will try to update User, Contact and Room database collection
  void _updateEveryDocument(User userToUpdate) async {
    List<DocumentSnapshot> listContacts = await ContactHelper()
        .getAllContactsWhoAreFriendsWithUser(widget.currentUser.userId)
        .then((docs) => docs.documents);
    List<DocumentSnapshot> listRooms = await RoomHelper()
        .getAllRoomWhereUserIs(widget.currentUser.userId)
        .then((docs) => docs.documents);
    listRooms.forEach((doc) => print('Doc received : ${doc.documentID}'));
    UserHelper().updateUserPicture(
        widget.currentUser.userId, widget.currentUser, listContacts, listRooms);
  }
}
