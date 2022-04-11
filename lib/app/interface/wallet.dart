import 'package:avme_wallet/app/model/account_item.dart';

abstract class AppWallet
{
  Map<int,AccountObject> get accountList;
  set setAccountList (Map<int,AccountObject> accountList);

  int get selectedId;
  set selectedId(int selectedId);
}