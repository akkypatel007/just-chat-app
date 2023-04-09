import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:just/common/entities/user.dart';
import 'package:just/common/routes/routes.dart';
import 'package:just/common/store/user.dart';
import 'package:just/pages/frame/sign_in/state.dart';

import '../../../common/apis/user.dart';
import '../../../common/widgets/toast.dart';

class SignInController extends GetxController {
  SignInController();
  final state = SignInState();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['openid'],
    // clientId:
    //     '1073276176959-bcs8b5bo6c2d7bpdibqs45duc31bbdeb.apps.googleusercontent.com',
  );

  Future<void> handleSignIn(String type) async {
    ///1:email,2:google,3:facebook,4:apple,5:phone
    try {
      if (type == "phone number") {
        if (kDebugMode) {
          print("...you are logging in with phone number...");
        }
      } else if (type == "google") {
        var user = await _googleSignIn.signIn();
        if (user != null) {
          final _gAuthentication = await user.authentication;
          final _credential = GoogleAuthProvider.credential(
              idToken: _gAuthentication.idToken,
              accessToken: _gAuthentication.accessToken);
          print("....${_gAuthentication.accessToken}...");
          await FirebaseAuth.instance.signInWithCredential(_credential);
          String? displayName = user.displayName;
          String email = user.email;
          String id = user.id;
          String photourl = user.photoUrl ?? "assets/icons/google.png";
          LoginRequestEntity loginPanelListRequestEntity = LoginRequestEntity();
          loginPanelListRequestEntity.avatar = photourl;
          loginPanelListRequestEntity.name = displayName;
          loginPanelListRequestEntity.email = email;
          loginPanelListRequestEntity.open_id = id;
          loginPanelListRequestEntity.type = 2;
          print(jsonEncode(loginPanelListRequestEntity));
          asyncPostAllData(loginPanelListRequestEntity);
        }
      } else {
        if (kDebugMode) {
          print("...login type not sure...");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('...error with login $e');
      }
    }
  }

  asyncPostAllData(LoginRequestEntity loginRequestEntity) async {
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);
    var result = await UserApi.Login(params: loginRequestEntity);

    if (result.code == 0) {
      await UserStore.to.saveProfile(result.data!);
      EasyLoading.dismiss();
      toastInfo(msg: "Internet error");
      Fluttertoast.showToast(
        msg: 'Internet error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
    Get.offAllNamed(AppRoutes.Message);
  }
}
