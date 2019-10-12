import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_firebase/Models/User.dart';

class UserHelper {
  static const String _COLLECTION_NAME = "users";

  CollectionReference _getUsersCollection() {
    return Firestore.instance.collection(_COLLECTION_NAME);
  }

  void createUser(String userId, String username, String userPicture) =>
      UserHelper()
          ._getUsersCollection()
          .document(userId)
          .setData(User(userId, username, userPicture).toJson());

  void getUser(String id) =>
      UserHelper()._getUsersCollection().document(id).get();
}
