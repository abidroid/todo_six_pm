import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
import 'package:todo_six_pm/screens/signup_screen.dart';
import 'package:todo_six_pm/screens/task_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Please'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
             TextField(
               controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
              ),
            ),
            const SizedBox(height: 10,),

             TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
            ),

            const SizedBox(height: 10,),

            ElevatedButton(onPressed: () async {

              var email = emailController.text.trim();
              var password = passwordController.text.trim();
              if( email.isEmpty || password.isEmpty ){
                // show error toast
                Fluttertoast.showToast(msg: 'Please fill all fields');
                return;
              }

              // request to firebase auth

              ProgressDialog progressDialog = ProgressDialog(
                context,
                title: const  Text('Logging In'),
                message: const Text('Please wait'),
              );

              progressDialog.show();

              try{

                FirebaseAuth auth = FirebaseAuth.instance;

                UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);

                if( userCredential.user != null ){


                   progressDialog.dismiss();
                   Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){

                     return const TaskListScreen();
                   }));
                }



              }
              on FirebaseAuthException catch ( e ) {

                progressDialog.dismiss();

                if( e.code == 'user-not-found'){
                  Fluttertoast.showToast(msg: 'User not found');

                }else if( e.code == 'wrong-password'){
                  Fluttertoast.showToast(msg: 'Wrong password');

                }

              }
              catch(e){
                Fluttertoast.showToast(msg: 'Something went wrong');
                progressDialog.dismiss();
              }


            }, child:const  Text('Login')),

            const SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Not Registered Yet'),
                TextButton(onPressed: (){

                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return SignUpScreen();
                  }));
                }, child: Text('Register Now')),
              ],
            )
          ],
        ),
      ),
    );
  }
}