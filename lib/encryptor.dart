import 'dart:math';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbols.dart';
import 'package:file_picker/file_picker.dart';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:permission_handler/permission_handler.dart';

class Encryptor extends StatefulWidget {
  // const Encryptor({Key? key}) : super(key: key);

  @override
  _EncryptorState createState() => _EncryptorState();
}

class _EncryptorState extends State<Encryptor> {
  String data = "", msg = "";
  String key = "my cool password";
  String defaultPath = "storage/emulated/0/Secure Store/";
  File file;
  String fileName = "";

  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createFolder();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.blueGrey[100],
      body: Center(
        child: new Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new TextField(
                controller: controller,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      data = controller.text;
                      msg = data;
                      data = "";
                      start();
                    });
                    // print(data);
                  },
                  child: Text("Proceed")),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text(data),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  onPressed: () {
                    openfile();
                  },
                  icon: Icon(Icons.file_upload)),
            ),
            Text(file != null ? file.path : " "),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextButton(
                  onPressed: () {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text("Enter Key!"),
                              content: TextField(
                                maxLength: 35,
                                maxLines: 1,
                                controller: controller,
                                decoration: new InputDecoration(
                                  hintText: "Enter the encryption key...",
                                ),
                              ),
                              actions: <Widget>[
                                MaterialButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                MaterialButton(
                                  child: Text("Encrypt"),
                                  onPressed: () {
                                    key = controller.text;
                                    fileEncrypt();

                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ));
                  },
                  child: Column(
                    children: [
                      Icon(Icons.no_encryption),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text("Encrypt"),
                      )
                    ],
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextButton(
                  onPressed: () {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text("Enter Key!"),
                              content: TextField(
                                maxLength: 35,
                                maxLines: 1,
                                controller: controller,
                                decoration: new InputDecoration(
                                  hintText: "Enter the Decryption key...",
                                ),
                              ),
                              actions: <Widget>[
                                MaterialButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                MaterialButton(
                                  child: Text("Decrypt"),
                                  onPressed: () {
                                    key = controller.text;
                                    fileDecrypt();

                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ));
                  },
                  child: Column(
                    children: [
                      Icon(Icons.no_encryption),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text("Decrypt"),
                      )
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  void openfile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = File(result.files.single.path);
      fileName = result.files.single.name;
      setState(() {});
    } else {
      // User canceled the picker
    }
  }

  void fileEncrypt() {
    var crypt = AesCrypt();
    crypt.setPassword(key);
    crypt.setOverwriteMode(AesCryptOwMode.rename);
    var p = crypt.encryptFileSync(file.path, defaultPath + fileName + ".aes");
    data = p;
    setState(() {});
  }

  void fileDecrypt() {
    var crypt = AesCrypt();
    crypt.setPassword(key);
    crypt.setOverwriteMode(AesCryptOwMode.rename);
    var p = crypt.decryptFileSync(file.path,
        defaultPath + fileName.substring(0, fileName.lastIndexOf(".")));
    //data = p;

    setState(() {});
  }

  void createFolder() async {
    final folderName = "Secure Store";
    final path = Directory("storage/emulated/0/$folderName");

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      print("here--------------------");
      await Permission.storage.request();
    }

    if ((await path.exists())) {
      print("exist");
    } else {
      print("not exist");
      path.create();
    }
  }

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
    p = 31;
    q = 41;

    print("\nENTER MESSAGE\n");
    print("msg: " + msg);
    for (i = 0; i < msg.length; i++) {
      m[i] = msg.codeUnitAt(i);
      print(m[i]);
    }

    n = p * q;

    t = (p - 1) * (q - 1);

    ce();

    print("\nPOSSIBLE VALUES OF e AND d ARE\n");

    for (i = 0; i < j - 1; i++) print("\n ${e[i]} \t ${d[i]}");
    print("excrypt start");
    myencrypt();
    print("Encrypty end,  decrypt start");
    mydecrypt();
    print("decrypt end");
    setState(() {});
  }

  void myencrypt() {
    int pt, ct, key = e[0], k, len;

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

    data += "   The encrypted msg:    ";
    // data += String.fromCharCodes(en);

    for (i = 0; en[i] != -1; i++) data += String.fromCharCode(en[i]);

    setState(() {});
  }

  void mydecrypt() {
    int pt, ct, key = d[0], k;

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
    data += "  \n The DEcrypted msg:    ";
    for (i = 0; m[i] != -1; i++) {
      if (m[i] == 32) {
        data += " ";
      } else {
        data += String.fromCharCode(m[i]);
      }
      print(m[i]);
    }
  }

/*void encrypt() {
    int pt, ct, key = e[0], k, len;

    i = 0;

    len = msg.length;

    while (i != len) {
      print("1");
      pt = m[i];

      pt = pt - 96;

      k = 1;

      for (j = 0; j < key; j++) {
        k = k * pt;

        k = k % n;
        print("2");
      }

      temp[i] = k;

      ct = k + 96;

      en[i] = ct;

      i++;
    }

    en[i] = -1;

    print("\nTHE ENCRYPTED MESSAGE IS\n");

    data += "   The encrypted msg:    ";
    // data += String.fromCharCodes(en);

    for (i = 0; en[i] != -1; i++) data += String.fromCharCode(en[i]);

    setState(() {});
  }*/

  /* void decrypt() {
    int pt, ct, key = d[0], k;

    i = 0;

    while (en[i] != -1) {
      ct = temp[i];

      k = 1;

      for (j = 0; j < key; j++) {
        k = k * ct;

        k = k % n;
      }

      pt = k + 96;

      m[i] = pt;

      i++;
    }

    m[i] = -1;

    print("\nTHE DECRYPTED MESSAGE IS\n");
    data += "  \n The DEcrypted msg:    ";
    for (i = 0; m[i] != -1; i++) {
      if (m[i] == 151) {
        data += " ";
      } else {
        data += String.fromCharCode(m[i]);
        print(m[i]);
      }
    }
  }*/
}
