import 'package:flutter/material.dart';
import 'package:flutter_chat_firebase/Pages/FriendsPage.dart';
import 'package:flutter_chat_firebase/Pages/MessagesPage.dart';
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

class _BasePageState extends State<BasePage> {
  var _index;

  Widget _showMessagesPage() {
    return MessagesPage();
  }

  Widget _showFriendsPage() {
    return FriendsPage();
  }

  Widget _showProfilePage() {
    return ProfilePage(signOut: signOut);
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

  Widget _showHeroLogo(){
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

  @override
  Widget build(BuildContext context) {
    Widget _widgetToDisplay;
    switch (_index) {
      case 0:
        _widgetToDisplay = _showMessagesPage();
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
  }
}
