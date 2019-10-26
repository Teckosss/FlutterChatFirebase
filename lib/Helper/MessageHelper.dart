import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_firebase/Models/Message.dart';

class MessageHelper {
  static const String _COLLECTION_NAME = 'messages';
  static const String _SUB_COLLECTION_NAME = 'roomMessages';

  CollectionReference getMessageCollection() =>
      Firestore.instance.collection(_COLLECTION_NAME);

  CollectionReference getRoomMessagesCollection(String roomId) =>
      MessageHelper()
          .getMessageCollection()
          .document(roomId)
          .collection(_SUB_COLLECTION_NAME);

  DocumentReference createMessageDocument() =>
      MessageHelper().getMessageCollection().document();

  void createNewMessage(String roomId, String messageText, String senderId) =>
      MessageHelper()
          .getRoomMessagesCollection(roomId)
          .add(Message(messageText, senderId).toJson());

  Stream<QuerySnapshot> getAllMessagesInRoom(String roomId) => MessageHelper()
      .getRoomMessagesCollection(roomId)
      .orderBy('sendAt', descending: true)
      .limit(20)
      .snapshots();
}
