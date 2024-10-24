import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:simple_frame_app/rx/tap.dart';

import 'package:simple_frame_app/simple_frame_app.dart';
import 'package:simple_frame_app/tx/code.dart';
import 'package:simple_frame_app/tx/plain_text.dart';

void main() => runApp(const MainApp());

final _log = Logger("MainApp");

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => MainAppState();
}

/// SimpleFrameAppState mixin helps to manage the lifecycle of the Frame connection outside of this file
class MainAppState extends State<MainApp> with SimpleFrameAppState {
  StreamSubscription<int>? _tapSubs;
  String? _message;

  MainAppState() {
    Logger.root.level = Level.FINER;
    Logger.root.onRecord.listen((record) {
      debugPrint(
          '${record.level.name}: [${record.loggerName}] ${record.time}: ${record.message}');
    });
  }

  @override
  Future<void> run() async {
    currentState = ApplicationState.running;
    if (mounted) setState(() {});

    try {
      _tapSubs?.cancel();
      _tapSubs = RxTap().attach(frame!.dataResponse)
        .listen((taps) {
          _message = '$taps-tap detected';
          frame!.sendMessage(TxPlainText(msgCode: 0x12, text: _message!));
          setState(() {});
        });

      // let Frame know to subscribe for taps and send them to us
      await frame!.sendMessage(TxCode(msgCode: 0x10, value: 1));

      await Future.delayed(const Duration(seconds: 1));

      // prompt the user to begin tapping
      await frame!.sendMessage(TxPlainText(msgCode: 0x12, text: 'Tap away!'));

    } catch (e) {
      _log.fine('Error executing application logic: $e');
      currentState = ApplicationState.ready;
      if (mounted) setState(() {});
    }
  }

  @override
  Future<void> cancel() async {
    // let Frame know to cancel subscription for taps
    await frame!.sendMessage(TxCode(msgCode: 0x10, value: 0));

    // clear
    await frame!.sendMessage(TxPlainText(msgCode: 0x12, text: ' '));

    currentState = ApplicationState.ready;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frame Tap Detector',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
            title: const Text('Frame Tap Detector'),
            actions: [getBatteryWidget()]),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Text(_message ?? '(Connect, Start, Run, then) Tap Frame to start!')),
            ],
          ),
        ),
        floatingActionButton: getFloatingActionButtonWidget(
            const Icon(Icons.file_open), const Icon(Icons.close)),
        persistentFooterButtons: getFooterButtonsWidget(),
      )
    );
  }
}
