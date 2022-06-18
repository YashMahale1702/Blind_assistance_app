import 'package:flutter/material.dart';

class MailScreen extends StatefulWidget {
  const MailScreen({Key key}) : super(key: key);

  static const routeName = '/mail_screen';

  @override
  _MailScreenState createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mail Screen'),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: const [
          Center(
            child: Text('Mail screen'),
          )
        ],
      )),
    );
  }
}
