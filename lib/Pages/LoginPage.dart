import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_firebase/Helper/UserHelper.dart';
import 'package:flutter_chat_firebase/authentication.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  _LoginPageState createState() => _LoginPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginPageState extends State<LoginPage> {
  final _formKey = new GlobalKey<FormState>();
  FormMode _formMode;

  String _email;
  String _password;
  String _username;
  String _errorMessage;

  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _formMode = FormMode.LOGIN;
    _errorMessage = "";
    _isLoading = false;
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          userId = await widget.auth.signIn(_email, _password);
          print('Signed in : $userId');
        } else {
          userId = await widget.auth.signUp(_email, _password);
          print('Signed up : $userId');
          UserHelper().createUser(userId, _username, "", null);
        }
        if (userId.length > 0 && userId != null) {
          print('userId is not null');
          widget.onSignedIn();
        }
      } catch (e) {
        print('Error on _validateAndSubmit in LoginPage : $e');
        switch ((e as PlatformException).code) {
          case "ERROR_USER_NOT_FOUND":
            _errorMessage =
                "This user doesn\'t exist. Please create an account first.";
            break;
          case "ERROR_WRONG_PASSWORD":
            _errorMessage = "The password is invalid.";
            break;
          case "ERROR_EMAIL_ALREADY_IN_USE":
            _errorMessage =
                "The email address is already in use by another account.";
            break;
          default:
            _errorMessage = "An error occured, please try again later.";
            break;
        }
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _isLoading = false;
    }
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w400),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  void _changeForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      if (_formMode == FormMode.LOGIN) {
        _formMode = FormMode.SIGNUP;
      } else {
        _formMode = FormMode.LOGIN;
      }
    });
  }

  Widget _showLogo() {
    return FlutterLogo(size: 150.0,);
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Stack(children: <Widget>[
        Opacity(
          opacity: 0.3,
          child: ModalBarrier(
            dismissible: false,
            color: Colors.grey,
          ),
        ),
        Center(child: CircularProgressIndicator())
      ]);
    }
    return Container(height: 0.0);
  }

  Widget _showEmailField() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: TextFormField(
          maxLines: 1,
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          autocorrect: false,
          decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Type your email',
              icon: Icon(
                Icons.email,
                color: Colors.grey,
              )),
          validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
          onSaved: (value) => _email = value.trim(),
        ));
  }

  Widget _showPasswordField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        autocorrect: false,
        decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Type your password',
            icon: Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget _showUsernameField() {
    if (_formMode == FormMode.SIGNUP) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: TextFormField(
          maxLines: 1,
          autofocus: false,
          autocorrect: false,
          decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'Type your username',
              icon: Icon(
                Icons.face,
                color: Colors.grey,
              )),
          validator: (value) =>
              value.isEmpty ? 'Username can\'t be empty' : null,
          onSaved: (value) => _username = value.trim(),
        ),
      );
    } else {
      return Container(height: 0.0);
    }
  }

  Widget _showLoginButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
      child: MaterialButton(
        elevation: 5.0,
        minWidth: 200.0,
        height: 42.0,
        color: Colors.blue,
        child: _formMode == FormMode.LOGIN
            ? Text('Login',
                style: TextStyle(fontSize: 20.0, color: Colors.white))
            : Text('Create account',
                style: TextStyle(fontSize: 20.0, color: Colors.white)),
        onPressed: () {
          _validateAndSubmit();
        },
      ),
    );
  }

  Widget _showRegisterButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: FlatButton(
        child: _formMode == FormMode.LOGIN
            ? Text('Create an account',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
            : Text('Already have an account?',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: () {
          _changeForm();
        },
      ),
    );
  }

  Widget _showBody() {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _showLogo(),
              _showEmailField(),
              _showPasswordField(),
              _showUsernameField(),
              _showLoginButton(),
              _showRegisterButton(),
              _showErrorMessage(),
            ],
          ),
        ));
  }

  List<Widget> _buildBody() {
    var listWidget = List<Widget>();

    SingleChildScrollView scrollView = SingleChildScrollView(
      child: _showBody(),
    );

    listWidget.add(scrollView);

    var progress = _showCircularProgress();

    listWidget.add(progress);
    return listWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Center(
            child: Stack(
          children: _buildBody(),
        )));
  }
}
