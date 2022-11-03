import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:marquee/marquee.dart';
//import 'player.dart';

class Song extends StatefulWidget {
  final AudioPlayer player;
  const Song({super.key, required this.player});

  @override
  createState() => _SongState();
}

class _SongState extends State<Song> {
  late AudioPlayer player = widget.player;
  final paths = <String>[];
  var items = <String>[];
  int indexx = 0;
  bool playlp = true;

  void setindex(int index) {
    indexx = index;
  }

  @override
  void initState() {
    super.initState();
    _songlistadd();
    playlist();
    playlp = true;
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
    playlp = false;
  }

  void filtersearch(String query) {
    List<String> dummySearchList = <String>[];
    dummySearchList.addAll(paths);
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
              title: const Text('No Song Found'),
              content: const Text('Please try again'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      return;
    } else {
      items.clear();
      items.addAll(paths);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
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
                'No Songs Found',
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
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100, left: 8, right: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        items[index].split('::')[1],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: index == indexx,
                      selectedColor: Colors.blue,
                      onTap: () {
                        player.play(
                            DeviceFileSource(items[index].split('::')[0]));
                        setState(() {
                          indexx = paths.indexOf(items[index]);
                          player.state = PlayerState.playing;
                        });
                      },
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Song'),
                              content: const Text('Are you sure?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    File(items[index].split('::')[0]).delete();
                                    Navigator.of(context).pop();
                                    setState(() {
                                      paths.remove(items[index]);
                                      items.remove(items[index]);
                                    });
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomSheet: SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.2,
                height: 30,
                child: Marquee(
                  text: paths[indexx].split('::')[1],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  blankSpace: 0.0,
                  velocity: 100.0,
                  pauseAfterRound: const Duration(seconds: 1),
                  startPadding: 10.0,
                  accelerationDuration: const Duration(seconds: 1),
                  accelerationCurve: Curves.linear,
                  decelerationDuration: const Duration(milliseconds: 500),
                  decelerationCurve: Curves.easeOut,
                ),
              ),
              Card(
                child: IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () {
                    if (indexx != 0) {
                      indexx--;
                      player
                          .play(DeviceFileSource(paths[indexx].split('::')[0]));
                    } else {
                      indexx = paths.length - 1;
                      player
                          .play(DeviceFileSource(paths[indexx].split('::')[0]));
                    }
                    setState(() {
                      player.state = PlayerState.playing;
                    });
                  },
                ),
              ),
              Card(
                child: IconButton(
                  icon: player.state != PlayerState.playing
                      ? const Icon(Icons.play_arrow)
                      : const Icon(Icons.pause),
                  onPressed: () {
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
                      player
                          .play(DeviceFileSource(paths[indexx].split('::')[0]));
                      setState(() {
                        player.state = PlayerState.playing;
                        //--//
                      });
                    }
                    //shuffle();
                  },
                ),
              ),
              Card(
                child: IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    if (indexx != paths.length - 1) {
                      indexx++;
                      player
                          .play(DeviceFileSource(paths[indexx].split('::')[0]));
                    } else {
                      indexx = 0;
                      player
                          .play(DeviceFileSource(paths[indexx].split('::')[0]));
                    }
                    setState(() {
                      player.state = PlayerState.playing;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Future<void> _navigate(BuildContext context) async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) => Playerpage(
  //               paths: paths,
  //               index: indexx,
  //               player: player,
  //             )),
  //   );
  //   if (result != null) {
  //     setState(() {
  //       indexx = result;
  //     });
  //   }
  // }

  void playlist() {
    player.onPlayerComplete.listen((event) {
      print('complete');
      if (playlp) {
        print('complete1');
        if (indexx != paths.length - 1) {
          indexx++;
          player.play(DeviceFileSource(paths[indexx].split('::')[0]));
          setState(() {
            player.state = PlayerState.playing;
            //_navigate(context);
          });
        } else {
          indexx = 0;
          player.play(DeviceFileSource(paths[indexx].split('::')[0]));
          setState(() {
            player.state = PlayerState.playing;
            //_navigate(context);
          });
        }
      }
      print('complete2');
    });
  }

  // void shuffle() {
  //   player.onPlayerComplete.listen((event) {
  //     indexx = Random().nextInt(paths.length);
  //     player.play(DeviceFileSource(paths[indexx].split('::')[0]));
  //     setState(() {
  //       player.state = PlayerState.playing;
  //       _navigate(context);
  //     });
  //   });
  // }

  void _songlistadd() async {
    try {
      if (Platform.isWindows) {
        if (await Permission.storage.request().isGranted) {
          Map<String, String> envVars = Platform.environment;
          String path = envVars['USERPROFILE']! + r'\Music';
          final dir = Directory(path);
          final files = dir.listSync(recursive: true, followLinks: false);
          for (final file in files) {
            if (file.path.endsWith('.mp3')) {
              paths.add(
                  "${file.path}::${file.path.split('\\').last.split('.').first}");
            }
          }
          setState(() {});
        }
      } else if (Platform.isAndroid) {
        if (await Permission.storage.request().isGranted) {
          //Map<String, String> envVars = Platform.environment;
          //String path = envVars['EXTERNAL_STORAGE']!;
          //final dir = Directory(path);
          final dir = Directory('/storage/emulated/0/Music');
          final files = dir.listSync(recursive: true, followLinks: false);
          for (final file in files) {
            if (file.path.endsWith('.mp3')) {
              paths.add(
                  "${file.path}::${file.path.split('/').last.split('.').first}");
            }
          }
          setState(() {});
        }
      } else if (Platform.isIOS) {
        if (await Permission.storage.request().isGranted) {
          Map<String, String> envVars = Platform.environment;
          String path = envVars['HOME']! + r'/Music';
          final dir = Directory(path);
          final files = dir.listSync(recursive: true, followLinks: false);
          for (final file in files) {
            if (file.path.endsWith('.mp3')) {
              paths.add(
                  "${file.path}::${file.path.split('/').last.split('.').first}");
            }
          }
          setState(() {});
        }
      }
      items.addAll(paths);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(e.toString())),
      );
    }
  }
}
