import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:paradox/models/user.dart';
import 'package:paradox/utilities/constant.dart';

class UserProvider extends ChangeNotifier {
  /// Instance of [User] for currently loggedIn User.
  User user;

  /// Create new [User] and assign it to [user].
  void assignUser(String uid, String email, String name) {
    user = new User(email: email, uid: uid, name: name);
  }

  /// This function creates new User in the backend.
  void createUser(String uid, String email, String displayName) async {
    final String postUrl = "${baseUrl}user/";

    /// Sending Request to backend with [google_id], [name], [email] to create new User.
    Response postResponse = await post(
      postUrl,
      body: jsonEncode(<String, String>{
        'google_id': uid,
        'name': displayName,
        'email': email
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );

    if (postResponse.statusCode == 201) {
      var body = jsonDecode(postResponse.body);

      /// Response Body contains a field [ref_code] assigning it to ref_code of [user].
      user.referralCode = body['ref_code'];
      notifyListeners();
    } else if (postResponse.statusCode == 400) {
      print('some error');
    }
  }

  /// This function is used to fetch details of User from backend and assign it to user.
  void fetchUserDetails() async {
    if (user.uid == null) {
      return;
    }
    String url = "${baseUrl}userProfile/${user.uid}/";
    Response response = await get(url);
    if (response.statusCode == 200) {
      var userProfile = jsonDecode(response.body);
    }
  }


  /// Check whether a present in backend or not using the uid provided by firebase on authentication.
  Future<bool> userIsPresent() async {
    try {
      final String getUrl = "${baseUrl}user-present-or-not/${user.uid}";
      Response getResponse = await get(getUrl);
      if (getResponse.statusCode == 404) {
        return false;
      } else if (getResponse.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      throw Exception();
    }
  }
}
