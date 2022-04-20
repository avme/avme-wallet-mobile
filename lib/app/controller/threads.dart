// @dart=2.12
import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'package:async/async.dart';
import 'dart:isolate';

import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/cupertino.dart';

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
  Map<int, StreamController> endChannel = {};

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
    ThreadData data = ThreadData(id: _threadCount, data: {"data": ["example", "data"]}, sendPort: threadPort.sendPort);
    _threadList.add(await Isolate.spawn(thread, data));

    StreamController<dynamic> streamController = StreamController<dynamic>.broadcast();
    threadPort.listen((message) async {

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
        // printOk("[RECEIVED] ${message.payload}");
      }
      else if(message is ThreadReference)
      {
        streamController.add(message);
        // printMark("Sending a ThreadReference back to main");
      }
      else if (message is ThreadOperation)
      {
        switch (message.operation)
        {
          case "cancel":
            if (endChannel.containsKey(message.processId))
            {
              await endChannel[message.processId]!.close();
              endChannel.removeWhere((key, value) => key == message.processId);
            }
            else
            {
              printError("[T#Main] No StreamController was found with the process ID ${message.processId}");
            }
            break;
          default:
            throw "[T#Main] Error at Thread.listener, unrecognised ThreadOperation \"${message.operation}\"";
            break;
        }
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
  Stream<dynamic> addToPool({required int id, required ThreadMessage task, shouldReturnReference = false})
  {
    SendPort port = threadChannel[id]["sendChannel"];
    Stream stream = threadChannel[id]["receiveChannel"].stream;
    StreamSubscription? sub;
    int noise = generateId(task.caller!.length + Random().nextInt(9999));
    task.noise = noise;
    port.send(task);
    // printWarning("Generated noise ${task.noise} for ${task.caller}");
    StreamController<dynamic> eController = StreamController<dynamic>.broadcast();
    sub = stream.listen((event) async {
      if (eController.isClosed)
        return;
      if (event is ThreadReference)
      {
        if(event.noise == task.noise)
        {
          endChannel[event.processId] = eController;
          if(shouldReturnReference)
            eController.add(event);
        }
      }
      else if (event is ThreadMessage) {
        if(event.noise == noise)
        {
          printOk("[P#${event.id}] ${event.payload}");
          eController.add(event.payload);
          ///Checking if the process was finalized
          if(event.isDone)
          {
            sub!.cancel();
            endChannel[event.id]!.close();
          }
        }
      }
      else
      {
        printError("[T#Main] Error at addToPool, unknown type $event");
      }
    });
    return eController.stream;
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
  Function? function;
  List <dynamic>? params = [];
  String? caller;
  int id = 0;
  int noise = 0;
  dynamic payload;
  bool isDone = false;
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

class ThreadReference
{
  int thread = -1;
  int processId = -1;
  int noise = -1;
  String caller = "";
}

///To any thread start a high level function must be passed!
void thread(ThreadData _d)
{
  printOk("[T#${_d.id}] Spawned thread ID# ${_d.id}");

  ReceivePort sender = ReceivePort();
  printOk("[T#${_d.id}] Sending my sendPort back to main()...");
  _d.sendPort.send(sender.sendPort);

  ///Starting our Operation cleaner
  cleaner(_d);
  ///Listening to any data received by Main
  sender.listen((message) async {
    int id = generateId(_d.processes.keys.length);
    if(message is ThreadMessage) {
      ThreadMessage threadMessage = message;
      if (threadMessage.function is Function) {
        // if (threadMessage.params == null) {
        //   printWarning("[T#${_d
        //       .id}] A function without parameters was called \"${threadMessage
        //       .caller}\"");
        //
        //   CancelableOperation? operation;
        //   threadMessage.id = id;
        //   // threadMessage.params = [_d];
        //   ///Sending the thread reference
        //   ThreadReference threadReference = ThreadReference()
        //     ..processId = id
        //     ..thread = _d.id;
        //
        //   _d.sendPort.send(threadReference);
        //   operation = CancelableOperation.fromFuture(
        //     threadMessage.function!(threadData: _d, id: id),
        //     // onCancel: () {
        //     //   if(_d.processes.containsKey(id))
        //     //   {
        //     //     printError("[T#${_d.id}] Process $id was cancelled.");
        //     //     threadMessage.isDone = true;
        //     //     _d.sendPort.send(threadMessage);
        //     //   }
        //     // }
        //   );
        //   _d.processes[id] = operation;
        //   dynamic result = await operation.value;
        //   threadMessage.payload = {"message": result, "id": id};
        //   if(result != null)
        //   {
        //     printError("[T#${_d.id}] Closing process #$id, finalized with \"$result\"");
        //     _d.processes.remove(id);
        //     threadMessage.isDone = true;
        //     _d.sendPort.send(threadMessage);
        //   }
        // }
        // else {
          ///Executing function with parameters
          printOk("[T#${_d.id}] Executing function \"${message.caller}\" with parameters");

          ///Convert it to cancelable please
          threadMessage.id = id;
          // Future? future;

          if (_d.processes.containsKey(id)) {
            printError("[T#${_d
              .id}] Thread should not repeat this function \"${threadMessage
              .caller}\" at the same process id#$id");
          }

          ///Sending the thread reference
          ThreadReference threadReference = ThreadReference()
            ..processId = id
            ..thread = _d.id
            ..noise = threadMessage.noise
            ..caller = threadMessage.caller!;

          _d.sendPort.send(threadReference);
          _d.processes[id] = CancelableOperation.fromFuture(
            threadMessage.function!(threadMessage.params, threadMessage: threadMessage, threadData: _d, id: id)
          );
          dynamic result = await _d.processes[id]!.value;
          threadMessage.payload = {"message": result, "id": id};
          if(result != null)
          {
            printError("[T#${_d.id}] Closing process #$id, finalized with \"$result\"");
            threadMessage.isDone = true;
            _d.sendPort.send(threadMessage);
            _d.processes.remove(id);
          }
        // }
      }
    }
    else if(message is ThreadOperation)
    {
      switch (message.operation){
        case "cancel":
          if(_d.processes.keys.contains(message.processId))
          {

            // _d.processes.remove(_d.processes[message.processId]);
            _d.sendPort.send({"message": '[T#${_d.id}] Process #${message.processId} has been canceled'});
            ///DO NOT USE LOOPS INSIDE A FUNCTION VOIDED, IT WILL FINISH AND NOT BE ABLE TO BE CANCELABLE

            await _d.processes[message.processId]!.cancel().then((value) {
              // printError("CANCELED? ${_d.processes[message.processId]!.isCanceled}");
              // printError("COMPLETED? ${_d.processes[message.processId]!.isCompleted}");
              // _d.processes.removeWhere((key, value) => key == message.processId);
            });
            ///Closing the StreamController used by its caller
            _d.sendPort.send(ThreadOperation("cancel", message.processId));
          }
          else
          {
            _d.sendPort.send({"message": "[T#${_d.id}] No operation found at (${message.processId}) found."});
          }
          break;
        case "kill":
          {
            printWarning("[T#${_d.id}] Killing process ${message.processId}");
            _d.processes.removeWhere((key, value) => key == message.processId);
          }
          break;
        default:
          _d.sendPort.send({"message": "[T#${_d.id}] Undefined operation ${message.operation}"});
          break;
      }
    }
    else
    {
      printError("[T#${_d.id}] Data sent to this thread was not of type \"ThreadOperation\"");
      return;
    }
  });
}

Future<dynamic> futureWrapper(Function function) async
{
  return function();
}

void cleaner(ThreadData threadData)
async {
  do {
    await Future.delayed(Duration(milliseconds: 100), (){
      List<int> keys = threadData.processes.keys.toList();
      keys.forEach((processId) {
        if(threadData.processes[processId] != null && (threadData.processes[processId]!.isCanceled || threadData.processes[processId]!.isCompleted))
        {
          threadData.processes.removeWhere((key, value) => key == processId);
        }
      });
    });
  }
  while(true);
}

Future<void> prepareOperation(int id, ThreadData threadData)
async {
  int _m = 2;
  printMark("[T#${threadData.id}] Preparing process id $id.");
  while(threadData.processes[id] == null)
  {
    if(_m > 2)
      printWarning("[T#${threadData.id}] $_m ms has been passed since the process $id was called...");
    await Future.delayed(Duration(milliseconds: _m));
    _m += 2;
  }
}