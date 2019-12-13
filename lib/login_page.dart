import 'package:contact_app/home_page.dart';
import 'package:contact_app/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email;
  String _password;
  var userId;
  var userEmail;
  SharedPreferences _preferences;
  ProgressDialog pr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          children: <Widget>[
        TextFormField(
        decoration: InputDecoration(
            labelText: 'Email'
        ),
          onChanged: (value){
          setState(() {
            _email = value;
          });
          },
      ),
      TextFormField(
        obscureText: true,
        decoration: InputDecoration(
            labelText: 'Password'
        ),
        onChanged: (value){
          setState(() {
            _password = value;
          });
        },
      ),
      new ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
           child: FlatButton(
             shape: RoundedRectangleBorder( borderRadius: new BorderRadius.circular(25.0),),
              color: Color.fromRGBO(66,133,244, 1),
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: EdgeInsets.all(8.0),
              splashColor:Color.fromRGBO(13,71,161, 1),
              onPressed: () {
                /*...*///print(_email +", "+ _password);
                login();
              },
              child: Text(
                "LOGIN",
                style: TextStyle(fontSize: 20.0),
              ),
            ),

      ),
            new ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: FlatButton(
                shape: RoundedRectangleBorder( borderRadius: new BorderRadius.circular(25.0),),
                color: Color.fromRGBO(255,68,68, 1),
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: EdgeInsets.all(8.0),
                splashColor: Color.fromRGBO(204,0,0, 1),
                onPressed: () {
                  /*...*/Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()));

                },
                child: Text(
                  "SIGN UP",
                  style: TextStyle(fontSize: 20.0),
                ),
              ),

            )
          ],
        ),

      ),
    );
  }
  void login() async {
    pr = new ProgressDialog(context);
    pr.style(message: "logging in...");
    pr.show();

    // set up POST request arguments
    String url = 'https://test.baity.com.br/user/login';
    var map = new Map<String, dynamic>();
    map['UserEmail'] = _email;
    map['UserPassword'] = _password;

    Response response = await post(
      url,
      body: map,
    );
    var jsonData = json.decode(response.body);
    bool error = jsonData["error"];
    if(error){
      pr.hide();
      showAlertDialog(context);
    }else{
      userId = jsonData["user_info"][0]["UserId"];
      userEmail = jsonData["user_info"][0]["UserEmail"];
      setSharedPreferences();
      //print(userId +", "+ userEmail);
      pr.hide();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomePage()));

    }
  }
  // set login session
  setSharedPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    await _preferences.setString("UserId", userId);
    await _preferences.setString("UserEmail", userEmail);
    await _preferences.commit();
  }

  showAlertDialog(BuildContext context) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: ()=> Navigator.pop(context)
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Login Error"),
      content: Text("Wrong email or password"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}