import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:vigenesia/Constant/const.dart';

class EditPage extends StatefulWidget {
  final String userid;
  final String idMotivasi;
  const EditPage({Key key, this.userid, this.idMotivasi}) : super(key: key);
  @override
  EditPageState createState() => EditPageState();
}

class EditPageState extends State<EditPage> {
  String baseurl = url;
  var dio = Dio();
  bool _visible = false;
  String _motivasi;
  TextEditingController editController = TextEditingController();

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  Future<dynamic> editPost(String isiMotivasi, String ids) async {
    Map<String, dynamic> data = {'isi_motivasi': isiMotivasi, 'id': ids};
    var response = await dio.put(
      '$baseurl/api/dev/PUTmotivasi',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return response.data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: Visibility(
        visible: _visible,
        child: ElevatedButton(
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
          ),
          child: const Text('Submit'),
          onPressed: () async {
            if (_motivasi == null) {
              return showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Terdapat Kesalahan'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: const <Widget>[
                          Text('Motivasi tidak bisa kosong.'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }

            await editPost(_motivasi, widget.idMotivasi).then(
              (value) => {
                Navigator.pop(context),
                if (value != null)
                  {
                    Flushbar(
                      message: 'Berhasil Diubah',
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.greenAccent,
                      flushbarPosition: FlushbarPosition.TOP,
                    ).show(context)
                  },
              },
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                onChanged: (text) {
                  setState(
                    () {
                      _visible = text.isNotEmpty;
                      _motivasi = text;
                    },
                  );
                },
                decoration: const InputDecoration(
                  hintText: "Apa yang ingin diubah?",
                  icon: Icon(Icons.circle_rounded),
                ),
                scrollPadding: const EdgeInsets.all(20.0),
                keyboardType: TextInputType.multiline,
                maxLines: 99999,
                autofocus: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}
