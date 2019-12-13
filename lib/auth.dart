import 'package:contact_app/home_page.dart';
import 'package:contact_app/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {

  SharedPreferences _preferences;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: CircularProgressIndicator()
        ),
    );
  }

  void initState(){
    this.checkAuth();
    super.initState();
  }
  Future<Null> checkAuth() async{
    _preferences = await SharedPreferences.getInstance();
    String _userId = _preferences.getString("UserId");
    if(_userId == "" || _userId == null){
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => new LoginPage()));
    }else{
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => new HomePage()));
    }
  }

}