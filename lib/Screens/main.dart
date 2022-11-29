import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vigenesia/Models/motivasi_model.dart';
import 'package:vigenesia/Screens/add_page.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'login.dart';
import 'package:vigenesia/Constant/const.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:vigenesia/Screens/feed.dart';

class MainScreens extends StatefulWidget {
  final String idUser;
  final String nama;
  const MainScreens({Key key, this.nama, this.idUser}) : super(key: key);
  @override
  MainScreensState createState() => MainScreensState();
}

class MainScreensState extends State<MainScreens> {
  String baseurl = url;
  String id;
  var dio = Dio();
  List<MotivasiModel> ass = [];
  TextEditingController titleController = TextEditingController();

  List<MotivasiModel> listproduk = [];
  Future<List<MotivasiModel>> getData() async {
    var response = await dio.get(
        '$baseurl/api/get_motivasi?iduser=${widget.idUser}'); // NGambil by data
    print(' ${response.data}');
    if (response.statusCode == 200) {
      var getUsersData = response.data as List;
      var listUsers =
          getUsersData.map((i) => MotivasiModel.fromJson(i)).toList();
      return listUsers;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<dynamic> deletePost(String id) async {
    dynamic data = {
      'id': id,
    };
    var response = await dio.delete(
      '$baseurl/api/dev/DELETEmotivasi',
      data: data,
      options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {'content-Type': 'application/json'}),
    );
    print(' ${response.data}');
    return response.data;
  }

  Future<List<MotivasiModel>> getData2() async {
    var response = await dio.get('$baseurl/api/get_motivasi');
    print(' ${response.data}');
    if (response.statusCode == 200) {
      var getUsersData = response.data as List;
      var listUsers =
          getUsersData.map((i) => MotivasiModel.fromJson(i)).toList();
      return listUsers;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<CircularProgressIndicator> _getData() async {
    setState(() {
      getData().then((_) => listproduk.clear());
    });
    return const CircularProgressIndicator();
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    getData2();
    _getData();
  }

  String trigger;
  String triggeruser;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    String firstName = widget.nama.split(' ')[0];
    String secondName =
        widget.nama.split(' ').length > 1 ? widget.nama.split(' ')[1] : null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        elevation: 0,
        title: Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 30.0),
              child: CircleAvatar(
                radius: 19.0,
                child: Text(
                  secondName != null
                      ? firstName[0] + secondName[0]
                      : firstName[0],
                ),
              ),
            ),
            const Text(
              "Home",
              style: TextStyle(color: Colors.black),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah Motivasi',
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => AddPage(userid: widget.idUser),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        // <-- Berfungsi Untuk Bisa Scroll
        child: SafeArea(
          // < -- Biar Gak Keluar Area Screen HP
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, // <-- Berfungsi untuk atur nilai X jadi tengah
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hallo ${widget.nama}',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                      TextButton(
                          child: const Icon(Icons.logout),
                          onPressed: () {
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.remove('email');
                              prefs.remove('nama');
                              prefs.remove('id');
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const Login(),
                                ),
                              );
                            });
                          }),
                    ],
                  ),
                  const SizedBox(height: 20), // <-- Kasih Jarak Tinggi : 50px
                  TextButton(
                    child: const Icon(Icons.refresh),
                    onPressed: () {
                      _getData();
                    },
                  ),
                  trigger == 'Motivasi By All'
                      ? FutureBuilder(
                          future: getData2(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<MotivasiModel>> snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                children: [
                                  for (var item in snapshot.data)
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          Text(item.isiMotivasi),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data.isEmpty) {
                              return const Text('No Data');
                            } else {
                              return const CircularProgressIndicator();
                            }
                          })
                      : Container(),
                  trigger == 'Motivasi By User'
                      ? FutureBuilder(
                          future: getData(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<MotivasiModel>> snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                children: [
                                  for (var item in snapshot.data)
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          Card(
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                Text(item.isiMotivasi),
                                                Row(children: [
                                                  TextButton(
                                                    child: const Icon(
                                                        Icons.delete),
                                                    onPressed: () {
                                                      deletePost(item.id)
                                                          .then((value) => {
                                                                if (value !=
                                                                    null)
                                                                  {
                                                                    Flushbar(
                                                                      message:
                                                                          'Berhasil Delete',
                                                                      duration: const Duration(
                                                                          seconds:
                                                                              2),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .redAccent,
                                                                      flushbarPosition:
                                                                          FlushbarPosition
                                                                              .TOP,
                                                                    ).show(
                                                                        context)
                                                                  }
                                                              });
                                                      _getData();
                                                    },
                                                  )
                                                ]),
                                              ])),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data.isEmpty) {
                              return const Text('No Data');
                            } else {
                              return const CircularProgressIndicator();
                            }
                          })
                      : Container(),
                ]),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
