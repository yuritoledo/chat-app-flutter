import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/services/firebase.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
        primaryColor: Colors.deepPurple,
        accentColor: Colors.orange,
        iconTheme: IconThemeData(color: Colors.white, size: 28.0)),
    title: "Chat app",
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat app'),
        centerTitle: true,
        elevation: 10.0,
      ),
      body: Container(
        child: Column(
          children: <Widget>[ListMessages(), Divider(), Form()],
        ),
      ),
    );
  }
}

class ListMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: firestore
            .collection('messages')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
            case ConnectionState.active:
              return ListView.builder(
                reverse: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, int index) =>
                    Message(snapshot.data.documents[index].data),
              );
            default:
              return Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}

class Form extends StatefulWidget {
  @override
  _FormState createState() => _FormState();
}

class _FormState extends State<Form> {
  bool _isComposing = false;
  TextEditingController _textController = TextEditingController();
  String _imageUrl;

  submit() {
    final text = _textController.text;
    _textController.clear();
    setState(() => _isComposing = false);
    sendToFirebase(text: text, imageUrl: _imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: <Widget>[
            Container(
              child: IconButton(
                icon: Icon(Icons.photo_camera),
                onPressed: () async {
                  File image =
                      await ImagePicker.pickImage(source: ImageSource.camera);

                  await ensureLoggedIn();

                  StorageUploadTask uploadTask = FirebaseStorage.instance
                      .ref()
                      .child(googleSignIn.currentUser.id +
                          DateTime.now().toString())
                      .putFile(image);

                  final imageUrl =
                      await (await uploadTask.onComplete).ref.getDownloadURL();

                  setState(() => _imageUrl = imageUrl);
                  submit();
                },
              ),
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                onChanged: (text) {
                  setState(() => _isComposing = text.isNotEmpty);
                },
                onSubmitted: (text) => submit(),
                decoration: InputDecoration.collapsed(
                  hintText: "Insira aqui",
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: _isComposing ? submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message extends StatelessWidget {
  final Map<String, dynamic> _data;

  Message(this._data);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(_data['senderPhoto']),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _data['senderName'],
                style: Theme.of(context).textTheme.subtitle,
              ),
              _data['imageUrl'] != null
                  ? Image.network(
                      _data['imageUrl'],
                      height: 250,
                      width: 250,
                    )
                  : Text(
                      _data['textMessage'],
                      style: Theme.of(context).textTheme.subhead,
                    ),
            ],
          )
        ],
      ),
    );
  }
}
