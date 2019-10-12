import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({this.signOut});

  final VoidCallback signOut;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Widget _showSignOutButton() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _showSignOutButton(),
    );
  }
}
