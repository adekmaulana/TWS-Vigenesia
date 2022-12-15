import 'package:flutter/services.dart';
import 'package:vigenesia/Screens/add_page.dart';
import 'package:flutter/material.dart';
import 'package:vigenesia/Screens/drawer.dart';
import 'package:vigenesia/Constant/const.dart';
import 'package:vigenesia/Models/tweet.dart';
import 'package:vigenesia/Models/motivasi_model.dart';

class MainScreens extends StatefulWidget {
  final String idUser;
  final String nama;
  const MainScreens({Key? key, required this.nama, required this.idUser})
      : super(key: key);
  @override
  MainScreensState createState() => MainScreensState();
}

class MainScreensState extends State<MainScreens> {
  late String id;
  TextEditingController titleController = TextEditingController();

  void _refresh() {
    setState(
      () {
        getDataMotivasi().then(
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
  void initState() {
    super.initState();
    getDataMotivasiUser(widget.idUser);
    getDataMotivasi();
    _refresh();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    String firstName = widget.nama.split(' ')[0];
    String? secondName =
        widget.nama.split(' ').length > 1 ? widget.nama.split(' ')[1] : null;
    String displayName =
        secondName != null ? firstName[0] + secondName[0] : firstName[0];
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(
        displayName: displayName,
        fullName: widget.nama,
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 19.0),
          child: CircleAvatar(
            child: TextButton(
              child: Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ),
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 19.0, right: 19.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  FutureBuilder(
                    future: getDataMotivasi(),
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
                                  fromPage: "home",
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
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(21.0),
              child: FloatingActionButton(
                tooltip: 'Tambah Motivasi',
                child: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          AddPage(userid: widget.idUser),
                    ),
                  ).then((value) => _refresh());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
