import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String photoUrl;

  UserModel({this.id, this.displayName, this.email, this.photoUrl});

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
        id: doc["id"],
        displayName: doc["displayName"],
        email: doc["email"],
        photoUrl: doc["photoUrl"]);
  }
}
