import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageText;
  final String fromUser;
  final FieldValue sendAt = FieldValue.serverTimestamp();

  Message(this.messageText, this.fromUser);

  Map<String, dynamic> toJson() =>
      {'messageText': messageText, 'fromUser': fromUser, 'sendAt': sendAt};
}
