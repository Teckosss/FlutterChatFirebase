import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

abstract class BaseUpload {
  Future<String> uploadProfilePic(String userId, File imageFile);
}

class Upload extends BaseUpload {


  @override
  Future<String> uploadProfilePic(String userId, File imageFile) async {
    var uuid = Uuid();
    StorageReference storageReference = FirebaseStorage.instance.ref().child("images/$userId/${uuid.v1()}.jpg");
    StorageUploadTask storageUploadTask = storageReference.putFile(imageFile);
    final StorageTaskSnapshot downloadUrl =
    (await storageUploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    return url;
  }
}