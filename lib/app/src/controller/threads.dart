import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'package:async/async.dart';
import 'package:avme_wallet/app/src/helper/utils.dart';

import 'package:flutter/cupertino.dart';

import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/helper/enums.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'network/connection.dart';

class Threads extends ChangeNotifier
{
  static final Threads _self = Threads._internal();
  Threads._internal() {
    _initialize();
  }

  factory Threads() => _self;

  List<Isolate> _threadList = [];
  int _threadCount = 0;
  List<Map<String, dynamic>> threadChannel = [];
  Map<int, StreamController> endChannel = {};
  Completer<bool> init = Completer();
  void _initialize() async
  {
    await newThread();
    // if(!spawned) {
    //   throw Exception('Exception at "Threads.initialize"-> Unknown Error');
    // }
    //
  }

  void printChannels()
  {
    Print.mark("Thread Count: ${_threadList.length}");
    Print.mark("Thread Channel Count: ${threadChannel.length}");
  }

  ///Spawns a new thread
  ///...
  Future<bool> newThread()
  async {
    ///This is our "global" receivePort, used to redirect data to is caller and store the thread information
    ReceivePort threadPort = ReceivePort();
    ThreadInfo data = ThreadInfo(
      id: _threadCount,
      data: {"data": ["example", "data"]},
      sendPort: threadPort.sendPort,
      debug: dotenv.env["DEBUG_MODE"] == "TRUE" ? true : false
    );
    _threadList.add(await Isolate.spawn(thread, data));

    StreamController<dynamic> streamController = StreamController<dynamic>.broadcast();
    threadPort.listen((message) async {
      // Print.mark(message.toString());
      ///At first we watch for the sendPort of the spawned thread
      ///this object "sendPort" is a must to re-use the thread later
      if(message is SendPort)
      {
        threadChannel.add({
          "sendChannel": message,
          "receiveChannel": streamController,
        });
        init.complete(true);
        Print.warning("printChannels [0]");
        // printChannels();
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
          case OperationTypes.cancel:
            if (endChannel.containsKey(message.processId))
            {
              await endChannel[message.processId]!.close();
              endChannel.removeWhere((key, value) => key == message.processId);
            }
            else
            {
              Print.error("[T#Main] No StreamController was found with the process ID ${message.processId}");
            }
            break;
          case OperationTypes.hasConnection:
            Connection appConnection = Connection();
            SendPort _s = threadChannel[_threadCount]["sendChannel"];
            _s.send([
              message,
              appConnection.hasConnection
            ]);
            break;
          default:
            throw "[T#Main] Error at Thread.listener, unrecognised ThreadOperation \"${message.operation}\"";
        }
      }
      else
      {
        Print.ok("$message");
        // streamController.add(message);
      }
    });
    _threadCount++;
    // threadPort.sendPort.send(threadPort.sendPort);
    return init.future;
  }

  ///Send function to the thread
  Stream<dynamic> addToPool({required int id, required ThreadMessage task, shouldReturnReference = false})
  {
    // Print.mark("THREAD CHANNEL LIST ${threadChannel.toString()}");
    SendPort port = threadChannel[id]["sendChannel"];
    Stream stream = threadChannel[id]["receiveChannel"].stream;
    StreamSubscription? sub;
    int noise = generateId(task.caller!.length + Random().nextInt(9999));
    task.noise = noise;
    port.send(task);
    // Print.warning("Generated noise ${task.noise} for ${task.caller}");
    StreamController eController = StreamController.broadcast();
    sub = stream.listen((event) async {
      if(eController.isClosed) {
        return;
      }
      if(event is ThreadReference)
      {
        if(event.noise == task.noise)
        {
          endChannel[event.processId] = eController;
          if(shouldReturnReference) {
            eController.add(event);
          }
        }
      }
      else if(event is ThreadMessage) {
        if(event.noise == noise)
        {
          // printOk("[P#${event.id}] ${event.payload}");
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
        Print.error("[T#Main] Error at addToPool, unknown type $event");
      }
    });
    return eController.stream;
  }

  ///Receives an ThreadReference and tries to "kill" by forcing an Listener of CancelableOperation
  void cancelProcess(ThreadReference reference)
  {
    SendPort port = threadChannel[reference.thread]["sendChannel"];
    ThreadOperation tOperation = ThreadOperation(OperationTypes.cancel, reference.processId);
    port.send(tOperation);
  }

  @override
  void dispose()
  {
    for(Isolate isolate in _threadList)
    {
      isolate.kill();
    }
    _threadList = [];
    threadChannel = [];
    _threadCount = 0;
    super.dispose();
  }
}

class ThreadInfo
{
  final Map<String, dynamic> data;
  final SendPort sendPort;
  final bool debug;
  Stream? stream;
  // List<List<dynamic>> processes = [];
  Map<int, CancelableOperation> processes = {};
  final int id;
  ThreadInfo({
    required this.id,
    required this.data,
    required this.sendPort,
    required this.debug,
  });

  Future<bool> hasConnection(int processId) async {
    bool hasValue = false;
    bool value = false;
    ThreadOperation threadOperation = ThreadOperation(OperationTypes.hasConnection, processId);
    sendPort.send(threadOperation);
    /*
      [ThreadOperation, value]
    */
    stream!.listen((message) {
      if (message is List && message[0] is ThreadOperation) {
        if(message[0].operation == OperationTypes.hasConnection && message[0].processId == processId)
        {
          value = message[1];
          hasValue = !hasValue;
        }
      }
    });

    do await Future.delayed(Duration(milliseconds: 50));
    while(!hasValue);
    return value;
  }
}

