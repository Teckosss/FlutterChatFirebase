import 'package:flutter/material.dart';
import 'package:flutter_chat_firebase/Pages/BasePage.dart';
import 'package:flutter_chat_firebase/Pages/LoginPage.dart';
import 'package:flutter_chat_firebase/authentication.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus{
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user){
      print('user : $user');
      setState(() {
        _userId = user;
        authStatus = _userId == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
    print('RootPage auth status : $authStatus');
    print('user id : $_userId');
  }

  void _onLoggedIn(){
    widget.auth.getCurrentUser().then((user){
      setState(() {
        if(user != null){
          _userId = user;
          authStatus = AuthStatus.LOGGED_IN;
        }else{
          print('RootPage : user id is null');
        }
      });
    });
  }

  void _onSignedOut(){
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId="";
    });
  }

  Widget _buildWaitingScreen(){
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch(authStatus){
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return LoginPage(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return BasePage(
            userId: _userId,
            auth: widget.auth,
            onSignedOut: _onSignedOut,
          );
        } else return _buildWaitingScreen();
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}
