import 'dart:convert';

import 'package:contact_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
        title: Text("Sign up"),
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
                color: Color.fromRGBO(255,68,68, 1),
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: EdgeInsets.all(8.0),
                splashColor: Color.fromRGBO(204,0,0, 1),
                onPressed: () {
                  /*...*/createUser();
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


  void createUser() async {
    pr = new ProgressDialog(context);
    pr.style(message: "Signing up...");
    pr.show();
    // set up POST request arguments
    String url = 'https://test.baity.com.br/user/create';
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
      print(userId +", "+ userEmail);
      pr.hide();
      Navigator.of(context).popUntil((route) => route.isFirst);
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
    Widget tryButton = FlatButton(
        child: Text("Try again"),
        onPressed: ()=> Navigator.pop(context)
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Error"),
      content: Text("Somthing went wrong!"),
      actions: [
        tryButton,
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