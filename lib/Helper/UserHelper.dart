import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_firebase/Helper/ContactHelper.dart';
import 'package:flutter_chat_firebase/Helper/RoomHelper.dart';
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

  // This function will update User, Contact and Room collection with Batched writes which mean if anything goes wrong nothing will be wrote
  void updateUserPicture(String userId, User userToUpdate,
      List<DocumentSnapshot> listContacts, List<DocumentSnapshot> listRooms) {
    var db = Firestore.instance;
    var batch = db.batch();
    batch.setData(UserHelper().getUsersCollection().document(userId),
        userToUpdate.toJson(),
        merge: true);
    listContacts.forEach((doc) {
      batch.setData(
          ContactHelper()
              .getContactsCollection()
              .document(doc.reference.parent().parent().documentID)
              .collection(ContactHelper.SUB_COLLECTION_NAME)
              .document(userToUpdate.userId),
          userToUpdate.toJson(),
          merge: true);
    });
    listRooms.forEach((doc) {
      batch.setData(
          RoomHelper()
              .getRoomsCollection()
              .document(doc.reference.parent().parent().documentID)
              .collection(RoomHelper.SUB_COLLECTION_NAME)
              .document(doc.documentID),
          userToUpdate.toJson(),
          merge: true);
    });
    batch.commit();
  }
}
