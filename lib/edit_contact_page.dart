import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';


class EditContactPage extends StatefulWidget {
  final String contact_id;
  EditContactPage({Key key,this.contact_id}):super(key:key);
  @override
  _EditContactPageState createState() => _EditContactPageState();

}

class _EditContactPageState extends State<EditContactPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> _genders = ["Male", "Female"].toList();
  String _selectedGender;
  File file;
  String _imageUrl ="";
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _birthDate = TextEditingController();
  final _note = TextEditingController();
  bool _validate = false;
  ProgressDialog pr;

  final FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery
        .of(context)
        .size;
    return Scaffold(
        appBar: AppBar(title: Text("Edit contact"),
            actions: <Widget>[
              // action button
              IconButton(

               icon: Icon(Icons.check),
               tooltip: ("Save"),
                onPressed: () {
                // action
                  updateContact();
                },
              ),
            ]
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Center(
                        child:
                        Column(
                          children: <Widget>[
                            file == null
                                ?  Image.network(_imageUrl, width: 150, height: 150,)
                                : Image.file(file, height: 150, width: 150,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                RaisedButton(
                                  onPressed: _choose,
                                  child: Text('Choose Image'),
                                ),
                                SizedBox(width: 10.0),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),

                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      errorText: _validate ? 'Value Can\'t Be Empty' : null,
                    ),
                    focusNode:  _validate ? focusNode : null,
                  ),


                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _email,
                    decoration: InputDecoration(
                        labelText: 'Email'
                    ),
                  ),


                  TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _phone,
                    decoration: InputDecoration(
                        labelText: 'Phone'
                    ),
                  ),

                  TextFormField(
                    keyboardType: TextInputType.datetime,
                    controller: _birthDate,
                    decoration: InputDecoration(
                        labelText: 'Birth Date'
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.only(top: 30.0, right: 10.0, left: 10.0),
                    child: new Column(
                      children: <Widget>[
                        new Text("Select Gender"),
                        new DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedGender,
                            items: _genders.map((String value) {
                              return new DropdownMenuItem(
                                  value: value,
                                  child: new Text("${value}")
                              );
                            }).toList(),
                            onChanged: (String value) {
                              onGenderChange(value);
                            }
                        ),
                      ],
                    ),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    controller: _note,
                    decoration: InputDecoration(
                        labelText: 'Note'
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }


  @override
  void initState() {
    setState(() {
      getSingleContact();
    });
    _selectedGender = _genders.first; // set option to first option
    super.initState();
  }

  void onGenderChange(String item) {
    setState(() {
      _selectedGender = item; // set option to selected item
    });
  }
  void _choose() async {
    //file = await ImagePicker.pickImage(source: ImageSource.camera);
    var _file = await ImagePicker.pickImage(source: ImageSource.gallery); // pick image from gallery
    setState(() {
      file = _file;
    });
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
        _name.text = jsonData["contact"][0]["ContactName"];
        _email.text = jsonData["contact"][0]["ContactEmail"];
        _phone.text = jsonData["contact"][0]["ContactPhone"];
        _birthDate.text = jsonData["contact"][0]["ContactDateBirth"];
        _selectedGender = jsonData["contact"][0]["ContactGender"];
        _note.text = jsonData["contact"][0]["ContactNote"];
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


  void updateContact() async {
    pr = new ProgressDialog(context);
    pr.style(message: "Loading...");
    pr.show();
    if(_name.text.isEmpty){ //check if name is empty
      _validate = true;
    }else{ // if name not empty
      String _img;
      String imgName;
      // set up POST request arguments
      String url = 'https://test.baity.com.br/contact/update_contact';
      var map = new Map<String, dynamic>();
      map['ContactId'] = widget.contact_id;
      if (file == null){
        _img = _imageUrl;
        imgName="";
      }else{
        _img = base64Encode(file.readAsBytesSync());// convert image
        imgName = file.path.split("/").last;
      }
      map['ImageName'] = imgName;
      map['ContactImage'] = _img;
      map['ContactName'] = _name.text;
      map['ContactEmail'] = _email.text;
      map['ContactPhone'] = _phone.text;
      map['ContactDateBirth'] = _birthDate.text;
      map['ContactGender'] = _selectedGender;
      map['ContactNote'] = _note.text;
      //get response
      Response response = await post(
        url,
        body: map,
      );
      var jsonData = json.decode(response.body); //get json response
      bool error = jsonData["error"];
      if(error){
        print("error!");
        // showAlertDialog(context); // show error dialog
      }else{
       // _showToast(context); // show toast
        Navigator.pop(context); // back to previous
      }
    }
    pr.hide();
  }
}