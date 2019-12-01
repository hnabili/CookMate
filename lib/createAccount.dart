import 'package:cookmate/util/localStorage.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './util/backendRequest.dart';
import 'homePage.dart';
import 'package:flushbar/flushbar.dart';



class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {

  final _formKey = GlobalKey<FormState>();
  String _username, _email, _password, _confirmedPassword;
  bool signup = false;



  _submit() async {
    int _id;
    if(_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if( _password == _confirmedPassword) {
        Future<int> potentialID = BackendRequest.createUser(_email, _username, _password);
          potentialID.then((id) {
            _id = id;
            if( _id != null) {
              LocalStorage.storeUserID(_id);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            }

          });
      }
    }
    _formKey.currentState.reset();
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.GROUNDED,
      messageText: Text('Unable to Sign Up with provided credentials.',
      textAlign: TextAlign.center, 
      style: TextStyle(fontSize: 16, 
      fontWeight: FontWeight.bold, color: Colors.white),) ,
      backgroundColor: Colors.red[800],)..show(context);
  }

  Widget _buildUsernameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0,),
        Container(
          alignment: Alignment.centerLeft,
          decoration:  BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(15),
                /*
                prefixIcon: Icon(
                  Icons.supervised_user_circle,
                  color: Colors.white,
                ),*/
                hintText: 'Enter your Username',
                hintStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            validator: (input) => input.trim().isEmpty
                ? 'Please enter a valid username'
                : null,
            onSaved: (input) => _username = input,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0,),
        Container(
          alignment: Alignment.centerLeft,
          decoration:  BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(15),
                hintText: 'Enter your Email',
                hintStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            validator: (input) => !EmailValidator.Validate(input, true)
                ? 'Please provide a valid email.' : null,
            onSaved: (input) => _email = input,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0,),
        Container(
          alignment: Alignment.centerLeft,
          decoration:  BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(15),
                hintText: 'Enter your Password',
                hintStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
            ),
            validator: (input) => input.length < 6
                ? 'Must be at least 6 characters'
                : null,
            onSaved: (input) => _password = input,

          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0,),
        Container(
          alignment: Alignment.centerLeft,
          decoration:  BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(15),

                hintText: 'Confirm your Password',
                hintStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
            ),
            validator: (input) => input.length < 6
                ? 'Must be at least 6 characters'
                : null,
            onSaved: (input) => _confirmedPassword = input,

          ),
        ),
      ],
    );
  }

  Widget _buildSignUpBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () {
          _submit();
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.red[800],
        child: Text(
            'SIGN UP',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.5,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            )
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),

          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xF8F8FF),
                      Color(0xFFFFFF),
                      Color(0xFFFAFA),
                    ],
                    stops: [0.1, 0.4, 0.7],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child:
                  Form(
                    key: _formKey,
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 20.0,),
                      _buildUsernameTF(),
                      SizedBox(
                        height: 20.0,
                      ),
                      _buildEmailTF(),
                      SizedBox(
                        height: 20.0,
                      ),
                      _buildPasswordTF(),
                      _buildConfirmPasswordTF(),
                      SizedBox(
                        height: 20.0,
                      ),
                      _buildSignUpBtn(),

                    ],
                  ),
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

