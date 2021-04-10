import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/link.dart';
import '../utility/category.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db.dart';

class InfoPage extends StatefulWidget {
  final Category category;

  const InfoPage({
    @required this.category,
  }) : assert(category != null);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    final _study = new Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Research Study: Emotions Detection During Online Lectures Using Mobile and Wearable Sensors",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ));
    final _purpose = _createSection(
        "What is the purpose of this research study?",
        "The purpose of this study is to develop an automatic approach to detect students’ emotions during online lectures using sensor data collected with wristband and earbuds. The sensor data includes physiological data (e.g., heart rate, electrodermal activity) and behavioral data (head movements and rotations).");

    final _what = _createSection("What will you do in the study?",
        "You will use this application on your personal smartphone, wear eSense earbuds and the Empatica E4 wristband. The data collected from the eSense earbuds will be used to detect your head gestures (e.g., nodding, head shaking) and facial expressions (e.g., yawning, smiling and talking). The wristband data will be used to detect your emotions during lectures such as e.g., engagement, boredom, confusion. At the end of each lecture block, you should report via surveys sent in Teams the emotions that you experienced during the lecture. Your answers will be used to segment the sensor data into different emotions and to understand which are the main factors that may influence your emotions during online lectures. You can refrain from answering any question you might prefer not to answer (e.g., because it makes you uncomfortable) and you can stop filling-in the questionnaires at any time. The data collected by the application during the lecture, will be uploaded regularly to a secure remote server when clicking the end session button. You should upload your E4 data to Empatica Manager and charge the device every day. All your data will be anonymized and ultimately stored in the academic cloud storage service SWITCHdrive.");

    final _duration = _createSection("How long does it last?",
        "The study phase will require approximately 5 minutes of your time to complete the self-reports sent in Teams after every lecture block and to wear the Empatica E4 wristband and eSense earbuds during the online lectures. The study will last for approximately 10 lectures.");

    final _confidentiality = _createSection(
        "Is my data going to be confidential?",
        "The information and data collected in this study will be stored safely and handled confidentially. Your data will be anonymized through the assignment of an alphanumerical code and your name will never be mentioned in connection to the data or in any report. Any attempt to deduce your identity from the data is explicitly forbidden by our data analysis policy.");

    final _skip = _createSection("Can I skip the study?",
        "Your participation in the study is completely voluntary. You have the right to withdraw from the study at any time without penalty and to require your data to be entirely and permanently deleted.");
    final _contact = _createSection(
        "Contact person if you have questions about the study:",
        "Bianca Maria Stan: bianca.maria.stan@usi.ch\nShkurta Gashi: shkurta.gashi@usi.ch\nElena Di Lascio: elena.di.lascio@usi.ch\nSilvia Santini: silvia.santini@usi.ch");

    final _dataCollected = _createSection(
        "What data does the application collect?",
        "Head movement – Time and amount of head movement in three directions (x, y and z).\nHead rotations – Time and amount of head rotations in three directions (x, y and z).");
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _study,
            new Divider(height: 20.0, color: Colors.white),
            _purpose,
            new Divider(height: 20.0, color: Colors.white),
            _what,
            new Divider(height: 20.0, color: Colors.white),
            _duration,
            new Divider(height: 20.0, color: Colors.white),
            _skip,
            new Divider(height: 20.0, color: Colors.white),
            _confidentiality,
            new Divider(height: 20.0, color: Colors.white),
            _contact,
            new Divider(height: 20.0, color: Colors.white),
            _dataCollected,
            new Divider(height: 40.0, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _createSection(title, text) {
    final _section = new Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 6.0, 0, 5.0),
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text(text),
      ],
    );
    return _section;
  }
}
