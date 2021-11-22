import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ndialog/ndialog.dart';
import 'package:todo_six_pm/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  UserModel? userModel;
  DatabaseReference? userRef;

  File? imageFile;
  bool showLocalFile = false;


  _getUserDetails() async {
    DataSnapshot snapshot = await userRef!.once();

    userModel = UserModel.fromMap(Map<String, dynamic>.from(snapshot.value));

    setState(() {});
  }

  _pickImageFromGallery() async {

    XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if( xFile == null ) return;

    final tempImage = File(xFile.path);

    imageFile = tempImage;
    showLocalFile = true;
    setState(() {

    });

    // upload to firebase storage


    ProgressDialog progressDialog = ProgressDialog(
      context,
      title: const Text('Uploading !!!'),
      message: const Text('Please wait'),
    );
    progressDialog.show();
    try{
      var fileName = userModel!.email + '.jpg';

      UploadTask uploadTask = FirebaseStorage.instance.ref().child('profile_images').child(fileName).putFile(imageFile!);

      TaskSnapshot snapshot = await uploadTask;

      String profileImageUrl = await snapshot.ref.getDownloadURL();

      print(profileImageUrl);

      progressDialog.dismiss();

    } catch( e ){
      progressDialog.dismiss();

      print(e.toString());
    }


  }

  _pickImageFromCamera() async {
    XFile? xFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if( xFile == null ) return;

    final tempImage = File(xFile.path);

    imageFile = tempImage;
    showLocalFile = true;
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();

    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userRef =
          FirebaseDatabase.instance.reference().child('users').child(user!.uid);
    }

    _getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: userModel == null
            ? const  Center(child:  CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                            radius: 80,
                            backgroundImage: showLocalFile ?

                                FileImage(imageFile!) as ImageProvider
                                :

                            userModel!.profileImage == ''
                                ? const NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGrQoGh518HulzrSYOTee8UO517D_j6h4AYQ&usqp=CAU')
                                : NetworkImage(userModel!.profileImage)),

                        IconButton(icon: const Icon(Icons.camera_alt), onPressed: (){

                          showModalBottomSheet(context: context, builder: (context){
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.image),
                                    title: const Text('From Gallery'),
                                    onTap: (){
                                      _pickImageFromGallery();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('From Camera'),
                                    onTap: (){

                                      _pickImageFromCamera();
                                      Navigator.of(context).pop();

                                    },
                                  ),
                                ],
                              ),
                            );
                          });

                        },),
                      ],


                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                userModel!.fullName,
                                style: const TextStyle(fontSize: 18),
                              ),
                              Text(
                                userModel!.email,
                                style: const TextStyle(fontSize: 18),
                              ),
                              Text(
                                'Joined ${getHumanReadableDate(userModel!.dt)}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }

  String getHumanReadableDate(int dt) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dt);

    return DateFormat('dd MMM yyyy').format(dateTime);
  }
}
