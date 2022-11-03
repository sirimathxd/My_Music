import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:window_size/window_size.dart';
import 'fm_home.dart';
import 'song.dart';
import 'dz.dart';
import 'contact.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMaxSize(Size.infinite);
    setWindowMinSize(const Size(1024, 768));
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AudioPlayer player;
  late FlameSplashController controller;

  final _controller = SidebarXController(selectedIndex: 0, extended: false);
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: FlameSplashScreen(
              theme: FlameSplashTheme(
                backgroundDecoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF000000),
                      Color(0xFF000000),
                    ],
                  ),
                ),
                logoBuilder: _logoBuilder
              ),
              showBefore: (context) {
                return const Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                );
              },
              onFinish: (context) => Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute(builder: (context) {
                  final isSmallScreen = MediaQuery.of(context).size.width < 600;
                  return Scaffold(
                    key: _key,
                    appBar: AppBar(
                      title: AnimatedTextKit(
                        animatedTexts: [
                          WavyAnimatedText(
                            'Music Player',
                            textStyle: const TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                        isRepeatingAnimation: true,
                        totalRepeatCount: 100,
                        pause: const Duration(milliseconds: 1000),
                      ),
                    ),
                    drawer:
                        isSmallScreen ? ExampleSidebarX(controller: _controller) : null,
                    body: Row(
                      children: [
                        if (!isSmallScreen) ExampleSidebarX(controller: _controller),
                        Expanded(
                          child: Center(
                            child: _ScreensExample(
                              controller: _controller,
                              player: player,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _logoBuilder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:  [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/avtr.jpg'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.black,
                width: 5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'My Music',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          //by sirimath
          const SizedBox(height: 20),
          const Text(
            'by sirimath',
            style: TextStyle(
              fontSize: 20,
              //fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

}

class ExampleSidebarX extends StatelessWidget {
  const ExampleSidebarX({
    Key? key,
    required SidebarXController controller,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: actionColor.withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: canvasColor,
        ),
      ),
      footerDivider: divider,
      headerBuilder: (context, extended) {
        return const SizedBox(
          height: 100,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/avtr.jpg'),
            ),
          ),
        );
      },
      items: const [
        SidebarXItem(
          icon: Icons.music_note,
          label: 'Music',
        ),
        SidebarXItem(
          icon: Icons.radio,
          label: 'Radio',
        ),
        SidebarXItem(
          icon: Icons.search,
          label: 'Search',
        ),
        //contact
        SidebarXItem(
          icon: Icons.person,
          label: 'Contact',
        ),
      ],
    );
  }
}

class _ScreensExample extends StatelessWidget {
  final AudioPlayer player;
  const _ScreensExample({
    Key? key,
    required this.controller,
    required this.player,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        switch (controller.selectedIndex) {
          case 0:
            return Song(player: player);
          case 1:

            return Fm(player: player);
          case 2:
            return Dz(player: player);
          case 3:
            return const Contact();
          default:
            return const SizedBox();
        }
      },
    );
  }
}

const canvasColor = Color(0xFF454545);
const scaffoldBackgroundColor = Colors.grey;
const accentCanvasColor = Color(0xFF454545);
const white = Colors.white;
final actionColor = const Color.fromARGB(255, 210, 210, 225).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);
