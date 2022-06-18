import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:mini_project/screens/mail_screen.dart';
import 'package:mini_project/screens/read_pdf_screen.dart';
import 'package:provider/provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:sms_advanced/sms_advanced.dart';

// import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

import '../provider/data_provider.dart';
import '../models/helpers.dart';
import './maps_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechToText _speechToText = SpeechToText();
  TextToSpeech tts = TextToSpeech();

  String _text = '';
  bool _isListening = false;
  String latestMessage = '';
  int _counter = 5;
  final String primaryInst =
      'Wait for 5 Seconds for directions, or to navigate say Navigate to, to read pdf say open sample.pdf, to open mail say mail, to save or call contact say Save/Call contact ';

  SmsQuery query;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    //origin is set
    final data = Provider.of<Data>(context, listen: false);
    data.getUserCurrentLocation();

    //recive the latest messgae
    query = SmsQuery();
    List<SmsMessage> messages = await query.getAllSms;
    setState(() {
      latestMessage = messages[0].body;
    });

    // Navigate to the maps screen
    if (latestMessage.isNotEmpty) {
      Provider.of<Data>(context, listen: false).setDestination =
          latestMessage.substring(38);
      Future.delayed(const Duration(seconds: 5)).then((value) {
        // Navigator.of(context).pushNamed(MapsScreen.routeName);
        //TODO uncomment
      });
    }

    //
    TextToSpeech tts = TextToSpeech();
    tts.speak(primaryInst);

    super.didChangeDependencies();
  }

  void _listen() async {
    Stream<Contact> contacts = await Contacts.streamContacts();

    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (val) {
          if (val == 'done') {
            setState(() {
              _isListening = false;
            });

            // if navigate to or open
            if (_text.contains('navigate to ') && _text.length >= 15) {
              // Navigate to a destination with voice feedback
              Provider.of<Data>(context, listen: false).setDestination =
                  _text.substring(12);
              Navigator.of(context).pushNamed(MapsScreen.routeName);
            } else if (_text.contains('open ')) {
              //open pdf and read the text
              Navigator.of(context).pushNamed(
                ReadPdfScreen.routeName,
                arguments: {
                  'filename': 'file-sample_150kB',
                },
              );
            } else if (_text.contains('mail ')) {
              //mail
              Navigator.of(context).pushNamed(MailScreen.routeName);
            } else if (_text.contains('save contact')) {
              //save contact
              // Contacts.addContact(
              //   Contact(
              //     displayName: 'Example',
              //     phones: [Item(label: 'Personal', value: '+910000000000')],
              //   ),
              // );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  duration: Duration(seconds: 10),
                  content: Text('Saving contact'),
                ),
              );
            } else if (_text.contains('call ')) {
              //cal
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 10),
                  content: Text('Calling ${_text.substring(5)}'),
                ),
              );
            }
          }
        },
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blind Assistance'),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       Navigator.of(context).pushNamed(MapsScreen.routeName);
        //       // TODO uncomment
        //     },
        //     icon: const Icon(Icons.navigation_rounded),
        //   )
        // ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            child: Image.asset('assets/images/logo.png'),
            height: 100,
          ),
          const SizedBox(
            height: 5,
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            // elevation: 4.0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Note',
                    style: TextStyle(
                      fontSize: 22,
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.wavy,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    primaryInst,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            // elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: latestMessage.isEmpty
                  ? Column(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        ),
                        Text(
                          'Waiting for the message',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Icon(
                              Icons.message,
                              color: latestMessage.isEmpty
                                  ? Colors.black
                                  : Colors.green,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              'Message retrived is',
                              style: TextStyle(
                                fontSize: 16.0,
                                // fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          latestMessage,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                        ),
                      ],
                    ),
            ),
          ),
          if (_text.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                // elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Generated through input command',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextHighlight(
                        text: _text.toUpperCase(),
                        words: Helpers.highlights,
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.0,
                          fontFamily: 'Quicksand',
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.dashed,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}


// void _getVoiceData() {
  //   tts.speak('Say the destination...');
  //   Future.delayed(const Duration(seconds: 3)).then((value) async {
  //     initSpeech();
  //     Future.delayed(const Duration(seconds: 6)).then((value) {
  //       tts.speak('Did you say $_text say yes to confirm').then((value) {
  //         confirmSpeech();
  //         Future.delayed(const Duration(seconds: 15)).then((value) {
  //           if (_confirm.toLowerCase().contains('yes')) {
  //             tts.stop();
  //             Navigator.of(context).pushNamed(MapsScreen.routeName);
  //           } else {
  //             _getVoiceData();
  //           }
  //         });
  //       });
  //     });
  //   });
  // }