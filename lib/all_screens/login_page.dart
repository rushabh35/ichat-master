import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ichat_app/allProviders/auth_providers.dart';
import 'package:ichat_app/allWidgets/loading_view.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch(authProvider.status){
      case Status.authenticateError : Fluttertoast.showToast(msg : "SignIn Fail");
        break;
      case Status.authenticateCanceled : Fluttertoast.showToast(msg: "SignIn Cancelled");
        break;
      case Status.authenticated : Fluttertoast.showToast(msg: "Signed In Successfully");
        break;
      default:
        break;
    }
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Image.asset(
              "images/back.png",
            ),
          ),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () async{
                bool isSuccess = await authProvider.handleSignIn();
                if(isSuccess){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                }
              },
              child: Image.asset(
                "images/google_login.jpg",
              ),
            ),
          ),
          // Positioned(
          //     child: authProvider.status == Status.authenticating ? LoadingView(): SizedBox.shrink(),
          // ),
        ],
      ),
    );
  }
}
