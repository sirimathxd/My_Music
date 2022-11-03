import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class FmPlayer extends StatefulWidget {
  final AudioPlayer player;
  final List fm;
  final int index;
  const FmPlayer(
      {Key? key, required this.player, required this.fm, required this.index})
      : super(key: key);

  @override
  State<FmPlayer> createState() => _FmState();
}

class _FmState extends State<FmPlayer> {
  //bool pause = false;
  late AudioPlayer player = widget.player;
  late int index = widget.index;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, index);
          },
        ),
        title: const Text("FM"),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '📻 ${widget.fm[index].split("::")[1]}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width/ 1.5,
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: NetworkImage(
                      widget.fm[index].split("::")[2],
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Card(
              child: SizedBox(
                width: 200,
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () {
                        if (index != 0) {
                          index--;
                          player.play(UrlSource(widget.fm[index].split("::")[0]));
                        } else {
                          index = widget.fm.length - 1;
                          player.play(UrlSource(widget.fm[index].split("::")[0]));
                        }
                        setState(() {
                          player.state = PlayerState.playing;
                        });
                      },
                    ),
                    const SizedBox(width: 5),
                    IconButton(
                      icon:player.state != PlayerState.paused
                        ? const Icon(Icons.pause)
                        : const Icon(Icons.play_arrow),
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
                          player.play(UrlSource(widget.fm[index].split("::")[0]));
                          setState(() {
                            player.state = PlayerState.playing;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 5),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: () {
                        if (index != widget.fm.length - 1) {
                          index++;
                          player.play(UrlSource(widget.fm[index].split("::")[0]));
                        } else {
                          index = 0;
                          player.play(UrlSource(widget.fm[index].split("::")[0]));
                        }
                        setState(() {
                          player.state = PlayerState.playing;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
              
          ]
        ),
      ),
    );
  }
}
