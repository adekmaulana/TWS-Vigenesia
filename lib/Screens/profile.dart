import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vigenesia/Models/tweet.dart';

import 'package:vigenesia/Constant/const.dart';
import 'package:vigenesia/Models/motivasi_model.dart';
import 'package:vigenesia/Screens/add_page.dart';

class Profile extends StatefulWidget {
  final String id;
  final String fromPage;
  final String? currentUser;

  const Profile({
    Key? key,
    required this.id,
    required this.fromPage,
    required this.currentUser,
  }) : super(key: key);
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  void _refresh() {
    setState(
      () {
        getDataMotivasiUser(widget.id).then(
          (_) async => {
            await Future.delayed(
              const Duration(milliseconds: 100),
            )
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/cover1.jpg'),
                    ),
                  ),
                  child: null,
                ),
                SafeArea(
                  child: IconButton(
                    icon: const Icon(
                      CupertinoIcons.back,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 4.65,
                  ),
                  child: FutureBuilder(
                    future: getDataUser(widget.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var item = snapshot.data![0];
                        var name = item.nama;
                        var subname = name.split(' ').length > 1
                            ? name.split(' ')[1][0]
                            : null;
                        return Container(
                          margin: const EdgeInsets.only(left: 11.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: SizedBox(
                                  child: CircleAvatar(
                                    radius: 19.0,
                                    child: Text(
                                      subname != null
                                          ? name.substring(0, 1) + subname
                                          : name.substring(0, 1),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19.0,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      '@${item.iduser}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  const Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      '·',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  const Icon(
                                    CupertinoIcons.briefcase,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  Text(
                                    item.profesi,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                        return const Text('No Data');
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: 21.0,
                      top: MediaQuery.of(context).size.width / 2.5,
                    ),
                    child: widget.id == widget.currentUser
                        ? FloatingActionButton(
                            tooltip: 'Tambah Motivasi',
                            child: const Icon(Icons.add),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      AddPage(userid: widget.id),
                                ),
                              ).then((value) => _refresh());
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
            const Divider(
              height: 10.0,
              thickness: 1.0,
            ),
            Container(
              margin: const EdgeInsets.only(left: 11.0),
              child: FutureBuilder(
                future: getDataMotivasiUser(widget.id),
                builder: (BuildContext context,
                    AsyncSnapshot<List<MotivasiModel>> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        for (var item in snapshot.data!)
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Tweet(
                              id: item.id,
                              user: item.idUser,
                              text: item.isiMotivasi,
                              date: item.tanggalInput,
                              fromPage: "profile",
                              refresher: _refresh,
                            ),
                          ),
                      ],
                    );
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return const Text('No Data');
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
