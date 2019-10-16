class User {
  final String userId;
  String username;
  String userPicture;
  Map<String, bool> rooms;

  User(this.userId, this.username, this.userPicture, this.rooms);

  Map<String, dynamic> toJson() => {
        'uid': userId,
        'username': username,
        'userPicture': userPicture,
        'rooms': rooms
      };

  User.fromMap(Map<String, dynamic> data, String id)
      : userId = id,
        username = data['username'],
        userPicture = data['userPicture'],
        rooms = data['rooms'] != null ? new Map<String, bool>.from(data['rooms']) : null;

  @override
  String toString() {
    return 'User{userId: $userId, username: $username, userPicture: $userPicture, rooms: $rooms}';
  }


}
