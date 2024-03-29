import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gallery_lab/screens/dashboard_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:fluttertoast/fluttertoast.dart';


class AddImage extends StatefulWidget {
  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  String imageUrl;
  String _locationMessage = "";
  String gettime = "";
  int i=0;
  String imgdes="";
  String desc ="";

  File imageFile;
  final _picker = ImagePicker();
  ImagePicker getImageFile;
  final firebase = FirebaseDatabase.instance;

  //to upload the text in firebase
  Future<void> main() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  _openGallery(BuildContext context)async{
    final pic= await _picker.getImage(source:ImageSource.gallery);
    this.setState(() {
      imageFile = File(pic.path);

    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context)async{
    final pic= await _picker.getImage(source:ImageSource.camera);
    this.setState(() {
      imageFile = File(pic.path);
    });
    Navigator.of(context).pop();
  }

  Future<void>_showChoice (BuildContext context){
    return showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text('Select one'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text('Gallery'),
                onTap: (){
                  _openGallery(context);
                },
              ),
              Padding(padding: EdgeInsets.all(8.0)),
              GestureDetector(
                child: Text('Camera'),
                onTap: (){
                  _openCamera(context);
                },
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _decideImage(){
    if(imageFile == null){
      return Text('No Image Selected');
    }else{
      return Image.file(imageFile,width: 400,height: 100 );
    }
  }

  TextEditingController des = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss EEE d MMM').format(now);
    String gettime = formattedDate;

    final ref = firebase.reference().child("image$i");

    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // SizedBox(height: 1.0,),
            _decideImage(),
            SizedBox(height: 10.0,),
            Text(
              "Date and Time: "+ formattedDate+"\n",

            ),
            Text("Current Location: "+_locationMessage+"\n"),
            SizedBox(
                width: 250,
                child: TextFormField(
                  controller: des,
                  decoration:InputDecoration(
                    border : OutlineInputBorder(),
                    hintText: 'Enter your Description',
                  ),
                  onChanged: (val){
                    setState(() {
                      desc=val;
                    });
                  },
                )
            ),
            SizedBox(height: 10.0,),
            RaisedButton(
              child: Text("Find location", style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
              onPressed: (){
                _getCurrentLocation();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.indigo)
              ),
              elevation: 5.0,
              color: Colors.indigo,
              textColor: Colors.white,

              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              splashColor: Colors.grey,
            ),
            SizedBox(height: 10.0,),
                RaisedButton(
                  child: Text("Pick Image", style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),

                  onPressed: (){
                    _showChoice(context);
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.indigo)
                  ),
                  elevation: 5.0,
                  color: Colors.indigo,
                  textColor: Colors.white,

                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  splashColor: Colors.grey,
                ),
                SizedBox(width: 10.0,),
                RaisedButton(
                  child: Text("Upload Image", style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
                  onPressed: () {

                    uploadFile();
                    ref.child("Description").set(desc);
                    ref.child("Location").set(_locationMessage);
                    ref.child("Date").set(formattedDate);


                    Fluttertoast.showToast(msg: 'Successfull upload !!');
                    i++;
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.indigo)
                  ),
                  elevation: 5.0,
                  color: Colors.indigo,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  splashColor: Colors.grey,
                ),

            SizedBox(height: 10.0,),
            RaisedButton(
              child: Text("Back To Gallery", style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => DashboardScreen()));
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.indigo)
              ),
              elevation: 5.0,
              color: Colors.indigo,
              textColor: Colors.white,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              splashColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _getCurrentLocation() async {

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position);

    setState(() {
      _locationMessage = "${position.latitude}, ${position.longitude}";
    });

  }

  Future uploadFile() async{
    if(imageFile == null) {
      return;
    }else{

      final fileName = basename(imageFile.path);
      final destination = 'newfile/image$i';
      print('image nume$i');

      FirebaseApi.uploadFile(destination,imageFile);

    }
  }

}

class FirebaseApi {
  static UploadTask uploadFile(String destination,File file){
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putFile(file);
    } on FirebaseStorage catch(e){
      return null;
    }
  }
}