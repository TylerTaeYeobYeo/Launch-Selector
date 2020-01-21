import 'package:flutter/material.dart';

import 'package:lunch_menu/Store/store.dart' as store;

class LoginPage extends StatelessWidget {
  LoginPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text("점심 뭐 먹을까?"),
            FlatButton(
              child: Text("로그인"),
              onPressed: () async {
                if(await store.user.login()){
                  Navigator.pushNamed(context, 'home');
                }
              },
            )
          ],
        ),
      ),
    );
  }
}