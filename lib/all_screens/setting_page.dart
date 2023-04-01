import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ichat_app/allConstants/app_constants.dart';
import 'package:ichat_app/allConstants/constants.dart';
import 'package:ichat_app/allModels/user_chat.dart';
import 'package:ichat_app/allProviders/settings_provider.dart';
import 'package:ichat_app/main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../allConstants/color_constants.dart';
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isWhite ? Colors.white : Colors.black,
        iconTheme: IconThemeData(
          color: ColorConstants.primaryColor,
        ),
        title: Text(
          AppConstants.settingsTitle,
          style: TextStyle(
              color: ColorConstants.primaryColor
          ),
        ),
        centerTitle: true,
      ),
    );
  }
}

class SettingsPageState extends StatefulWidget {
  const SettingsPageState({Key? key}) : super(key: key);

  @override
  State<SettingsPageState> createState() => _SettingsPageStateState();
}

class _SettingsPageStateState extends State<SettingsPageState> {

  TextEditingController? controllerNickname;
  TextEditingController? controllerAboutMe;

  String dialCodeDigits = "+91";
  final TextEditingController _controller = TextEditingController();

  String id='';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';
  String phoneNumber = '';


  bool isLoading = false;
  File ? avatarImageFile;
  late SettingProvider settingProvider;

  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    settingProvider = context.read<SettingProvider>();
    readLocal();
  }

  void readLocal() {
    setState(() {
      id = settingProvider.getPref(FirestoreConstants.id) ?? "" ;
      nickname = settingProvider.getPref(FirestoreConstants.nickname) ?? "" ;
      aboutMe = settingProvider.getPref(FirestoreConstants.aboutMe) ?? "" ;
      photoUrl = settingProvider.getPref(FirestoreConstants.photoUrl) ?? "" ;
      phoneNumber = settingProvider.getPref(FirestoreConstants.phoneNumber) ?? "" ;
    });

    controllerNickname =  TextEditingController(
      text: nickname
    );

    controllerAboutMe = TextEditingController(
      text: aboutMe
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile = await imagePicker.getImage(
        source: ImageSource.gallery).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async{
    String fileName = id;
    UploadTask uploadTask  = settingProvider.uploadFile(avatarImageFile! , fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();

      UserChat updateInfo = UserChat(
          id: id,
          photoUrl: photoUrl,
          nickname: nickname,
          phoneNumber: phoneNumber,
          aboutMe: aboutMe
      );
      settingProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, id, updateInfo.toJson()).then((data)
          async{
            await  settingProvider.setPref(FirestoreConstants.photoUrl, photoUrl);
            setState(() {
              isLoading = false;
            });
          }).catchError((err){
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: err.toString());
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }


  void handleUpdateData() {
  focusNodeAboutMe.unfocus();
  focusNodeNickname.unfocus();
  setState(() {
    isLoading = true;
    if(dialCodeDigits!="+91" && _controller.text!=""){
      phoneNumber = dialCodeDigits + _controller.text.toString();
    }
  });
  UserChat updateInfo = UserChat(
    id: id,
    photoUrl: photoUrl,
    nickname: nickname,
    phoneNumber: phoneNumber,
    aboutMe: aboutMe
  );
  settingProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, id, updateInfo.toJson()).then((data) async {
    await settingProvider.setPref(FirestoreConstants.nickname, nickname);
    await settingProvider.setPref(FirestoreConstants.aboutMe, aboutMe);
    await settingProvider.setPref(FirestoreConstants.photoUrl, photoUrl);
    await settingProvider.setPref(FirestoreConstants.phoneNumber, phoneNumber);

    setState(() {
      isLoading = false;
    });
    Fluttertoast.showToast(msg: "Update Success");
  }).catchError((err){
    setState(() {
      isLoading = false;
    });

    Fluttertoast.showToast(msg: err.toString());
  });
}
  @override
  Widget build(BuildContext context) {
    return Container();
  }


}

