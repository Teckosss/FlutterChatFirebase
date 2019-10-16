import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_firebase/Models/User.dart';

class RoomHelper {
  static const String _COLLECTION_NAME = "rooms";
  static const String _SUB_COLLECTION_NAME = "userRooms";

  CollectionReference getRoomsCollection() =>
      Firestore.instance.collection(_COLLECTION_NAME);

  CollectionReference getRoomsCollectionForUser(String userId) => RoomHelper()
      .getRoomsCollection()
      .document(userId)
      .collection(_SUB_COLLECTION_NAME);

  void createRoomForUser(String userId, User userToAdd, String roomId) =>
      RoomHelper()
          .getRoomsCollection()
          .document(userId)
          .collection(_SUB_COLLECTION_NAME)
          .document(roomId)
          .setData(userToAdd.toJson(), merge: true);

  Future<QuerySnapshot> getRoomsForUser(String userId) =>
      RoomHelper().getRoomsCollectionForUser(userId).getDocuments();

  Future<QuerySnapshot> checkIfUserIsAlreadyInRoomWithSpecificUser(
          String userId, String userIdToFind) =>
      RoomHelper()
          .getRoomsCollectionForUser(userId)
          .where('uid', isEqualTo: userIdToFind).getDocuments();
}
