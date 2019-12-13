import 'package:contact_app/contact_details_page.dart';
import 'package:contact_app/login_page.dart';
import 'package:contact_app/new_contact_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'ContactModel.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences _preferences;
  String UserId;
  String UserEmail;
  List<ContactModel> list;
  var contactInfo;
  var data;
  ProgressDialog pr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contacts"),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                logout();
              },
            ),
          ]),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          return snapshot.data != null ? listViewWidget(snapshot.data) : Center(
              child: Text("Contact List is Empty"));
        },

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NewContactPage()));
        },
        child: Icon(Icons.person_add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<String> getUserIdPref() async {
    _preferences = await SharedPreferences.getInstance();
    String _userId = _preferences.getString("UserId");
    return _userId;
  }

  Future<String> getUserEmailPref() async {
    _preferences = await SharedPreferences.getInstance();
    String _userEmail = _preferences.getString("UserEmail");
    return _userEmail;
  }

  @override
  void initState() {
    getUserIdPref().then(SetUserIdPref);
    getUserEmailPref().then(SetUserEmailPref);
    super.initState();
  }

  void SetUserIdPref(String userId) {
    setState(() {
      this.UserId = userId;
    });
  }

  void SetUserEmailPref(String userEmail) {
    setState(() {
      this.UserEmail = userEmail;
    });
  }

  void logout() async {
    _preferences = await SharedPreferences.getInstance();
    await _preferences.setString("UserId", null);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
  }

  Future<List<ContactModel>> getData() async {
    String id = _preferences.getString("UserId");
    // set up POST request arguments
    String url = 'https://test.baity.com.br/contact/read_contacts?UserId='+id;
    _preferences = await SharedPreferences.getInstance();

    var map = new Map<String, dynamic>();
    map['UserId'] = id;
    Response response = await get(url);
    data = json.decode(response.body);
    contactInfo = data['contacts'] as List;
    list = contactInfo.map<ContactModel>((json) => ContactModel.fromJson(json))
        .toList();
    //print(url);
    return list;
  }

  Widget listViewWidget(List<ContactModel> _contact) {
    return Container(
      child: ListView.builder(
          itemCount: _contact.length,
          padding: const EdgeInsets.all(2.0),
          itemBuilder: (context, position) {
            return new ListTile(
              title: new Text('${list[position].ContactName}',
                style: TextStyle(fontSize: 22),
              ),
              subtitle: new Text('${list[position].ContactEmail}',
                style: TextStyle(fontSize: 14),
              ),
              leading: new CircleAvatar(
                radius: 25.0,
                backgroundImage:
                NetworkImage('${list[position].ContactImage}'),
                backgroundColor: Colors.transparent,
              ),
              onTap: () => _onTapItem(context, _contact[position]),
              onLongPress: () =>
                  _onLongPress(context, _contact[position], position),
            );
          }),
    );
  }

  void _onTapItem(BuildContext context, ContactModel contact) {
    var route = new MaterialPageRoute(
      builder: (BuildContext context) =>
      new ContactDetails(
          contact_id: contact.ContactId
      ),);
    Navigator.push(context, route);
  }

  void _onLongPress(BuildContext context, ContactModel contact, int _position) {
    //print(pos);
    showAlertDialog(context, contact.ContactId, _position);
  }

  showAlertDialog(BuildContext context, String contact_id, int contact_pos) {
    // set up the button
    Widget okButton = FlatButton(
        child: Text("Yes"),
        onPressed: () {
          deleteContact(contact_id, contact_pos);
        Navigator.pop(context);
        }
    );
    // set up the button
    Widget noButton = FlatButton(
        child: Text("No"),
        onPressed: () => Navigator.pop(context)
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text("Are you sure you want to delete this contact?"),
      actions: [
        noButton, okButton,
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

  void deleteContact(String _id, int _pos) async {

      // set up POST request arguments
      String url = 'https://test.baity.com.br/contact/delete_contact';
      var map = new Map<String, dynamic>();
      map['ContactId'] = _id;
      Response response = await post(
        url,
        body: map,
      );
      var jsonData = json.decode(response.body);
      bool error = jsonData["error"];
      if (error) {
        showErrorAlertDialog(context);
      }else{
        setState(() {
          list.remove(_pos);
        });
      }
  }


  showErrorAlertDialog(BuildContext context) {

    // set up the button
    Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () => Navigator.pop(context)
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Error"),
      content: Text("Error deleting Contact"),
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



