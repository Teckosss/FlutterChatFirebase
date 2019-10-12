class User {
  final String userId;
  final String username;
  final String userPicture;

  User(this.userId, this.username, this.userPicture);

  Map<String, dynamic> toJson() =>
      {'uid': userId, 'username': username, 'userPicture': userPicture};
}
