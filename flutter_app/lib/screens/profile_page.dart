import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../utility/category.dart';
import 'package:flutterapp/utility/category_route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final Category category;

  const ProfilePage({
    @required this.category,
  }) : assert(category != null);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final myController = TextEditingController();
  bool _validate = true;
  final eSenseController = TextEditingController();
  bool _validateeSense = true;
  String _usernameKey = "username";
  String _eSenseNameKey = "eSense";
  String _username = "";
  String _eSense = "";

  void _loadData() async {
    await SharedPreferences.getInstance().then((value) {
      setState(() {
        _username = value.getString(_usernameKey);
        _eSense = value.getString(_eSenseNameKey);
      });
    });
  }

  @override
  void dispose() {
    myController.dispose();
    eSenseController.dispose();
    super.dispose();
  }

  Future<void> _editUsername() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        bool valid = true;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Username'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: myController,
                    decoration: InputDecoration(
                      hintText: _username,
                      helperText: 'Enter a username of form "B001"',
                      errorText: valid ? null : 'Provide a valid username',
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Submit'),
                onPressed: () {
                  RegExp user = RegExp(r'^B[0-9]+$');
                  if (myController != null &&
                      user.hasMatch(myController.text)) {
                    SharedPreferences.getInstance().then((value) =>
                        {value.setString(_usernameKey, myController.text)});
                    setState(() {
                      valid = true;
                      _username = myController.text;
                    });

                    Navigator.of(context).pop();
                  } else {
                    setState(() {
                      valid = false;
                    });
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _editeSenseName() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        bool valid = true;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit eSense earbuds number'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: eSenseController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      helperText: 'Enter the name of your earbuds',
//                      border: ,
                      hintText: _eSense,
                      errorText: valid ? null : 'Provide a valid name',
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Submit'),
                onPressed: () {
                  if (int.tryParse(eSenseController.text) != null) {
                    SharedPreferences.getInstance().then((value) => {
                          value.setString(_eSenseNameKey, eSenseController.text)
                        });
                    setState(() {
                      valid = true;
                      _eSense = eSenseController.text;
                    });
                    Navigator.of(context).pop();
                  } else {
                    setState(() {
                      valid = false;
                    });
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //not very pretty, but it does allow for interactive update on edits
    _loadData();
    final fullWidth = MediaQuery.of(context).size.width;

    final profile = new Container(
      height: 170,
      width: fullWidth,
      color: Color(0xFFFFD28E),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            elevation: 2.0,
            fillColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Color(0xFFFFA41C),
              size: 55.0,
            ),
            padding: EdgeInsets.all(10.0),
            shape: CircleBorder(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              _username,
              style: TextStyle(fontSize: 17, color: Colors.white),
            ),
          )
        ],
      ),
    );

    final _usernameInfo = new Container(
        child: Padding(
      padding: EdgeInsets.only(left: 30, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text("Username",
                  style: TextStyle(fontSize: 18, color: Color(0xFFFFA41C)),
                  textAlign: TextAlign.right),
              Container(
                width: 20,
              ),
              Text(_username,
                  style: TextStyle(fontSize: 18, color: Colors.black45),
                  textAlign: TextAlign.left),
            ],
          ),
          TextButton(
            child: Icon(Icons.edit),
            style: TextButton.styleFrom(
              primary: Colors.grey,
            ),
            onPressed: () => _editUsername(),
          )
        ],
      ),
    ));

    final _earbudsInfo = new Container(
        child: Padding(
      padding: EdgeInsets.only(left: 30, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text("eSense name",
                  style: TextStyle(fontSize: 18, color: Color(0xFFFFA41C)),
                  textAlign: TextAlign.right),
              Container(
                width: 20,
              ),
              Text(_eSense,
                  style: TextStyle(fontSize: 18, color: Colors.black45),
                  textAlign: TextAlign.left),
            ],
          ),
          TextButton(
            child: Icon(Icons.edit),
            style: TextButton.styleFrom(
              primary: Colors.grey,
            ),
            onPressed: () => _editeSenseName(),
          )
        ],
      ),
    ));

    Future<void> _neverSatisfied() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('You are deleting your account'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to proceed?'),
                  Text('Every data will be deleted and never be restored.'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Delete'),
                onPressed: () {
                  // _deleteUser();
                  Fluttertoast.showToast(
                      msg: "Your profile has been deleted successfully!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoryRoute()),
                  );
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
        body: ListView(children: <Widget>[
      Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          profile,
          new Divider(height: 40.0, color: Colors.white),
          _usernameInfo,
          new Divider(height: 20.0, color: Colors.white),
          _earbudsInfo,
        ],
      ))
    ]));
  }
}
