import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lunch_menu/Store/store.dart' as store;

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int size = 0;
  Random rand = new Random();
  List<DocumentSnapshot> menu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('메뉴추천'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: ()=>_scaffoldKey.currentState.openDrawer(),
        )
      ),
      drawer: Drawer(
        child: ListView(children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(store.user.getPhoto()),
                  ),
                  title: Text(store.user.getName()),
                  subtitle: Text(store.user.getEmail()),
                ),
                ListTile(
                  leading: FlatButton(
                    child: Text("로그아웃",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: (){
                      Navigator.popUntil(context, ModalRoute.withName('login'));
                      store.user.logout();
                    },
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text("메뉴관리"),
            onTap: ()=>Navigator.pushNamed(context, 'menu_all'),
          ),
        ],),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: store.user.getRef().collection('curr').snapshots(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(
                    child: Text('Loading...'),
                  );
                }
                else if(!snapshot.hasData){
                  return Center(
                    child: Text('메뉴를 등록하세요'),
                  );
                }
                else {
                  menu = snapshot.data.documents;
                  size = menu.length;
                  return ListView.builder(
                    itemCount: menu.length,
                    itemBuilder: (context,index){
                      final item = menu[index].data;
                      return Dismissible(
                        key: Key(item['name']), 
                        child: Card(
                          child: ListTile(
                            title: Text(item['name']),
                          ),
                        ),
                        onDismissed: (direction){
                          // Remove the item from the data source.
                          Firestore.instance.runTransaction((transaction) async {
                            await store.user.getRef().collection('curr').document(item['name']).delete();
                            await store.user.getRef().collection('menu').document(item['name']).setData(item);
                          });
                          // Show a snackbar. This snackbar could also contain "Undo" actions.
                          Scaffold
                              .of(context)
                              .showSnackBar(SnackBar(content: Text(item['name'] + " 삭제됨")));
                        },
                      );
                    }
                  );
                }
              },
            )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Text('추천'),
        backgroundColor: Colors.accents[0],
        onPressed: ()=>showDialog(
          context: context,
          builder: (context){
            int num = rand.nextInt(size);
            return AlertDialog(
              title: ListTile(
                leading: Icon(Icons.sentiment_very_satisfied,color: Colors.yellow,),
                title: Text('오늘은 이거먹어!'),
              ),
              content: ListTile(
                title: Text(menu[num]['name']),
              ),
            );
          }
        ),
      ),
    );
  }
}