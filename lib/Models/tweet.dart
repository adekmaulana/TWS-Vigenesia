import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vigenesia/Constant/const.dart';
import 'package:vigenesia/Models/login_model.dart';
import 'package:vigenesia/Screens/edit_page.dart';
import 'package:vigenesia/Screens/profile.dart';

class Tweet extends StatefulWidget {
  final String id;
  final String user;
  final String text;
  final DateTime date;
  final String fromPage;
  final Function refresher;

  const Tweet({
    Key? key,
    required this.id,
    required this.user,
    required this.text,
    required this.date,
    required this.fromPage,
    required this.refresher,
  }) : super(key: key);

  @override
  State<Tweet> createState() => TweetState();
}

class TweetState extends State<Tweet> {
  late String? currentUser;

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
      return await showDialog<void>(
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
        '/dev/DELETEmotivasi',
        data: body,
      );
      return response.data;
    } catch (e) {
      print('Error di -> $e');
    }
  }

  Future<dynamic> showPopupMenu(
      BuildContext context, TapDownDetails details) async {
    showMenu<String>(
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
    ).then((String? itemSelected) async {
      if (itemSelected == "1") {
        if (currentUser != widget.user) {
          return await showDialog<void>(
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

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => EditPage(
              userid: widget.user,
              idMotivasi: widget.id,
              text: widget.text,
            ),
          ),
        ).then((value) => widget.refresher());
      } else if (itemSelected == "2") {
        await deletePost(widget.id).then((value) {
          if (value != null) {
            Flushbar(
              message: 'Berhasil Dihapus',
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.greenAccent,
              flushbarPosition: FlushbarPosition.TOP,
            ).show(context);
          } else {
            Flushbar(
              message: 'Gagal Dihapus',
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.redAccent,
              flushbarPosition: FlushbarPosition.TOP,
            ).show(context);
          }
        });
        widget.refresher();
      }
    });
  }

  Widget _tweetContent(String name, String id) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.only(left: 11.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        name.split(' ').length >= 3
                            ? name.split(' ')[0] + name.split(' ')[2]
                            : name,
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
                    ],
                  ),
                ),
                widget.user == currentUser
                    ? Container(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          child: const Icon(Icons.more_horiz_rounded),
                          onTapDown: (details) =>
                              showPopupMenu(context, details),
                        ),
                      )
                    : const SizedBox.shrink(),
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
          var data = snapshot.data![0];
          var name = data.nama;
          String? subname;
          try {
            subname = name.split(' ')[1][0];
          } catch (e) {
            subname = null;
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 30.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                CircleAvatar(
                  radius: 19,
                  child: TextButton(
                    onPressed: () => {
                      if (widget.fromPage != "profile")
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => Profile(
                                id: widget.user,
                                fromPage: "home",
                                currentUser: currentUser,
                              ),
                            ),
                          ).then((value) => widget.refresher())
                        },
                    },
                    child: Text(
                      subname != null
                          ? data.nama.substring(0, 1) + subname
                          : data.nama.substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    ),
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
