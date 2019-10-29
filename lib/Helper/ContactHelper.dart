import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_firebase/Models/User.dart';

class ContactHelper {
  static const String _COLLECTION_NAME = 'contacts';
  static const String SUB_COLLECTION_NAME = 'userContacts';

  CollectionReference getContactsCollection() {
    return Firestore.instance.collection(_COLLECTION_NAME);
  }

  CollectionReference getUserContactCollection(String userId) {
    return ContactHelper()
        .getContactsCollection()
        .document(userId)
        .collection(SUB_COLLECTION_NAME);
  }

  void createUserContact(String fromUser, User toUser) {
    ContactHelper()
        .getContactsCollection()
        .document(fromUser)
        .collection(SUB_COLLECTION_NAME)
        .document(toUser.userId)
        .setData(toUser.toJson(), merge: true);
  }

  Future<QuerySnapshot> getUserContact(String userId, String userIdToFind) {
    return ContactHelper()
        .getUserContactCollection(userId)
        .where('uid', isEqualTo: userIdToFind)
        .getDocuments();
  }

  Future<QuerySnapshot> getAllContactsForUser(String userId) =>
      ContactHelper().getUserContactCollection(userId).getDocuments();

  Query getSpecificContactForUser(String userId, String userIdToFind) =>
      ContactHelper()
          .getUserContactCollection(userId)
          .where('uid', isEqualTo: userIdToFind);

  Future<QuerySnapshot> getAllContactsWhoAreFriendsWithUser(String userId) {
    var db = Firestore.instance;
    return db
        .collectionGroup(SUB_COLLECTION_NAME)
        .where('uid', isEqualTo: userId)
        .getDocuments();
  }

  void updateContact(String userId, User userToUpdate) => ContactHelper()
      .getUserContactCollection(userId)
      .document(userToUpdate.userId)
      .setData(userToUpdate.toJson(), merge: true);
}
