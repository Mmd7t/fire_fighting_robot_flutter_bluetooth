import 'dart:convert';
import 'dart:typed_data';
import 'package:control_pad/control_pad.dart';
import 'package:control_pad/models/pad_button_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  BluetoothConnection connection;

  final TextEditingController textEditingController = TextEditingController();

  bool isConnecting = true;

  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input?.listen(_onDataReceived)?.onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
    }
    super.dispose();
  }

  String received;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        automaticallyImplyLeading: false,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
        ),
        backgroundColor: Colors.indigo,
        title: (isConnecting
            ? Text(
                'Connecting to ' + widget.server.name + '...',
                style: TextStyle(color: Colors.white),
              )
            : isConnected
                ? Text(
                    'Connected with ' + widget.server.name,
                    style: TextStyle(color: Colors.white),
                  )
                : Text(
                    'Disconnected with ' + widget.server.name,
                    style: TextStyle(color: Colors.white),
                  )),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                received ?? 'No received data',
                style: received == null
                    ? Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.black)
                    : Theme.of(context).textTheme.headline5.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
              ),
              const SizedBox(height: 25),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  PadButtonsView(
                    buttons: [
                      PadButtonItem(
                        index: 4,
                        buttonIcon: Icon(Icons.add, color: Colors.white),
                        backgroundColor: Colors.teal,
                      ),
                      PadButtonItem(
                        index: 3,
                        buttonIcon: Icon(Icons.stop, color: Colors.white),
                        backgroundColor: Colors.blue,
                      ),
                      PadButtonItem(
                        index: 2,
                        buttonIcon: Icon(Icons.remove, color: Colors.white),
                        backgroundColor: Colors.amber[700],
                      ),
                      PadButtonItem(
                        index: 1,
                        buttonIcon:
                            Icon(Icons.water_outlined, color: Colors.white),
                        backgroundColor: Colors.red,
                      ),
                    ],
                    buttonsPadding: 10,
                    backgroundPadButtonsColor: Colors.grey.shade100,
                    padButtonPressedCallback: (buttonIndex, gesture) {
                      if (buttonIndex == 1) {
                        print('pumb water');
                        Fluttertoast.showToast(
                            msg: 'Pumb Water', backgroundColor: Colors.green);
                        setState(() => _sendMessage('P'));
                      } else if (buttonIndex == 2) {
                        print('speed down');
                        setState(() => _sendMessage('-'));
                      } else if (buttonIndex == 3) {
                        print('stop car');
                        setState(() => _sendMessage('0'));
                      } else {
                        print('speed up');
                        setState(() => _sendMessage('+'));
                      }
                    },
                  ),
                  JoystickView(
                    backgroundColor: Colors.indigo,
                    innerCircleColor: Colors.pink[700],
                    onDirectionChanged: (degrees, distance) {
                      // print('degreeeeee :: $degrees');
                      // print('distanceeee :: $distance');
                      if (degrees >= 45 && degrees < 135 && distance > 0.5) {
                        print('right');
                        setState(() => _sendMessage('R'));
                      } else if (degrees >= 135 &&
                          degrees < 225 &&
                          distance > 0.5) {
                        print('bottom');
                        setState(() => _sendMessage('D'));
                      } else if (degrees >= 225 &&
                          degrees < 315 &&
                          distance > 0.5) {
                        print('left');
                        setState(() => _sendMessage('L'));
                      } else if ((degrees >= 315 && degrees < 359) ||
                          (degrees >= 0 && degrees < 45) && distance > 0.5) {
                        print('top');
                        setState(() => _sendMessage('U'));
                      } else {
                        print('stop');
                        setState(() => _sendMessage('0'));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        //],
      ),
      // ),
    );
  }

  void _onDataReceived(Uint8List data) {
    if (ascii.decode(data) == 'F' || ascii.decode(data) == 'f') {
      setState(() {
        received = 'There is a fire';
      });
    } else {
      Fluttertoast.showToast(msg: '$data', backgroundColor: Colors.green);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();
    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;
      } catch (e) {
        setState(() {});
      }
    }
  }
}





  // int backspacesCounter = 0;
    // data.forEach((byte) {
    //   if (byte == 8 || byte == 127) {
    //     backspacesCounter++;
    //   }
    // });
    // Uint8List buffer = Uint8List(data.length - backspacesCounter);
    // int bufferIndex = buffer.length;

    // // Apply backspace control character
    // backspacesCounter = 0;
    // for (int i = data.length - 1; i >= 0; i--) {
    //   if (data[i] == 8 || data[i] == 127) {
    //     backspacesCounter++;
    //   } else {
    //     if (backspacesCounter > 0) {
    //       backspacesCounter--;
    //     } else {
    //       buffer[--bufferIndex] = data[i];
    //     }
    //   }
    // }

    // Create message if there is new line character
    // String dataString = String.fromCharCodes(buffer);
    // int index = buffer.indexOf(13);
    // if (~index != 0) {
    //   setState(() {
    //     messages.add(
    //       _Message(
    //         1,
    //         backspacesCounter > 0
    //             ? _messageBuffer.substring(
    //                 0, _messageBuffer.length - backspacesCounter)
    //             : _messageBuffer + dataString.substring(0, index),
    //       ),
    //     );
    //     _messageBuffer = dataString.substring(index);
    //   });
    // } else {
    //   _messageBuffer = (backspacesCounter > 0
    //       ? _messageBuffer.substring(
    //           0, _messageBuffer.length - backspacesCounter)
    //       : _messageBuffer + dataString);
    // }
