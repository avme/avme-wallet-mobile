import 'package:avme_wallet/app/model/token_chart.dart';
import 'package:hive/hive.dart';

class Boxes
{
  static Box<TokenChart> getHistory() => Hive.box<TokenChart>('dashboard_chart');
}