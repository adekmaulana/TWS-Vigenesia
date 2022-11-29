import 'package:flutter/material.dart';
import 'package:vigenesia/Models/motivasi_model.dart';

class Feed extends StatefulWidget {
  final Future<List<MotivasiModel>> data;
  const Feed({Key key, this.data}) : super(key: key);
  @override
  FeedState createState() => FeedState();
}

class FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Feed'),
        ),
        body: FutureBuilder(
            future: widget.data,
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
              } else if (snapshot.hasData && snapshot.data.isEmpty) {
                return const Text('No Data');
              } else {
                return const CircularProgressIndicator();
              }
            }));
  }
}
