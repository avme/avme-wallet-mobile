import 'dart:async';
import 'package:avme_wallet/app/controller/services/push_notification.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/external/contracts/erc20_contract.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:decimal/decimal.dart';
import 'package:async/async.dart';
import '../threads.dart';

Future<bool> balanceSubscription(AvmeWallet appState) async {
  Map<int, AccountObject> accounts = appState.accountList;
  int currentWalletId = appState.currentWalletId;

  Threads th = Threads.getInstance();
  List<Stream> processPool = [];

  for (int pos = 0; pos < accounts.length; pos++)
  {
    Map data = {};
    if (pos == currentWalletId) {
      data = {
        "id": currentWalletId,
        "updateIn": 10,
        "url": env['NETWORK_URL'],
        "activeTokens": appState.activeContracts.tokens,
        "contracts": appState.activeContracts.sContracts.contracts,
        "address": EthereumAddress.fromHex(appState.currentAccount.address),
      };
    }
    else {
      data = {
        "id": pos,
        "updateIn": 15,
        "url": env['NETWORK_URL'],
        "activeTokens": appState.activeContracts.tokens,
        "contracts": appState.activeContracts.sContracts.contracts,
        "address": EthereumAddress.fromHex(appState.accountList[pos].address),
      };
    }

    ThreadMessage task = ThreadMessage(
      caller: "balanceSubscription",
      params: [data],
      function: trackBalance
    );

    processPool.add(
      th.addToPool(
        id: 0,
        task: task,
        shouldReturnReference: true,
      )
    );
  }
  printWarning("process pool size: ${processPool.length}");
  StreamGroup.merge(processPool).listen((event) {
    if(event is ThreadReference)
    {
      // printMark("Received ThreadReference ID: ${event.processId}");
      appState.addProcess("balanceSubscription", event);
      return;
    }
    else
    {
      // for(ThreadReference processo in appState.tProcesses["balanceSubscription"])
      // {
      //   printMark("ID:${processo.processId} Caller: ${processo.caller} Noise: ${processo.noise}");
      // }

      List<Map> balanceData = event["balanceSubscription"]["balance"];
      int accId = event["balanceSubscription"]["id"];

      ///Recovering the account to apply the requested data
      AccountObject accountObject = appState.accountList[accId];
      double oldBalance = 0;
      double updatedBalance = 0;

      balanceData.forEach((Map requestedBalance) {
        String key = requestedBalance.entries.first.key;
        if (key == "empty") return;
        print("processing $key");

        ///Recovering the requested value as bigInt/Wei
        BigInt balance = requestedBalance.entries.first.value;

        ///...then convert it to normal double
        double balanceUSD = double.tryParse(weiToFixedPoint(balance.toString()));

        if (key == "AVAX") {
          oldBalance = accountObject.networkBalance;
          // printError("Old Balance $oldBalance, Balance: $balance");
          ///Double
          updatedBalance = oldBalance;

          ///Checking the difference in BigInt/Wei
          if (accountObject.networkTokenBalance != balance) {

            ///Recovering the USD price of "Network Token" that we retrieved in
            ///the valueSubscription routine...
            Decimal networkTokenValue = appState.networkToken.decimal;
            ///Calculating the balance
            updatedBalance = balanceUSD * networkTokenValue.toDouble();

            ///Checking if the balance has been incremented
            if(accountObject.networkTokenBalance < balance && accountObject.networkTokenBalance != BigInt.zero)
            {
              double difference = updatedBalance - accountObject.networkBalance;
              if(difference > 0)
                PushNotification.showNotification(
                  id: 9,
                  title: "Transfer received ($key)",
                  body: "Account Update: "
                      "You received \$${difference.toStringAsFixed(2)}\b ($key) in the Account#$accId ${accountObject.title}.",
                  payload: "app/history"
                );
            }
            printError("Updating avax ${accountObject.networkTokenBalance} <= $balance");
            accountObject.updateAccountBalance = balance;
            ///Finally we update the balance in the account
            accountObject.networkBalance = updatedBalance;
            appState.updateAccountObject(accId, accountObject);
          }
        } else {
          ///When consulting a Smart Contract that does not exist on
          ///api.thegraph.com the default value will be 1 USD
          double tokenValue = 1;
          if (accountObject.tokensBalanceList.containsKey(key)) {
            oldBalance = accountObject.tokensBalanceList[key]["balance"];
          }

          ///Recovering the USD price of "Token" that we retrieved in
          ///the valueSubscription routine...

          tokenValue = appState.activeContracts.token.decimal(key).toDouble();

          ///Stored as String

          updatedBalance = oldBalance;

          ///Calculating the balance
          updatedBalance = balanceUSD * tokenValue;

          Map<String, dynamic> preparedData = {
            "wei" : balance,
            "balance" : updatedBalance
          };

          ///Checking the prepared data and inserting it
          // print("NOSSO MAP $key");
          // print(preparedData);

          String mainName = key.replaceAll(" testnet", "");

          if(accountObject.tokensBalanceList[key] != null)
          {
            BigInt tWei = accountObject.tokensBalanceList[key]["wei"];

            ///Checking if the balance has been incremented
            if (tWei != balance) {
              ///Houve um incremento
              if(balance > tWei)
              {
                double difference = updatedBalance - accountObject.tokensBalanceList[key]["balance"];
                if (difference > 0)
                  PushNotification.showNotification(
                    id: 9,
                    title: "Transfer received ($key)",
                    body: "Account Update: "
                        "You received \$${difference.toStringAsFixed(2)}\b ($key) in the Account#$accId ${accountObject.title}.",
                    payload: "app/history"
                  );
              }

              accountObject.updateTokens(key, preparedData);
              if (appState.activeContracts.tokens.contains(mainName)) {
                accountObject.updateTokens(mainName, preparedData);
              }
              appState.updateAccountObject(accId, accountObject);
            }
          } else
          {
            accountObject.updateTokens(key, preparedData);
            if (appState.activeContracts.tokens.contains(mainName)) {
              accountObject.updateTokens(mainName, preparedData);
            }
            appState.updateAccountObject(accId, accountObject);
          }
        }
      });
    }
  });

  return true;
}

