import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String nfcData = 'No NFC data';

  @override
  void initState() {
    super.initState();
    _initNFC();
  }

  Future<void> _initNFC() async {
    try {
      var availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        //print something
      }

      var tag = await FlutterNfcKit.poll(timeout: Duration(days:1, seconds: 10),
          iosMultipleTagMessage: "Multiple tags found!", iosAlertMessage: "Scan your tag");


      print(jsonEncode(tag));
      bool isNdefAvailable = tag.ndefAvailable ?? false;
      // read NDEF records if available
      if (isNdefAvailable) {
        for (var record in await FlutterNfcKit.readNDEFRecords(cached: false)) {
          setState(() {
                if(record is ndef.TextRecord) {
                  nfcData = record.text ?? "";
                }
          });
        }
      }
    } on Exception catch (e) {
      print('Error initializing NFC: $e');
    }
  }

  @override
  void dispose() {
    FlutterNfcKit.finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Reader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              nfcData,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}