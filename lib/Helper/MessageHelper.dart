import 'package:cloud_firestore/cloud_firestore.dart';

class MessageHelper {
  static const String _COLLECTION_NAME = 'messages';

  CollectionReference getMessageCollection() {
    return Firestore.instance.collection(_COLLECTION_NAME);
  }

  DocumentReference createMessageDocument() =>
      MessageHelper().getMessageCollection().document();
}