Future<void> trackBalance(List<dynamic> params, {ThreadData threadData, int id, ThreadMessage threadMessage}) async {

  await prepareOperation(id, threadData);
  Map account = params.first;

  EthereumAddress address = account["address"];
  http.Client httpClient = http.Client();
  Web3Client ethClient = Web3Client(account["url"], httpClient);

  print("ethClient: ${account["url"]}");

  ///List of contracts
  Map<String, List> contracts = account["contracts"];

  ///Remember, mounted contracts is stored as
  ///[<ContractAbi>"Contract Abi", <String>"ContractAddress", <String>"ChainID"]

  Map<String, ERC20> contractsERC20 = {};
  account["activeTokens"].forEach((String tokenName) {
    List<dynamic> a = [
      contracts[tokenName][0], // ContractAbi Object
      EthereumAddress.fromHex(contracts[tokenName][1]), // String Address
      ethClient,
      int.tryParse(contracts[tokenName][2]), //Chain ID
    ];

    try {
      contractsERC20[tokenName] = ERC20(
        contracts[tokenName][0], // ContractAbi Object
        address: EthereumAddress.fromHex(contracts[tokenName][1]),
        // String Address
        client: ethClient,
        chainId: int.tryParse(contracts[tokenName][2]), //Chain ID
      );
    } catch (e) {
      print("$tokenName -> $e");
      throw e;
    }
  });
  int seconds = 0;
  List<String> blackList = [];
  while (!threadData.processes[id].isCanceled) {
    await Future.delayed(Duration(seconds: seconds), () async {
      /// AVAX/Network balance
      EtherAmount balance = await ethClient.getBalance(address);
      List<Map> tokenBalance = [];
      /// Tokens balance as List<Map<String TokenName, BigInt balance>>
      tokenBalance =
      await Future.wait(contractsERC20.entries.map((contractItem) {
        if (blackList.contains(contractItem.key))
          return Future.value({
            contractItem.key: {"empty"}
          });
        return wrapAsList(identifier: contractItem.key,
            future: contractItem.value.balanceOf(address),
            processName: "balanceSubscription");
      }));

      tokenBalance.insert(0, {"AVAX": balance.getInWei});
      tokenBalance.forEach((Map map) {
        if (map.entries.first.value == "empty" &&
            !blackList.contains(map.entries.first.key)) blackList.add(
            map.keys.first);
      });
      blackList.forEach((blacklisted) =>
          tokenBalance.removeWhere((element) =>
              element.containsKey(blacklisted)));
      threadMessage.payload = {
        "balanceSubscription": {"balance": tokenBalance, "id": account["id"]}
      };
      threadData.sendPort.send(threadMessage);
      print(blackList);
      if (seconds == 0) seconds = account["updateIn"];
    });
  }
}

Future<Map<int, List>> requestBalanceByAddress(Map<int, String> addresses) async {
  Map<int, List> data = {};
  await Future.forEach(addresses.entries, (entry) async {
    EthereumAddress ethereumAddress = EthereumAddress.fromHex(entry.value);
    String url = env['NETWORK_URL'];

    http.Client httpClient = http.Client();
    Web3Client ethClient = Web3Client(url, httpClient);

    BigInt balance = (await ethClient.getBalance(ethereumAddress)).getInWei;
    String convertedBalance = balance.toDouble() != 0 ? weiToFixedPoint(balance.toString()) : "0";

    data[entry.key] = [
      entry.value,
      shortAmount(convertedBalance, length: 6),
    ];
  });
  return data;
}
