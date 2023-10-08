import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_app/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Firestore
  final firestoreService = FirestoreService();
  //text controller
  final textController = TextEditingController();
  //open dialog when click on button
  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          //button to save note
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                //add a new note
                firestoreService.addNote(textController.text);
              } else {
                //update the note
                firestoreService.updateNote(docID, textController.text);
              }

              //clear text
              textController.clear();

              //close the box
              Navigator.pop(context);
            },
            child: Text(docID == null ? 'Add' : 'Edit'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Notes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          //if have data, get all the docs
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;

            //display the list
            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = noteList[index];
                String docID = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                String note = data['note'];

                return buildListTile(note: note, docID: docID);
              },
            );
          }
          //if no data return nothing :))
          else {
            return const Center(child: Text('Waiting for notes.....'));
          }
        },
      ),
    );
  }

  //build a Listtile
  Widget buildListTile({required String note, required String docID}) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
          title: Text(note),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => openNoteBox(docID: docID),
              ),
              IconButton(
                onPressed: () => firestoreService.deleteNote(docID),
                icon: const Icon(Icons.delete),
              )
            ],
          )),
    );
  }
}
