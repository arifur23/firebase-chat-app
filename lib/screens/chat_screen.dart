import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final String? text;
  late final String? sender = _auth.currentUser!.email;
  FirebaseAuth _auth = FirebaseAuth.instance;
  late final String? loggedUser;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final messageController = TextEditingController();
  late final String? userEmail;

  @override
  void initState() {
    userEmail = _auth.currentUser!.email;
    super.initState();
  }




  // void getMessages() async {
  //   final messages = await _firestore.collection("messages").get();
  //   for(var message in messages.docs ){
  //       print(message.data());
  //   }
  // }

  void getMessageStream() async {
    try {
      await for (var snapshots in _firestore.collection("messages")
          .snapshots()) {
        for (var message in snapshots.docs) {
          print(message.data());
        }
      }
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                try {
                  // _auth.signOut();
                  // Navigator.popAndPushNamed(context, LoginScreen.id);
                }
                catch(e){
                  print(e);
                }
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection("messages").snapshots(),
              builder: (context, snapshot) {
                List<MessageBubble> ownMessageWidgets = [];
                try {
                  if(!snapshot.hasData){
                    return Center(
                      child: Text("There is no data"),
                    );
                  }
                    final messages = snapshot.data!.docs.reversed;
                    for (var message in messages) {
                      final messageText = message.get('text');
                      final messageSender = message.get('sender');

                        final messageWidgetOwn = MessageBubble(sender: messageSender,text: messageText,isMe: messageSender == userEmail );
                        ownMessageWidgets.add(messageWidgetOwn);




                    }
                }
                catch(e){
                  print(e);
                  }
                    return Expanded(
                      child: ListView(
                        reverse: true,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        children: ownMessageWidgets,
                      ),
                    );
              }
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      text = messageController.text;
                      _firestore.collection("messages").add({
                        "text" : text,
                        "sender" : sender,
                      });
                      messageController.clear();
                      print("message sent$text");
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}


class MessageBubble extends StatelessWidget {

  MessageBubble({this.text,this.sender,this.isMe});

  final String? text;
  final String? sender;
  final bool? isMe;


  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(sender!,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black26,
            fontWeight: FontWeight.w300
          ),
          ),
          Material(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
              topLeft: isMe! ? Radius.circular(15) : Radius.circular(0),
              topRight: isMe! ? Radius.circular(0) : Radius.circular(15)
            ),
            elevation: 5.0,
            color: isMe! ? Colors.lightBlueAccent : Colors.white70,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              child: Text('$text',
              style: TextStyle(
                color: isMe! ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 15
              ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

