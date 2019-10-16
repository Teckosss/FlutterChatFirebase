import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_firebase/Models/User.dart';

class UserHelper {
  static const String _COLLECTION_NAME = "users";

  CollectionReference getUsersCollection() {
    return Firestore.instance.collection(_COLLECTION_NAME);
  }

  void createUser(String userId, String username, String userPicture,
          Map<String, bool> rooms) =>
      UserHelper()
          .getUsersCollection()
          .document(userId)
          .setData(User(userId, username, userPicture, rooms).toJson());

  Future<DocumentSnapshot> getUser(String id) =>
      UserHelper().getUsersCollection().document(id).get();

  Query getUserByUsername(String username) =>
      UserHelper().getUsersCollection().where('username', isEqualTo: username);

  void updateUser(String userId, User userToUpdate) => UserHelper()
      .getUsersCollection()
      .document(userId)
      .setData(userToUpdate.toJson(), merge: true);
}
