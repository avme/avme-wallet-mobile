import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() => runApp(MaterialApp(home: QRScanner()));

class QRScanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  BuildContext _context;
  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  Widget build(BuildContext context) {
    _context = context;
    ButtonStyle invisible =  ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
      shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
    );
    return WillPopScope(
      onWillPop: () async => false,
      child:
        Scaffold(
        body: Container(
          child: Stack(
            // alignment: AlignmentDirectional.center,
            fit: StackFit.expand,
            children: [
              // Expanded(flex: 4, child: _buildQrView(context)),
              Column(
                children: [
                  Expanded(child: _buildQrView(context)),
                ],
              ),

              // color: Colors.blue,
              Column(
                // crossAxisAlignment: CrossAxisAlignment.end,
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child:
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 60,
                              width: 60,
                              child: ElevatedButton(
                                // style: ButtonStyle(
                                //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                //         RoundedRectangleBorder(
                                //             borderRadius: BorderRadius.circular(30)
                                //         )
                                //     )
                                // ),
                                style: invisible,
                                onPressed: () async {
                                  Navigator.pop(context, "returned some data");
                                }, child: Icon(Icons.close),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ),
                  // Expanded(flex: 4,child: SizedBox()),
                  Expanded(
                      flex: 6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (result != null)
                            Text(
                                'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}')
                          else
                            Text('Looking for QR Address'),
                        ],
                      )
                  ),
                  Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.all(8),
                          child: SizedBox(
                            width: 70,
                            height: 70,
                            child: ElevatedButton(
                                style: invisible,
                                onPressed: () async {
                                  await controller?.toggleFlash();
                                  setState(() {});
                                },
                                child: FutureBuilder(
                                  future: controller?.getFlashStatus(),
                                  builder: (context, snapshot) {
                                    // return Text('Flash: ${snapshot.data}');
                                    if(snapshot.data == null) return Container();
                                    return Icon(snapshot.data ? Icons.flash_on : Icons.flash_off, size: 35,);
                                  },
                                )),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(8),
                          child: FutureBuilder(
                            future: controller?.getCameraInfo(),
                            builder:(context, snapshot)
                            {
                              return SizedBox(
                                width: 70,
                                height: 70,
                                child: ElevatedButton(
                                    style: invisible,
                                    onPressed: snapshot.data != null ? () async {
                                      await controller?.flipCamera();
                                      setState(() {});
                                    } : null,
                                    child: FutureBuilder(
                                      future: controller?.getCameraInfo(),
                                      builder: (context, snapshot) {
                                        if (snapshot.data != null) {
                                          return Icon(describeEnum(snapshot.data) == "back" ?
                                            Icons.flip_camera_ios :
                                            Icons.flip_camera_ios_outlined,size: 35,);
                                        } else {
                                          return Text('loading');
                                        }
                                      },
                                    )
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 170.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Color.fromRGBO(233, 70, 101, 1),
          borderRadius: 5,
          borderLength: 15,
          borderWidth: 5,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller){
    setState(() {
      this.controller = controller;
    });
    bool found = false;
    controller.scannedDataStream.listen((scanData){
      if(!found)
      {
        result = scanData;
        controller?.pauseCamera();
        Navigator.pop(context, result.code);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}