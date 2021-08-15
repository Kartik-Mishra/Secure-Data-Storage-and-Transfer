import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:story/speedDialButton.dart';
import 'dart:math';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:story/encryptor.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  FirebaseUser user;
  // User user;
  StreamSubscription<QuerySnapshot> subscription;
  List<DocumentSnapshot> story;
  // final CollectionReference collectionReference =
  //     Firestore.instance.collection("StoryFeed");
  CollectionReference collectionReference;
  // FirebaseMessaging messaging = new FirebaseMessaging();
  String plainText, title;
  TextEditingController tec3, tec4, tec1, tec2;
  static String msg, data;

  void signin() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gsa = await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: gsa.accessToken, idToken: gsa.idToken);
    user = await auth.signInWithCredential(credential);

    setState(() {});
  }

  void getin() async {
    if (auth.currentUser() != null) {
      user = await auth.currentUser().then((user) {
        collectionReference = Firestore.instance
            .collection("Secure Collection/" + user.email + "/Text");
        subscription =
            collectionReference.snapshots().listen((documentSnapshot) {
          setState(() {
            story = documentSnapshot.documents;
            //     .where((element) {
            //   if (element.data['name'] != 'Kartik Mishra') {
            //     return true;
            //   } else
            //     return false;
            // });
          });
        });
        return user;
      });

      setState(() {});
    }
  }

  void signout() async {
    googleSignIn.signOut();
    user = null;
    print("Signed out");
    setState(() {});
  }

  void init() {
    CollectionReference collectionReference = Firestore.instance
        .collection("Secure Collection/" + user.email + "/Text");
    subscription = collectionReference.snapshots().listen((documentSnapshot) {
      setState(() {
        story = documentSnapshot.documents;
        //     .where((element) {
        //   if (element.data['name'] != 'Kartik Mishra') {
        //     return true;
        //   } else
        //     return false;
        // });
      });
    });
    DocumentReference documentReference1 =
        Firestore.instance.document("Secure Collection/" + user.email);
    Map data1 = <String, dynamic>{'Name': user.displayName};
    documentReference1.setData(data1);
  }

  @override
  void initState() {
    super.initState();
    getin();
    // if (user == null) {
    //   signin();
    // }
    // CollectionReference collectionReference = init();
    title = "Untitled";
    // subscription = collectionReference.snapshots().listen((documentSnapshot) {
    //   setState(() {
    //     story = documentSnapshot.documents;
    //     //     .where((element) {
    //     //   if (element.data['name'] != 'Kartik Mishra') {
    //     //     return true;
    //     //   } else
    //     //     return false;
    //     // });
    //   });
    // });

    // DocumentReference documentReference =
    // collectionReference.document(user.email);
    // messaging.configure(
    //   onLaunch: (Map<String, dynamic> message) {
    //     print(message);
    //   },
    //   onResume: (Map<String, dynamic> message) {
    //     print(message);
    //   },
    //   onMessage: (Map<String, dynamic> message) {
    //     print(message);
    //   },
    // );
    // messaging.getToken().then((token) {
    //   print("the token is ${token}");
    // });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  void addPost(String s) {
    var now = DateTime.now();
    Map data = <String, dynamic>{
      'story': s,
      'name': user.displayName,
      'img': user.photoUrl,
      'likes': 0,
      'datetime':
          "${now.hour}:${now.minute} | ${now.day}-${now.month}-${now.year}"
    };
    DocumentReference reference =
        Firestore.instance.document("StoryFeed/" + "${now.toLocal()}");
    reference.setData(data);

    // print("${now.toLocal()}");
  }

  void deleteNote(int i) {
    story[i].reference.delete();
    setState(() {});
  }

  void upload() {
    var now = DateTime.now();

    Map data1 = <String, dynamic>{
      "Title": title == "" ? "Untitled" : title,
      "Data": data,
      'datetime':
          "${now.hour}:${now.minute} | ${now.day}-${now.month}-${now.year}"
    };
    DocumentReference documentReference1 =
        Firestore.instance.document("Secure Collection/" + user.email);
    Map data2 = <String, dynamic>{'Name': user.displayName};
    documentReference1.setData(data2);

    DocumentReference documentReference = Firestore.instance.document(
        "Secure Collection/" + user.email + "/Text/" + "${now.toLocal()}");
    documentReference.setData(data1);
  }

  void liked(int l, int i) {
    Map dat = <String, dynamic>{'likes': story[i].data['likes'] + l};
    String id = story[i].documentID;
    print(id);
    DocumentReference reference =
        Firestore.instance.document("StoryFeed/${id}");
    reference.updateData(dat);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    tec3 = new TextEditingController();
    tec4 = new TextEditingController();
    tec1 = new TextEditingController();
    tec2 = new TextEditingController();
    int factor = 1;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title: Text('Secure Store'),
            actions: <Widget>[
              IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Encryptor()));
                  },
                  icon: Icon(Icons.security)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: user != null
                      ? NetworkImage(user.photoUrl)
                      : AssetImage("assets/e.png"),
                  radius: 20,
                ),
              )
            ],
            bottom: TabBar(indicatorWeight: 3, tabs: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(Icons.pages,
                    color: Color.fromARGB(255, 255, 255, 255)),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(Icons.enhanced_encryption,
                    color: Color.fromARGB(255, 255, 255, 255)),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(
                  Icons.edit,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              )
            ]),
          ),
          floatingActionButton: dialer(backgroundColor: Colors.blue, children: [
            new dialChild(
              backgroundColor: Colors.lightBlue,
              text: "New User",
              onPressed: () {
                signout();
                signin();
                setState(() {});
              },
              icon: Icons.person_add,
            ),
            dialChild(
                backgroundColor: Colors.lightBlue,
                text: "New Note",
                icon: Icons.note_add,
                onPressed: () {
                  print("object");
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("Create Note!"),
                            content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: new TextField(
                                      controller: tec1,
                                      decoration:
                                          InputDecoration(hintText: "Title"),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: new TextField(
                                        controller: tec2,
                                        decoration:
                                            InputDecoration(hintText: "Note")),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Key",
                                            style: TextStyle(fontSize: 15),
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 50,
                                          child: new TextField(
                                            maxLength: 3,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            controller: tec3,
                                            decoration:
                                                InputDecoration(hintText: "P"),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 50,
                                          child: new TextField(
                                            maxLength: 3,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            controller: tec4,
                                            decoration:
                                                InputDecoration(hintText: "Q"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                            // TextField(
                            //   maxLength: 100,
                            //   maxLines: 5,
                            //   controller: tec,
                            //   decoration: new InputDecoration(
                            //     hintText: "Write your story here",
                            //   ),
                            // ),
                            actions: <Widget>[
                              MaterialButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              MaterialButton(
                                child: Text("Note!"),
                                onPressed: () {
                                  // addPost(tec.text);
                                  title = tec1.text;
                                  plainText = tec2.text;
                                  p = int.parse(tec3.text);
                                  q = int.parse(tec4.text);
                                  myencrypt(plainText);
                                  upload();
                                  setState(() {});

                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ));
                })
          ]),
          body: TabBarView(
            children: [
              Container(
                color: Colors.blueGrey[100],
                child: user == null
                    ? new AlertDialog(
                        title: Text("No user Found!"),
                        content:
                            Text("Please SignIn to with Google to continue."),
                        actions: <Widget>[
                          MaterialButton(
                            elevation: 8,
                            child: Text("Signin"),
                            onPressed: () {
                              signin();
                              init();
                            },
                          ),
                        ],
                      )
                    : new ListView.builder(
                        // reverse: true,
                        itemCount: story.length,
                        itemBuilder: (context, i) {
                          // i = story.length - i - 1;
                          // String name = story[i].data['name'];
                          // String url = story[i].data['img'];
                          // int likes = story[i].data['likes'];
                          // String date = story[i].data['datetime'];
                          // String post = story[i].data['story'];
                          String name = story[i].data['Title'];
                          String date = story[i].data['datetime'];
                          String post = story[i].data['Data'];
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 5, left: 6, right: 16, bottom: 20),
                            child: new Material(
                              elevation: 10,
                              borderRadius: new BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              child: new Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      new Row(
                                        children: <Widget>[
                                          // Padding(
                                          //   padding: const EdgeInsets.only(
                                          //       top: 4, left: 5, bottom: 0),
                                          //   child: new CircleAvatar(
                                          //     radius: 10,
                                          //     backgroundImage:
                                          //         NetworkImage(url),
                                          //   ),
                                          // ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 3, top: 4),
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 3, right: 6),
                                        child: Text(
                                          date,
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w200,
                                              fontSize: 13),
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 28),
                                    child: Divider(
                                      color: Colors.grey,
                                      indent: 28,
                                      height: 5,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, top: 5, bottom: 10),
                                    child: Text(
                                      post,
                                      maxLines: 3,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  //-----------------------------------------------------------------------------
                                  Divider(
                                    color: Colors.blue,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 6.0, bottom: 4),
                                        child: GestureDetector(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Icon(Icons.visibility),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Decrypt",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.green),
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: Text("Enter Key"),
                                                      content: Row(
                                                        children: [
                                                          Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                "Key",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15),
                                                              )),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Container(
                                                              width: 50,
                                                              child:
                                                                  new TextField(
                                                                maxLength: 3,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                inputFormatters: <
                                                                    TextInputFormatter>[
                                                                  FilteringTextInputFormatter
                                                                      .digitsOnly
                                                                ],
                                                                controller:
                                                                    tec1,
                                                                decoration:
                                                                    InputDecoration(
                                                                        hintText:
                                                                            "P"),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Container(
                                                              width: 50,
                                                              child:
                                                                  new TextField(
                                                                maxLength: 3,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                inputFormatters: <
                                                                    TextInputFormatter>[
                                                                  FilteringTextInputFormatter
                                                                      .digitsOnly
                                                                ],
                                                                controller:
                                                                    tec2,
                                                                decoration:
                                                                    InputDecoration(
                                                                        hintText:
                                                                            "Q"),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      actions: <Widget>[
                                                        MaterialButton(
                                                          child: Text("Cancel"),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                        MaterialButton(
                                                          child:
                                                              Text("Decrypt!"),
                                                          onPressed: () {
                                                            // addPost(tec.text);
                                                            p = int.parse(
                                                                tec1.text);
                                                            q = int.parse(
                                                                tec2.text);
                                                            setState(() {});
                                                            mydecrypt(post);
                                                            setState(() {});
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ],
                                                    )).then((value) {
                                              showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                          title: Text(
                                                              "Decrypted Text"),
                                                          content: Text(data),
                                                          actions: <Widget>[
                                                            MaterialButton(
                                                              child:
                                                                  Text("OK!"),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                          ]));
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20.0, bottom: 4),
                                        child: GestureDetector(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Icon(Icons.delete),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.red[700]),
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            deleteNote(i);
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                  //---------------------------------------------------------------------------------------------------
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              //--------------------------------------------second page------------------------------------
              Encryptor(),
              //-------------------------------------third page-------------------------------------
              Scaffold(
                  body: Center(
                      child: new Column(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new TextField(
                        controller: tec1,
                        decoration: InputDecoration(hintText: "Title"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new TextField(
                        maxLength: 100,
                        controller: tec2,
                        decoration: InputDecoration(hintText: "Enter Note"),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Key",
                              style: TextStyle(fontSize: 15),
                            )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 50,
                            child: new TextField(
                              maxLength: 3,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller: tec3,
                              decoration: InputDecoration(hintText: "P"),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 50,
                            child: new TextField(
                              maxLength: 3,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller: tec4,
                              decoration: InputDecoration(hintText: "Q"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                          onPressed: () {
                            title = tec1.text;
                            plainText = tec2.text;
                            p = int.parse(tec3.text);
                            q = int.parse(tec4.text);
                            myencrypt(plainText);
                            upload();
                            setState(() {});

                            // print(data);
                          },
                          child: Text("Proceed")),
                    ),
                  ])))
            ],
          )),
    );
  }

  // Widget textEncrypt = Scaffold(
  //   body: Center(
  //       child: new Column(
  //         children: <Widget>[
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: new TextField(
  //               controller: tec,
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: TextButton(
  //                 onPressed: () {
  //                     data = tec.text;
  //                     start();

  //                   // print(data);
  //                 },
  //                 child: Text("Proceed")),
  //           ),]
  //       ))
  // );

  int p, q, n, t, flag, i, j;
  var e = new List(100),
      d = new List(100),
      temp = new List(100),
      m = new List<int>(100),
      en = new List<int>(100);

  // String msg;

  int prime(int pr) {
    int i;

    j = sqrt(pr).toInt();

    for (i = 2; i <= j; i++) {
      if (pr % i == 0) return 0;
    }

    return 1;
  }

  void ce() {
    int k;

    k = 0;

    for (i = 2; i < t; i++) {
      if (t % i == 0) continue;

      flag = prime(i);

      if (flag == 1 && i != p && i != q) {
        e[k] = i;

        flag = cd(e[k]);

        if (flag > 0) {
          d[k] = flag;

          k++;
        }

        if (k == 99) break;
      }
    }
  }

  int cd(int x) {
    int k = 1;

    while (true) {
      k = k + t;

      if (k % x == 0) return (k ~/ x);
    }
  }

  void start() {
    // p = 31;
    // q = 41;

    print("\nENTER MESSAGE\n");
    // print("msg: " + msg);

    n = p * q;

    t = (p - 1) * (q - 1);

    ce();

    print("\nPOSSIBLE VALUES OF e AND d ARE\n");

    for (i = 0; i < j - 1; i++) print("\n ${e[i]} \t ${d[i]}");
    print("excrypt start");
    // myencrypt();
    print("Encrypty end,  decrypt start");
    // mydecrypt();
    print("decrypt end");
    setState(() {});
  }

  void myencrypt(String plain) {
    start();
    int pt, ct, key = e[0], k, len;
    msg = plain;
    for (i = 0; i < msg.length; i++) {
      m[i] = msg.codeUnitAt(i);
      print(m[i]);
    }

    i = 0;

    len = msg.length;

    while (i != len) {
      print("1");
      pt = m[i];

      // ct = pow(pt, key) % n;
      k = pt;
      for (int i = 2; i <= key; i++) {
        k = k * pt;
        k = k % n;
      }

      ct = k;
      en[i] = ct;

      i++;
    }

    en[i] = -1;

    print("\nTHE ENCRYPTED MESSAGE IS\n");

    data = "";
    // data += String.fromCharCodes(en);

    for (i = 0; en[i] != -1; i++) data += String.fromCharCode(en[i]);

    setState(() {});
  }

  void mydecrypt(String cipher) {
    start();
    int pt, ct, key = d[0], k;

    for (i = 0; i < cipher.length; i++) {
      en[i] = cipher.codeUnitAt(i);
      print(en[i]);
    }
    en[i] = -1;
    i = 0;

    while (en[i] != -1) {
      ct = en[i];
      // pt = pow(ct, key) % n;
      k = ct;
      for (int i = 2; i <= key; i++) {
        k = k * ct;
        k = k % n;
      }

      pt = k;
      m[i] = pt;

      i++;
    }

    m[i] = -1;
    print("decryption complete");
    print("\nTHE DECRYPTED MESSAGE IS\n");
    data = "";
    for (i = 0; m[i] != -1; i++) {
      if (m[i] == 32) {
        data += " ";
      } else {
        data += String.fromCharCode(m[i]);
      }
      print(m[i]);
    }
    setState(() {});
  }
}
