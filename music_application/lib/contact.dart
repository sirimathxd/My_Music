import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Contact extends StatelessWidget {
  const Contact({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/s69.jpeg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: Colors.black,
                  width: 5,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'This app is developed by sirimath',
            style: TextStyle(
              //fontSize: 40,
              //fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  launchUrlString('https://github.com/sirimathxd');
                },
                icon: const Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
