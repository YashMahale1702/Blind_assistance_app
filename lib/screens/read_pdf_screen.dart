import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:text_to_speech/text_to_speech.dart';

class ReadPdfScreen extends StatefulWidget {
  const ReadPdfScreen({Key key}) : super(key: key);

  static const String routeName = '/read_pdf_screen';

  @override
  _ReadPdfScreenState createState() => _ReadPdfScreenState();
}

class _ReadPdfScreenState extends State<ReadPdfScreen> {
  //     Future<String> getPDFtext(String path) async {
  //   String text = "";
  //   try {
  //     text = await ReadPdfText.getPDFtext(path);
  //   } on PlatformException {
  //     print('Failed to get PDF text.');
  //   }
  //   return text;
  // }

  String _text = '';
  // String fileName = 'network_slicing_5g_final_version_1';
  String fileName = 'file-sample_150kB';
  TextToSpeech tts = TextToSpeech();

  @override
  void didChangeDependencies() async {
    // FilePickerResult result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['pdf', 'doc'],
    // );

    // print(result.files.first.path);

    // if (result != null) {
    //   // PlatformFile file = result.files.first;
    //   // print(file.path);

    String path =
        '/data/user/0/com.example.mini_project/cache/file_picker/$fileName.pdf';

    try {
      await ReadPdfText.getPDFtext(path).then((value) {
        setState(() {
          _text = '';
          _text = value;
        });
        tts.speak('Starting');

        // tts.speak(value.toString());
      });
    } on PlatformException {
      tts.speak('Failed to load the PDF');
    }

    //
    // } else {
    //   debugPrint('User cancelled');
    //   return;
    // }

    super.didChangeDependencies();
  }

  void _fn() {}

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    fileName = routeArgs['filename']; //'file-sample_150kB'
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Read Screen'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AvatarGlow(
        glowColor: const Color.fromARGB(255, 37, 116, 180),
        endRadius: 75.0,
        duration: const Duration(milliseconds: 5000),
        repeatPauseDuration: const Duration(milliseconds: 0),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _fn,
          child: const Icon(
            Icons.volume_up_sharp,
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _text.isEmpty
                  ? Container()
                  : Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'PDF Converted to Text to Speech',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 10.0,
                            margin: const EdgeInsets.all(20.0),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                _text,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
