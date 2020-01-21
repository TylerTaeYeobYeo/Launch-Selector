import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:lunch_menu/Store/store.dart' as store;

class MenuListPage extends StatefulWidget {
  MenuListPage({Key key}) : super(key: key);

  @override
  _MenuListPageState createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  TextEditingController _textEditingController;
  @override
  void initState() {
    super.initState();
    _textEditingController = new TextEditingController();
  }
  
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('메뉴관리'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: ()=>Navigator.popUntil(context, ModalRoute.withName('home')),
        )
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height*0.3,
            child: ListTile(
            leading: Icon(Icons.sentiment_satisfied,color: Colors.yellow,),
            title: StreamBuilder<QuerySnapshot>(
                stream: store.user.getRef().collection('curr').snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(
                      child: Text('Loading...'),
                    );
                  }
                  else {
                    List<DocumentSnapshot> menu = snapshot.data.documents;
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
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: ListTile(
              leading: Icon(Icons.sentiment_satisfied,color: Colors.accents[0],),
              title:  StreamBuilder<QuerySnapshot>(
                stream: store.user.getRef().collection('menu').snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(
                      child: Text('Loading...'),
                    );
                  }
                  else {
                    List<DocumentSnapshot> menu = snapshot.data.documents;
                    return ListView.builder(
                      itemCount: menu.length,
                      itemBuilder: (context,index){
                        final item = menu[index].data;
                        return Dismissible(
                          key: Key(item['name']), 
                          child: Card(
                            child: ListTile(
                              title: Text(item['name']),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_forever,color: Colors.accents[0],),
                                onPressed: ()=>showDialog(
                                  context: context,
                                  builder: (context){
                                    return AlertDialog(
                                      title: Text('경고',style: TextStyle(color: Colors.accents[0]),),
                                      content: ListTile(
                                        title: Text(item['name'] + ' 를 영구제거 하시겠습니까?'),
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text('확인'), onPressed: (){
                                            store.user.getRef().collection('menu').document(item['name']).delete();
                                            Navigator.pop(context);
                                          },
                                        ),
                                        FlatButton(
                                          child: Text('취소',style: TextStyle(color: Colors.accents[0]),), onPressed: ()=>Navigator.pop(context),
                                        )
                                      ],
                                    );
                                  }
                                ),
                              ),
                            ),
                          ),
                          onDismissed: (direction){
                            // Remove the item from the data source.
                            Firestore.instance.runTransaction((transaction) async {
                              await store.user.getRef().collection('curr').document(item['name']).setData(item);
                              await store.user.getRef().collection('menu').document(item['name']).delete();
                            });
                            // Show a snackbar. This snackbar could also contain "Undo" actions.
                            Scaffold
                                .of(context)
                                .showSnackBar(SnackBar(content: Text(item['name'] + " 추가됨")));
                          },
                        );
                      }
                    );
                  }
                },
              ),
            ),
          ),
          ListTile(
            title: TextField(
              maxLength: 10,
              obscureText: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '밥상 추가'
              ),
              controller: _textEditingController,
            ),
            trailing: 
            IconButton(
              icon: Icon(Icons.save),
              color: Colors.accents[0],
              onPressed: (){
                String text = _textEditingController.text;
                var data = {
                  'name': text,
                  'date': DateTime.now(),
                  'count': 0
                };
                store.user.getRef().collection('curr').document(text).setData(data);
                // items.add(data);
                _textEditingController.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}