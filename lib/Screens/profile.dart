import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vigenesia/Models/tweet.dart';

import 'package:vigenesia/Constant/const.dart';
import 'package:vigenesia/Models/motivasi_model.dart';

class Profile extends StatefulWidget {
  final String id;

  const Profile({Key? key, required this.id}) : super(key: key);
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  final Dio dio = Dio();
  final String baseurl = url;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 19.0, right: 19.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/cover1.jpg'),
                  ),
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
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            child: Padding(
                              padding: const EdgeInsets.all(8.5),
                              child: Text(
                                name,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 19.0),
                              ),
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
              const SizedBox(height: 20),
              FutureBuilder(
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
    );
  }
}
