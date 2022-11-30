import 'package:flutter/services.dart';
import 'package:vigenesia/Screens/add_page.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:vigenesia/Screens/drawer.dart';
import 'package:vigenesia/Screens/home.dart';
import 'package:vigenesia/Screens/profile.dart';
import 'package:vigenesia/Constant/const.dart';

class MainScreens extends StatefulWidget {
  final String idUser;
  final String nama;
  const MainScreens({Key? key, required this.nama, required this.idUser})
      : super(key: key);
  @override
  MainScreensState createState() => MainScreensState();
}

class MainScreensState extends State<MainScreens> {
  String baseurl = url;
  late String id;
  var dio = Dio();
  TextEditingController titleController = TextEditingController();

  Future<CircularProgressIndicator> getData() async {
    setState(
      () {
        getDataMotivasi().then((_) => {});
      },
    );
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
    getDataMotivasiUser(widget.idUser);
    getDataMotivasi();
    getData();
  }

  int _selectedIndex = 0;
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
            radius: 19.0,
            child: TextButton(
              child: Text(
                displayName,
                style: const TextStyle(color: Colors.white, fontSize: 13.0),
              ),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ),
        title: Text(
          _selectedIndex == 0 ? 'Home' : 'Profile',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          _selectedIndex == 0 ? const Home() : Profile(id: widget.idUser),
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
                  );
                },
              ),
            ),
          ),
        ],
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
