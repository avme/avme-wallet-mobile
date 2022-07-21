import 'dart:async';
import 'dart:isolate';

import 'package:avme_wallet/app/src/controller/network/network.dart';
import 'package:avme_wallet/app/src/controller/threads.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:flutter_test/flutter_test.dart';

class ThreadsTest{
  static Future<void> testIsolate() async
  {
    List<Isolate> isolates = [];
    ReceivePort receivePort = ReceivePort();
    Completer<bool> completed = Completer();
    isolates.add(
      await Isolate.spawn(isoFunction, ["string1", "string2", receivePort.sendPort])
    );
    receivePort.listen((event) async {
      if(event is SendPort)
      {
        print("received ReceivePort");
        print("sending data back to spawned thread");
        Map data = {"field":"data"};
        print("Main sending $data");
        for(int i = 0; i < 10; i++)
        {
          await Future.delayed(Duration(seconds: 1));
          event.send(data);
        }
      }
      else if(event == "finished")
      {
        completed.complete(true);
      }
      else
      {
        print("event $event");
      }
    });
    await completed.future;
    print("DONE");
  }

  static void isoFunction(List args) async
  {
    SendPort sendport = args[2];
    ReceivePort receiveFromMain = ReceivePort();
    print(args[0]);
    print(args[1]);
    int received = 0;
    sendport.send(receiveFromMain.sendPort);
    receiveFromMain.listen((event) {
      print("Received from main");
      print(event.toString());
      received ++;

      if(received > 9)
      {
        sendport.send("finished");
      }
    });
    sendport.send("isoFunction finished");
  }
  static Future<void> main() async
  {
    Threads? threads;
    group("Threads test", () {
      test("Can initialize Threads", () async {
        threads = Threads();
        bool didStart = await threads!.init.future;
        expect(didStart, true);
      });

      // test("Gathering Coin values", () async {
      //   await Network.observeValueChanges();
      // });

      // test("Gather history data", () async {
      //   bool done = await Network.updateCoinHistory();
      //   expect(done, true);
      // });

      test("Synchronize current day missing dates", () async {
        bool done = await Network.observeTodayHistory();
        expect(done, true);
      });
      test("Dispose Threads", () async {
        ///Dispose after 30 seconds
        for(int i = 7200; i >= 0; i--)
        // for(int i = 10; i >= 0; i--)
        {
          await Future.delayed(Duration(seconds: 1));
          if(i <= 3)
          {
            Print.warning("[Dispose] Auto-dispose in $i seconds");
          }
          if(i == 0)
          {
            threads!.dispose();
          }
        }
      });
    });
  }
}