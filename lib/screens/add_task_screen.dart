import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {

  var taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
             TextField(
              controller: taskController,
              decoration: const InputDecoration(
                hintText: 'Task Name'
              ),
            ),

            const SizedBox(height: 10,),

            ElevatedButton(onPressed: () async{

              String taskName = taskController.text.trim();

              if( taskName.isEmpty){
                Fluttertoast.showToast(msg: 'Please provide task name');
                return;
              }

              User? user = FirebaseAuth.instance.currentUser;

              if( user != null ){

                String uid = user.uid;
                int dt = DateTime.now().millisecondsSinceEpoch;

                DatabaseReference taskRef = FirebaseDatabase.instance.reference().child('tasks').child(uid);

                String taskId = taskRef.push().key;

                await taskRef.child(taskId).set(
                  {
                    'dt': dt,
                    'taskName': taskName,
                    'taskId': taskId,
                  }
                );

              }

              }, child: const Text('Save')),

          ],
        ),
      ),
    );
  }
}
