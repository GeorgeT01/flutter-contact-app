import 'dart:convert';
import 'package:contact_app/edit_contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:progress_dialog/progress_dialog.dart';



class ContactDetails extends StatefulWidget {
  final String contact_id;
  ContactDetails({Key key,this.contact_id}):super(key:key);
  @override
  _ContactDetailsState createState() => _ContactDetailsState();

}

class _ContactDetailsState extends State<ContactDetails> {

  String _imageUrl = "", _name ="", _email="", _phone="", _bd="", _note="", _gender="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text(_name),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async{
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => new EditContactPage(
                          contact_id: widget.contact_id
                      ),
                      fullscreenDialog: true,
                    )
                );


                setState(() {getSingleContact();});

//
//                var route = new MaterialPageRoute(
//                  builder: (BuildContext context) =>
//                  new EditContactPage(
//                      contact_id: widget.contact_id
//                  ),);
//                Navigator.push(context, route);

                },
            ) ,
          ]),
      body: Container(
        margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius:60.0,
                  backgroundImage:
                  NetworkImage(_imageUrl),
                  backgroundColor: Colors.transparent,
                ),
                Padding(
                    padding: const EdgeInsets.all(10.0),
                      child: Text(_name, style: new TextStyle(fontSize: 20),),
                 )
              ],
            ),
            Row(
              children: <Widget>[
              Icon(Icons.email),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(_email, style: new TextStyle(fontSize: 20),),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Icon(Icons.phone),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(_phone, style: new TextStyle(fontSize: 20),),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Icon(Icons.calendar_today),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(_bd, style: new TextStyle(fontSize: 20),),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Icon(Icons.info),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(_gender, style: new TextStyle(fontSize: 20),),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Icon(Icons.note),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(_note, style: new TextStyle(fontSize: 20),),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

@override
  void initState() {
    setState(() {
      this.getSingleContact();
    });
    super.initState();
  }

  void getSingleContact() async {
    // set up POST request arguments
    String url = 'https://test.baity.com.br/contact/read_contact?ContactId='+widget.contact_id;
   // var map = new Map<String, dynamic>();
    //map['ContactId'] = widget.contact_id;
    Response response = await get(url);
    var jsonData = json.decode(response.body);
    bool error = jsonData["error"];
    if (error) {
      showErrorAlertDialog(context);
    }else{
      setState(() {
        _imageUrl = jsonData["contact"][0]["ContactImage"];
        _name = jsonData["contact"][0]["ContactName"];
        _email = jsonData["contact"][0]["ContactEmail"];
        _phone = jsonData["contact"][0]["ContactPhone"];
        _bd = jsonData["contact"][0]["ContactDateBirth"];
        _gender = jsonData["contact"][0]["ContactGender"];
        _note = jsonData["contact"][0]["ContactNote"];

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
      content: Text("Error fetching Contact"),
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