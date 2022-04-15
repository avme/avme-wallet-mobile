// @dart=2.12
import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'package:async/async.dart';
import 'dart:isolate';

import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/cupertino.dart';

//TODO 1: remove duplicate functions being runned by the threads
//TODO 2: Fix the login in infinite loop
class Threads extends ChangeNotifier
{
  static final Threads _self = Threads._internal();
  Threads._internal();

  static Threads getInstance()
  {
    return _self;
  }

  List<Isolate> _threadList = [];
  int _threadCount = 0;
  List<Map<String, dynamic>> threadChannel = [];

  void initialize() async
  {
    bool spawned = await newThread();
    if(!spawned)
      throw Exception('Exception at "Threads.initialize"-> Unknown Error');
  }

  ///Spawns a new thread
  ///...
  Future<bool> newThread()
  async {
    _threadCount = _threadCount > 0 ? _threadCount + 1 : 0;
    ///This is our "global" receivePort, used to redirect data to is caller and store the thread information
    ReceivePort threadPort = ReceivePort();
    ThreadData data = ThreadData(id: _threadCount, data: {"data": ["exemple", "data"]}, sendPort: threadPort.sendPort);
    _threadList.add(await Isolate.spawn(thread, data));

    StreamController<dynamic> streamController = StreamController<dynamic>.broadcast();
    threadPort.listen((message) {

      ///At first we watch for the sendPort of the spawned thread
      ///this object "sendPort" is a must to re-use the thread later
      if(message is SendPort)
      {
        threadChannel.add({
          "sendChannel": message,
          "receiveChannel": streamController,
        });
      }
      else if(message is ThreadMessage)
      {
        streamController.add(message);
        // printOk("${message.payload}");
      }
      else
      {
        printOk("$message");
        // streamController.add(message);
      }
    });
    return true;
  }

  ///Send function to the thread
  Stream<dynamic> addToPool({required int id, required ThreadMessage task})
  {
    SendPort port = threadChannel[id]["sendChannel"];
    Stream stream = threadChannel[id]["receiveChannel"].stream;
    StreamSubscription? sub;
    ///Personal ticket
    task.noise = generateId(task.caller!.length + Random().nextInt(9999));
    port.send(task);
    StreamController<dynamic> finalController = StreamController<dynamic>.broadcast();

    sub = stream.listen((event) {
      // print("task.noise:${task.noise} == event.noise:${event.noise}");
      if(event is ThreadMessage) {
        finalController.add(event.payload);
      } else
      {
        printError("[T#Main] Error at addToPool");
      }
      sub!.cancel();
    });
    return finalController.stream;
  }

  ///Cancel any process
  void cancelProcess(int thread, int processId)
  {
    SendPort port = threadChannel[thread]["sendChannel"];
    ThreadOperation tOperation = ThreadOperation("cancel", processId);
    port.send(tOperation);
  }

  @override
  void dispose()
  {
    super.dispose();
    for(int i = _threadList.length; i >= 0; i--)
    {
      _threadList[i].kill();
      _threadList.remove(i);
      threadChannel.removeAt(i);
      _threadCount = 0;
    }
  }
}

class ThreadData
{
  final Map<String, dynamic> data;
  final SendPort sendPort;
  // List<List<dynamic>> processes = [];
  Map<int, CancelableOperation> processes = {};
  final int id;
  ThreadData({
    required this.id, required this.data, required this.sendPort
  });
}

class ThreadMessage
{
  dynamic function;
  List <dynamic>? params;
  String? caller;
  int id = 0;
  int noise = 0;
  dynamic payload;
  ThreadMessage({this.function, this.caller, this.params});
}

class ThreadOperation
{
  final String operation;
  final int processId;
  ThreadOperation(this.operation, this.processId);
}

int generateId(int size)
{
  return randomRangeInt(size, 9999999);
}

///To any thread start a high level function must be passed!
void thread(ThreadData _d)
{
  printOk("[T#${_d.id}] Spawned thread ID# ${_d.id}");

  ReceivePort sender = ReceivePort();
  printOk("[T#${_d.id}] Sending my sendPort back to main()...");
  _d.sendPort.send(sender.sendPort);

  ///Listening to any data received by Main
  sender.listen((message) async {
    printWarning("[T#${_d.id}] Process Count: ${_d.processes.length}");
    int id = generateId(_d.processes.keys.length);
    if(message is ThreadMessage) {
      ThreadMessage threadMessage = message;
      if (threadMessage.function is Function) {
        if (threadMessage.params == null) {
          printWarning("[T#${_d
              .id}] A function without parameters was called \"${threadMessage
              .caller}\"");
          CancelableOperation? operation;

          threadMessage.id = id;
          threadMessage.params = [_d];
          operation = CancelableOperation.fromFuture(
            threadMessage.function(threadData: _d, id: id),
          );
          _d.processes[id] = operation;
        }
        else {
          ///Executing function with parameters
          printOk("[T#${_d.id}] Executing function \"${message.caller}\" with parameters");

          ///Convert it to cancelable please
          threadMessage.id = id;
          Future? future;

          if (_d.processes.containsKey(id)) {
            printError("[T#${_d
              .id}] Thread should not repeat this function \"${threadMessage
              .caller}\" at the same process id#$id");
          }
          threadMessage.params!.add(_d);
          if (threadMessage.function is Function) {
            future = futureWrapper(() {
              Function _f = threadMessage.function;
              dynamic result = _f.call(threadMessage.params, threadData: _d, id: id);
              if (result == null)
                return;
              else
                return result;
            });
          }
          else if (threadMessage.function is Future)
            future = threadMessage.function!(threadMessage.params, threadData: _d, id: id);
          else
            throw Exception('Exception at "Threads.thread"-> [T#${_d
                .id}] Passed a unknown function type, not "Function" or "Future"');

          CancelableOperation? operation = CancelableOperation.fromFuture(
              future!
          );
          _d.processes[id] = operation;
          dynamic result = await operation.value;
          threadMessage.payload = {"message": result, "id": id};
          if(result != null)
          {
            printError("[T#${_d.id}] Closing process #$id, finalized with \"$result\"");
            _d.processes.remove(id);
            _d.sendPort.send(threadMessage);
          }
        }
      }
    }
    else if(message is ThreadOperation)
    {
      switch (message.operation){
        case "cancel":
          if(_d.processes.keys.contains(message.processId))
          {
            await _d.processes[message.processId]!.cancel();
            _d.processes.remove(id);
            _d.sendPort.send({"message": '[T#${_d.id}] Process #${message.processId} has been canceled'});
          }
          else
          {
            _d.sendPort.send({"message": "[T#${_d.id}] No operation found at (${message.processId}) found."});
          }
        break;
        default:
          _d.sendPort.send({"message": "[T#${_d.id}] Undefined operation ${message.operation}"});
        break;
      }
    }
    else
    {
      printError("[T#${_d.id}] Data sent to this thread was not of type \"ThreadMessage\"");
      return;
    }
  });
}

Future<dynamic> futureWrapper(Function function) async
{
  return function();
}
