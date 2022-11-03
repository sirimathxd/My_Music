import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'fm_player.dart';

class Fm extends StatefulWidget {
  final AudioPlayer player;
  const Fm({Key? key, required this.player}) : super(key: key);

  @override
  State<Fm> createState() => _FmState();
}

class _FmState extends State<Fm> {
  late AudioPlayer player = widget.player;
  List fm = [];
  var items = [];
  int indexx = 0;

  @override
  void initState() {
    super.initState();
    getFm();
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  getFm() async {
    try {
      var response = await http.get(Uri.parse(
          "https://gist.githubusercontent.com/sirimathxd/d27a26895c36a04b027b8e92aac10369/raw/fm.txt"));
      if (response.statusCode == 200) {
        setState(() {
          fm = response.body.split("\n");
          items.addAll(fm);
        });
      } else {
        showDialog(
          context: context, 
          builder: (context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("Something went wrong"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  }, 
                  child: const Text("Ok")
                )
              ],
            );
          }
        );
      }
    } on SocketException {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("No Internet"),
            content: const Text("Please check your internet connection"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Ok"),
              ),
            ],
          );
        },
      );
    }
  }

  void filtersearch(String query) {
    List dummySearchList = [];
    dummySearchList.addAll(fm);
    if (query.isNotEmpty) {
      List<String> dummyListData = <String>[];
      for (var item in dummySearchList) {
        if (item.split('::')[1].toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      if (dummyListData.isNotEmpty) {
        setState(() {
          items.clear();
          items.addAll(dummyListData);
        });
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("No Results"),
              content: const Text("No results found"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Ok"),
                ),
              ],
            );
          },
        );
      }
      return;
    } else {
      items.clear();
      items.addAll(fm);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (fm.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              CircularProgressIndicator(),
              SizedBox(
                height: 20,
              ),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filtersearch(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Search',
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Platform.isAndroid ? 2 : 6,
                ),
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: InkWell(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 8,
                        height: MediaQuery.of(context).size.height / 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: NetworkImage(
                              items[index].split("::")[2],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      onTap: () {
                        player.play(UrlSource(items[index].split("::")[0]));
                        setState(() {
                          indexx = fm.indexOf(items[index]);
                          player.state == PlayerState.playing;
                        });
                        _navigate(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomSheet: Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Color(0xFF454545),
            borderRadius:  BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 10,
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: NetworkImage(
                      fm[indexx].split("::")[2],
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 9,
                height: 30,         
                child: Marquee(
                  text: fm[indexx].split("::")[1],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  blankSpace: 20.0,
                  velocity: 100.0,
                  pauseAfterRound: const Duration(seconds: 1),
                  startPadding: 10.0,
                  accelerationDuration: const Duration(seconds: 1),
                  accelerationCurve: Curves.linear,
                  decelerationDuration: const Duration(milliseconds: 500),
                  decelerationCurve: Curves.easeOut,
                ),
              ),
              const Spacer(),
              Card(
                child: IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () {
                    if (indexx != 0) {
                      indexx--;
                      player.play(UrlSource(fm[indexx].split("::")[0]));
                    } else {
                      indexx = fm.length - 1;
                      player.play(UrlSource(fm[indexx].split("::")[0]));
                    }
                    setState(() {
                      player.state = PlayerState.playing;
                    });
                  },
                ),
              ),
              Card(
                child: IconButton(
                  icon:player.state != PlayerState.playing
                    ? const Icon(Icons.play_arrow)
                    : const Icon(Icons.pause),
                  onPressed: ()  {
                    if (player.state == PlayerState.paused) {
                      player.resume();
                      setState(() {
                        player.state = PlayerState.playing;
                      });
                    } else if (player.state == PlayerState.playing) {
                      player.pause();
                      setState(() {
                        player.state = PlayerState.paused;
                      });
                    } else {
                      player.play(UrlSource(fm[indexx].split("::")[0]));
                      setState(() {
                        player.state = PlayerState.playing;
                      });
                    }
                  },
                ),
              ),
              Card(
                child: IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    if (indexx != fm.length - 1) {
                      indexx++;
                      player.play(UrlSource(fm[indexx].split("::")[0]));
                    } else {
                      indexx = 0;
                      player.play(UrlSource(fm[indexx].split("::")[0]));
                    }
                    setState(() {
                      player.state = PlayerState.playing;
                    });
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _navigate(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FmPlayer(fm: fm, index: indexx, player: player)),
    );
    setState(() {
      indexx = result;
    });
  }
}

