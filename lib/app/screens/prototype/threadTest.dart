import 'dart:async';

import 'package:avme_wallet/app/controller/threads.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThreadContainer extends StatefulWidget {
  const ThreadContainer({Key key}) : super(key: key);

  @override
  _ThreadTestState createState() => _ThreadTestState();
}

class Cart extends ChangeNotifier
{
  int qtd = 0;

  Cart();

  void increment()
  {
    qtd++;
    notifyListeners();
  }

  void decrease()
  {
    qtd--;
    notifyListeners();
  }
}

class _ThreadTestState extends State<ThreadContainer> {

  String message = "no meme here";
  TextEditingController processController = TextEditingController();
  void sendDataToThread()
  {
    Threads _t = Threads.getInstance();

    ///Creating our stream listener

    // ThreadMessage m = ThreadMessage(
    //     caller: "infiniteCount",
    //     function: infiniteCount
    // );
    // StreamSubscription sub;
    // sub = _t.addToPool(id: 0, task: m).listen((event) {
    //   printWarning("infiniteCount returned $event");
    //   sub.cancel();
    // });

    ThreadMessage m = ThreadMessage(
        caller: "threadMe",
        params: ["meme, anal sex jajajaja"],
        function: threadMe
    );
    StreamSubscription sub;
    sub = _t.addToPool(id: 0, task: m).listen((event) {
      printWarning("Banana $event");
      sub.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test threads"),
      ),
      body: ListView(
        children: [
          ChangeNotifierProvider<Cart>(
            create: (context) => Cart(),
            child: ListTile(
              title: Text("Increment"),
              trailing: Consumer<Cart>(
                builder: (_, cart, __) {
                  return ElevatedButton(
                    onPressed: () {
                      cart.increment();
                    },
                    child: Text("+"),
                  );
                },
              ),
              subtitle: Consumer<Cart>(
                builder: (_, cart, __) {
                  return Text("QTD: ${cart.qtd}");
                },
              ),
            ),
          ),
          ChangeNotifierProvider<Cart>(
            create: (context) => Cart(),
            child: ListTile(
              title: Text("Add function to thread 0 / $message"),
              trailing: Consumer<Cart>(
                builder: (_, cart, __) {
                  return ElevatedButton(
                    onPressed: () async {
                      sendDataToThread();
                      // await _t.newThread();
                      // for(int i = 0; i < 5; i++)
                      // {
                      //   await Future.delayed(Duration(seconds: 1));
                      //   printWarning("${_t.threadChannel.length}");
                      // }

                      // cart.increment();
                    },
                    child: Text("+"),
                  );
                },
              ),
              subtitle: Consumer<Cart>(
                builder: (_, cart, __) {
                  return Text("QTD: ${cart.qtd}");
                },
              ),
            ),
          ),
          ListTile(
            title: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: TextField(
                        controller: processController,
                        onTap: () {
                          setState(() {});
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            helperText: "type the process id"
                        ),
                      ),
                    ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: (){
                            Threads th = Threads.getInstance();
                            th.cancelProcess(0, int.parse(processController.text));
                          },
                          child: const Text("Terminate"),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

dynamic threadMe(List<dynamic> params,
  {
    @required ThreadData threadData,
    @required int id
  }){
  print(params.first);
  return params.first;
}

Future<bool> infiniteCount({
  @required ThreadData threadData,
  @required int id
}) async
{
  int passed = 0;
  do
  {
    if(threadData.processes[id] != null && threadData.processes[id].isCanceled)
    {
      break;
    }
    await Future.delayed(Duration(seconds: 1), (){
      passed++;
      printWarning("[T#${threadData.id} P#$id] Seconds passed $passed");
    });
  }
  while(true);
  return true;
}

class ThreadTest extends StatelessWidget {
  const ThreadTest({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ThreadContainer(),
    );
  }
}
