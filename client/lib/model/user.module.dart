import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class UserModel extends Equatable {
  String? key;
  String? email;
  String? userId;
  String? bio;
  String? localisation;
  String? userName;
  String? displayName;
  String? profilePic;
  String? createAt;
  String? fcmToken;
  int? daily;
  int? weekly;
  bool? picture_taken;
  List<String>? followersList;
  List<String>? followingList;

  UserModel(
      {this.email,
      this.key,
      this.userName,
      this.localisation,
      this.bio,
      this.userId,
      this.displayName,
      this.profilePic,
      this.createAt,
      this.followingList,
      this.followersList,
      this.daily,
      this.weekly,
      this.picture_taken,
      this.fcmToken});

  UserModel.fromJson(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return;
    }
    followersList ??= [];
    email = map['email'];
    userId = map['userId'];
    userName = map['userName'];
    displayName = map['displayName'];
    localisation = map['localisation'];
    bio = map['bio'];
    profilePic = map['profilePic'];
    key = map['key'];
    createAt = map['createAt'];
    fcmToken = map['fcmToken'];
    daily = map['daily'];
    weekly = map['weekly'];
    picture_taken = map['picture_taken'];
    if (map['followingList'] != null) {
      followingList = <String>[];
      map['followingList'].forEach((value) {
        followingList!.add(value);
      });
    }
  }
  toJson() {
    return {
      'key': key,
      "userId": userId,
      "userName": userName,
      "bio": bio,
      "localisation": localisation,
      "email": email,
      'displayName': displayName,
      'createAt': createAt,
      'profilePic': profilePic,
      'fcmToken': fcmToken,
      'followerList': followersList,
      'followingList': followingList,
      'daily': daily,
      'weekly': weekly,
      'picture_taken': picture_taken,
    };
  }

  UserModel copyWith({
    String? email,
    String? userId,
    String? userName,
    String? displayName,
    String? profilePic,
    String? createAt,
    String? bio,
    String? localisation,
    String? key,
    String? fcmToken,
    int? daily,
    int? weekly,
    bool? picture_taken,
    List<String>? followingList,
    List<String>? followersList,
  }) {
    return UserModel(
      email: email ?? this.email,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      displayName: displayName ?? this.displayName,
      profilePic: profilePic ?? this.profilePic,
      createAt: createAt ?? this.createAt,
      bio: bio ?? this.bio,
      localisation: localisation ?? this.localisation,
      key: key ?? this.key,
      fcmToken: fcmToken ?? this.fcmToken,
      followersList: followersList ?? this.followersList,
      followingList: followingList ?? this.followingList,
      daily: daily ?? this.daily,
      weekly: weekly ?? this.weekly,
      picture_taken: picture_taken ?? this.picture_taken,
    );
  }

  @override
  List<Object?> get props => [
        key,
        email,
        bio,
        localisation,
        userName,
        userId,
        createAt,
        displayName,
        fcmToken,
        profilePic,
        followersList,
        followingList,
        daily,
        weekly,
        picture_taken
      ];
}