class ThreadMessage
{
  Function? function;
  List <dynamic>? params;
  String? caller;
  int id = 0;
  int noise = 0;
  dynamic payload;
  bool isDone = false;
  ThreadMessage({this.function, this.caller, List params = const []}){
    this.params = params;
  }

  @override
  String toString()
  {
    return
'''Function: $function
Params: $params
Caller: ${caller ?? "empty"}
Id: $id
Noise; $noise,
Payload: $payload,
isDone: $isDone
''';
  }
}

class ThreadWrapper {
  ThreadInfo info;
  int id;
  ThreadMessage message;
  ThreadWrapper(this.info, this.id, this.message);

  bool isCanceled()
  {
    return info.processes[id]!.isCanceled;
  }

  void send(Object _message)
  {
    message.payload = _message;
    info.sendPort.send(message);
  }
}

class ThreadOperation
{
  final OperationTypes operation;
  final int processId;
  ThreadOperation(this.operation, this.processId);
}

int generateId(int size)
{
  return Utils.randomRangeInt(size, 9999999);
}

class ThreadReference
{
  int thread = -1;
  int processId = -1;
  int noise = -1;
  String caller = "";

  @override
  String toString() {
    return "(ThreadReference) $caller: Thread# $thread | ProcessID# $processId | Noise# $noise";
  }
}

///To any thread start a high level function must be passed!
void thread(ThreadInfo _d) async
{
  Print(debug: _d.debug);
  Print.ok("[T#${_d.id}] Spawned thread ID# ${_d.id}");
  ReceivePort sender = ReceivePort();
  Print.ok("[T#${_d.id}] Sending my sendPort back to main()...");
  Stream stream = sender.asBroadcastStream();
  _d.stream = stream;
  _d.sendPort.send(sender.sendPort);
  ///Starting our Operation cleaner
  cleaner(_d);
  ///Listening to any data received by Main
  stream.listen((message) async {
    int id = generateId(_d.processes.keys.length);
    if(message is ThreadMessage) {
      ThreadMessage threadMessage = message;
      if (threadMessage.function is Function) {
        ///Executing function with parameters
        Print.ok("[T#${_d.id}] Executing function \"${message.caller}\" with parameters");

        ///Convert it to cancelable please
        threadMessage.id = id;
        // Future? future;

        if (_d.processes.containsKey(id)) {
          Print.error("[T#${_d
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
        ThreadWrapper wrap = ThreadWrapper(_d, id, threadMessage);
        _d.processes[id] = CancelableOperation.fromFuture(
            threadMessage.function!(threadMessage.params, wrap)
        );
        dynamic result = await _d.processes[id]!.value;
        threadMessage.payload = {"message": result, "process-id": id};
        if(result != null)
        {
          Print.error("[T#${_d.id}] Closing process #$id, finalized with \"$result\"");
          threadMessage.isDone = true;
          _d.sendPort.send(threadMessage);
          _d.processes.remove(id);
        }
      }
    }
    else if(message is ThreadOperation)
    {
      switch (message.operation){
        case OperationTypes.cancel:
          if(_d.processes.keys.contains(message.processId))
          {

            // _d.processes.remove(_d.processes[message.processId]);
            _d.sendPort.send({"message": '[T#${_d.id}] Process #${message.processId} has been canceled'});
            ///DO NOT USE LOOPS INSIDE A FUNCTION VOIDED, IT WILL FINISH AND NOT BE ABLE TO BE CANCELABLE

            await _d.processes[message.processId]!.cancel();
            ///Closing the StreamController used by its caller
            _d.sendPort.send(ThreadOperation(OperationTypes.cancel, message.processId));
          }
          else
          {
            _d.sendPort.send({"message": "[T#${_d.id}] No operation found at (${message.processId}) found."});
          }
          break;
        case OperationTypes.kill:
          {
            Print.warning("[T#${_d.id}] Killing process ${message.processId}");
            _d.processes.removeWhere((key, value) => key == message.processId);
          }
          break;
        default:
          _d.sendPort.send({"message": "[T#${_d.id}] Undefined operation ${message.operation}"});
          break;
      }
    }
    else if(message is List)
    {
      if(message[0] is ThreadOperation)
      {}
    }
    else
    {
      Print.error("[T#${_d.id}] Data sent to this thread was not of type \"ThreadOperation\"");
      return;
    }
  });
}

Future<dynamic> futureWrapper(Function function) async
{
  return function();
}

void cleaner(ThreadInfo threadInfo)
async {
  do {
    await Future.delayed(Duration(milliseconds: 100), (){
      List<int> keys = threadInfo.processes.keys.toList();
      keys.forEach((processId) {
        if(threadInfo.processes[processId] != null && (threadInfo.processes[processId]!.isCanceled || threadInfo.processes[processId]!.isCompleted))
        {
          threadInfo.processes.removeWhere((key, value) => key == processId);
        }
      });
    });
  }
  while(true);
}

Future<void> prepareOperation(ThreadWrapper wrap)
async {
  int _m = 2;
  Print.mark("[T#${wrap.info.id}] Preparing process id ${wrap.id}.");
  while(wrap.info.processes[wrap.id] == null)
  {
    if(_m > 2) {
      Print.warning("[T#${wrap.info.id}] $_m ms has been passed since the process ${wrap.id} was called...");
    }
    await Future.delayed(Duration(milliseconds: _m));
    _m += 2;
  }
}