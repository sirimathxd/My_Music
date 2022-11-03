import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:isolate';
import 'dart:ui';

class Dz extends StatefulWidget {
  final AudioPlayer player;

  const Dz({Key? key, required this.player}) : super(key: key);

  @override
  State<Dz> createState() => _DzState();
}

class _DzState extends State<Dz> {
  late AudioPlayer player = widget.player;
  List dz = [];
  int indexx = 0;
  String name = '';
  String url = '';
  String song = '';

  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState((){ });
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      hintText: 'Search songs...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(25.0),
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      getsong(name);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF454545),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                    ),
                    fixedSize: const Size(100, 50),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100, left: 8, right: 8),
              itemCount: dz.length,
              itemBuilder: (context, index) {
                var duration = Duration(seconds: dz[index]['duration']);
                return Card(
                  child: ListTile(
                    title: Text(dz[index]['title']),
                    subtitle: Text(
                        'Artist: ${dz[index]['artist']['name']}\nDuration: ${duration.toString().split('.').first}'),
                    leading: Image(
                      image: NetworkImage(dz[index]['album']['cover_medium']),
                      fit: BoxFit.cover,
                    ),
                    //download song
                    trailing: IconButton(
                      onPressed: () {
                        downloadsong(dz[index]['id']);
                      },
                      icon: const Icon(Icons.download),
                    ),
                    onTap: () {
                      setState(() {
                        indexx = index;
                      });
                      playsong(dz[index]['id']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: dz.isNotEmpty
          ? Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color(0xFF454545),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: NetworkImage(url.isEmpty
                            ? dz[indexx]['album']['cover_medium']
                            : url),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 6,
                    height: 30,
                    child: Marquee(
                      text: song.isEmpty
                          ? dz[indexx]['title'] +
                              ' - ' +
                              dz[indexx]['artist']['name']
                          : song,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      blankSpace: 10.0,
                      velocity: 100.0,
                      pauseAfterRound: const Duration(seconds: 1),
                      startPadding: 10.0,
                      accelerationDuration: const Duration(seconds: 1),
                      accelerationCurve: Curves.linear,
                      decelerationDuration: const Duration(milliseconds: 500),
                      decelerationCurve: Curves.easeOut,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 12,
                  ),
                  Card(
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          if (indexx > 0) {
                            indexx--;
                            playsong(dz[indexx]['id']);
                          } else {
                            indexx = dz.length - 1;
                            playsong(dz[indexx]['id']);
                          }
                          setState(() {
                            player.state = PlayerState.playing;
                          });
                        });
                      },
                      icon: const Icon(Icons.skip_previous),
                    ),
                  ),
                  Card(
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          if (player.state == PlayerState.playing) {
                            player.pause();
                            setState(() {
                              player.state = PlayerState.paused;
                            });
                          } else if (player.state == PlayerState.paused) {
                            player.resume();
                            setState(() {
                              player.state = PlayerState.playing;
                            });
                          } else {
                            playsong(dz[indexx]['id']);
                            setState(() {
                              player.state = PlayerState.playing;
                            });
                          }
                        });
                      },
                      icon: player.state == PlayerState.playing
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow),
                    ),
                  ),
                  Card(
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          if (indexx < dz.length - 1) {
                            indexx++;
                            playsong(dz[indexx]['id']);
                          } else {
                            indexx = 0;
                            playsong(dz[indexx]['id']);
                          }
                          setState(() {
                            player.state = PlayerState.playing;
                          });
                        });
                      },
                      icon: const Icon(Icons.skip_next),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox(),
    );
  }

  getsong(String name) async {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              CircularProgressIndicator(),
              SizedBox(
                height: 10,
              ),
              Text('Searching...'),
            ],
          );
        },
      );
      var response = await http
        .get(Uri.parse("https://dz.anjanamadu.net/api/search?q=$name"));
        //print(response.body);
        //print(response.statusCode);
      if (response.statusCode == 200 ) {
        setState(() {
          //print(response.body);
          Map<String, dynamic> body = jsonDecode(response.body);
          dz = body['data'];
          Navigator.of(context).pop();
        });
        
      } else {
        //print('no results');
        setState(() {
          Navigator.of(context).pop();
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Song not found'),
              content: const Text('Please try again'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
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

  playsong(int id) async {
    try {
      showDialog(context: context, 
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 10,),
              Text('Playing...'),
            ],
          );
        },
      );
      var response = await http.get(Uri.parse(
          "https://dz.anjanamadu.net/api/track?id=$id&download=true"));
      if (response.statusCode == 200) {
        setState(() {
          Map<String, dynamic> body = jsonDecode(response.body);
          if (body['downloadURL'] != null) {
            player.play(UrlSource(body['downloadURL']));
            player.state = PlayerState.playing;
            song = dz[indexx]['title'] + ' - ' + dz[indexx]['artist']['name'];
            url = dz[indexx]['album']['cover_medium'];
            Navigator.of(context).pop();
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Song not found'),
                  content: const Text('Please try again'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Song not found'),
              content: const Text('Please try again'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
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

  downloadsong(int id) async {
    try {
      var response = await http.get(Uri.parse(
          "https://dz.anjanamadu.net/api/track?id=$id&download=true"));
      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(response.body);
        if (body['downloadURL'] != null) {
          await FlutterDownloader.enqueue(
            url: body['downloadURL'],
            savedDir: '/storage/emulated/0/Music',
            showNotification: true,
            openFileFromNotification: true,
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Song not found'),
                content: const Text('Please try again'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Song not found'),
              content: const Text('Please try again'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
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
}
