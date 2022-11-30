import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/login.dart';
import 'Screens/main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email') ?? '';
  var nama = prefs.getString('nama') ?? '';
  var id = prefs.getString('id') ?? '';
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: email == '' ? const Login() : MainScreens(nama: nama, idUser: id),
    ),
  );
}
