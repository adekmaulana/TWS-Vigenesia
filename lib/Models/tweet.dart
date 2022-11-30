import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vigenesia/Constant/const.dart';
import 'package:vigenesia/Models/login_model.dart';
import 'package:vigenesia/Screens/edit_page.dart';

class Tweet extends StatefulWidget {
  final String id;
  final String user;
  final String text;
  final DateTime date;

  const Tweet({Key key, this.id, this.user, this.text, this.date})
      : super(key: key);

  @override
  State<Tweet> createState() => TweetState();
}

class TweetState extends State<Tweet> {
  final Dio dio = Dio();
  final String baseurl = url;

  String currentUser;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        currentUser = prefs.getString('id');
      });
    });
  }

  Future<dynamic> deletePost(String motivasiId) async {
    if (currentUser != widget.user) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Terdapat Kesalahan'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('Anda bukan pembuat motivasi ini.'),
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

    Map<String, dynamic> body = {
      'id': motivasiId,
    };
    try {
      final response = await dio.delete(
        '$baseurl/api/dev/DELETEmotivasi',
        data: body,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response.data;
    } catch (e) {
      print('Error di -> $e');
    }
  }

  void showPopupMenu(BuildContext context, TapDownDetails details) async {
    await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      items: const [
        PopupMenuItem<String>(
          value: '1',
          child: Text('Edit Motivasi'),
        ),
        PopupMenuItem<String>(
          value: '2',
          child: Text('Delete Motivasi'),
        ),
      ],
      elevation: 8.0,
    ).then(
      (String itemSelected) async {
        if (itemSelected == null) return;

        if (itemSelected == "1") {
          if (currentUser != widget.user) {
            return showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Terdapat Kesalahan'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: const <Widget>[
                        Text('Anda bukan pembuat motivasi ini.'),
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
          ;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => EditPage(
                userid: widget.user,
                idMotivasi: widget.id,
              ),
            ),
          );
        } else if (itemSelected == "2") {
          await deletePost(widget.id); //bug
          await getDataMotivasi();
        } else {
          return;
        }
        ;
      },
    );
  }

  Widget _tweetContent(String name, String id) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.only(left: 11.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    "@$id · ${widget.date.timeAgo(numericDates: false)}",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width - 350),
                  child: GestureDetector(
                    child: const Icon(Icons.more_horiz_rounded),
                    onTapDown: (details) => showPopupMenu(context, details),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(
                widget.text,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDataUser(widget.user),
      builder: (BuildContext context, AsyncSnapshot<List<DataUser>> snapshot) {
        if (snapshot.hasData && widget.text.isNotEmpty) {
          var data = snapshot.data[0];
          var name = data.nama;
          var subname =
              name.split(' ').length > 1 ? name.split(' ')[1][0] : null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 30.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                CircleAvatar(
                  child: Text(
                    subname != null
                        ? data.nama.substring(0, 1) + subname
                        : data.nama.substring(0, 1),
                  ),
                ),
                _tweetContent(data.nama, data.iduser),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
