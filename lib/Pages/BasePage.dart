import 'package:flutter/material.dart';
import 'package:flutter_chat_firebase/Helper/UserHelper.dart';
import 'package:flutter_chat_firebase/Models/User.dart';
import 'package:flutter_chat_firebase/Pages/ChatsPage.dart';
import 'package:flutter_chat_firebase/Pages/FriendsPage.dart';
import 'package:flutter_chat_firebase/Pages/ProfilePage.dart';
import 'package:flutter_chat_firebase/authentication.dart';

class BasePage extends StatefulWidget {
  BasePage({this.auth, this.onSignedOut, this.userId});

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _BasePageState createState() => _BasePageState();
}

enum UserDataStatus {
  WAITING,
  OK,
}

class _BasePageState extends State<BasePage> {
  var _index;
  User currentUser;
  UserDataStatus userDataStatus;

  Widget _showChatsPage() {
    return ChatsPage(
      currentUser: currentUser,
    );
  }

  Widget _showFriendsPage() {
    return FriendsPage(
      userId: widget.userId,
      currentUser: currentUser,
    );
  }

  Widget _showProfilePage() {
    return ProfilePage(
      signOut: signOut,
      currentUser: currentUser,
    );
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    print('BasePage, current user uid : ${widget.userId}');
    _index = 0;
    userDataStatus =
        currentUser == null ? UserDataStatus.WAITING : UserDataStatus.OK;
    _retrieveCurrentUser();
  }

  void _retrieveCurrentUser() async {
    await UserHelper().getUser(widget.userId).then((user) {
      setState(() {
        currentUser = User.fromMap(user.data, user.documentID);
        userDataStatus = UserDataStatus.OK;
      });
    });
  }

  Widget _showBottomNavBar() {
    return BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        currentIndex: _index,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.message,
            ),
            title: Text('Messages'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people,
            ),
            title: Text('Friends'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.face,
            ),
            title: Text('Profile'),
          ),
        ],
        onTap: (value) {
          setState(() {
            _index = value;
          });
        });
  }

  Widget _showHeroLogo() {
    return Hero(
      tag: 'logo',
      child: Padding(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 30.0,
          child: Image.asset('assets/images/flutter_logo.png'),
        ),
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (userDataStatus) {
      case UserDataStatus.WAITING:
        return _buildWaitingScreen();
        break;
      case UserDataStatus.OK:
        Widget _widgetToDisplay;
        switch (_index) {
          case 0:
            _widgetToDisplay = _showChatsPage();
            break;
          case 1:
            _widgetToDisplay = _showFriendsPage();
            break;
          case 2:
            _widgetToDisplay = _showProfilePage();
            break;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Flutter Chat'),
            leading: _showHeroLogo(),
          ),
          body: _widgetToDisplay,
          bottomNavigationBar: _showBottomNavBar(),
        );
      default:
        return _buildWaitingScreen();
    }
  }
}
