import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ichat_app/allProviders/auth_providers.dart';
import 'package:ichat_app/all_screens/setting_page.dart';
import 'package:provider/provider.dart';

import '../allConstants/color_constants.dart';
import '../allModels/popup_choices.dart';
import '../main.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();
  int _limit = 20;
  int _limitIncrement = 20;
  String textSearch = "";
  bool isLoading = false;
  late String currentUserid;
  late AuthProvider authProvider;
  // late HomeProvider homeProvider;
  List<PopupChoices> choices = <PopupChoices> [
    PopupChoices(title: 'Settings', icon: Icons.settings),
    PopupChoices(title: 'Sign Out', icon: Icons.exit_to_app),
  ];

  Future<void> handleSignOut() async {
    authProvider.handleSignOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void scrollListener() {
    if(listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange){
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }
  void onItemMenuPress(PopupChoices choice) {
    if(choice.title == "Sign Out"){
      handleSignOut();
    }else{
      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
    }
  }

  Widget buildPopUpMenu(){
    return PopupMenuButton<PopupChoices>(
      icon: Icon(Icons.more_vert ,color: Colors.grey,),
        onSelected: onItemMenuPress,
        itemBuilder: (BuildContext context){
          return choices.map((PopupChoices choice){
            return PopupMenuItem<PopupChoices>(
              value : choice,
              child : Row(
                children:<Widget> [
                  Icon(
                    choice.icon,
                    color: ColorConstants.primaryColor
                  ),
                  Container(
                    width : 10,
                  ),
                  Text(
                    choice.title,
                    style: TextStyle(
                      color: ColorConstants.primaryColor,
                    ),
                  )
                ],
              )
            );
          }
          ).toList();
        }
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    authProvider = context.read<AuthProvider>();

    if(authProvider.getUserFirebaseId() ?. isNotEmpty == true) {
      currentUserid = authProvider.getUserFirebaseId()!;
    }else{
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
      );
    }
    listScrollController.addListener(scrollListener);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite?Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isWhite ? Colors.white : Colors.black,
        leading : IconButton(
          icon : Switch(
            value: isWhite,
            onChanged : (value) {
              setState(() {
                isWhite = value;
                print(isWhite);
              });
            },
            activeTrackColor: Colors.grey,
            activeColor: Colors.white,
            inactiveThumbColor: Colors.black45,
            inactiveTrackColor: Colors.grey,
          ),
          onPressed: () =>"",
        ),
        actions: <Widget>[
          buildPopUpMenu(),
        ],
      ),
    );
  }
}
