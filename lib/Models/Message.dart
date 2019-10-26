import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageText;
  final String fromUser;
  Timestamp sendAt = Timestamp.now();

  Message(this.messageText, this.fromUser);

  Map<String, dynamic> toJson() =>
      {'messageText': messageText, 'fromUser': fromUser, 'sendAt': sendAt};

  Message.fromMap(Map<String, dynamic> data)
      : messageText = data['messageText'],
        fromUser = data['fromUser'],
        sendAt = data['sendAt'];

  @override
  String toString() {
    return 'Message{messageText: $messageText, fromUser: $fromUser, sendAt: $sendAt}';
  }


}
