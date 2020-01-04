import 'package:flutter/material.dart';
import 'package:chat_app/services/firebase.dart';

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
        child: ListView(
      children: <Widget>[
        Message(),
        Message(),
        Message(),
        Message(),
      ],
    ));
  }
}

class Form extends StatefulWidget {
  @override
  _FormState createState() => _FormState();
}

class _FormState extends State<Form> {
  bool _isComposing = false;
  TextEditingController _textController = TextEditingController();
  String imageUrl;

  submit() {
    final text = _textController.text;
    _textController.clear();
    setState(() => _isComposing = false);
    sendToFirebase(text: text, imageUrl: imageUrl);
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
                onPressed: () {},
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
                  hintText: "Insira aqui o texto!",
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
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Caboclo 1',
                style: Theme.of(context).textTheme.subtitle,
              ),
              Text(
                'Mensagem aushduiahsd',
                style: Theme.of(context).textTheme.subhead,
              ),
            ],
          )
        ],
      ),
    );
  }
}
