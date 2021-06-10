import 'dart:isolate';

class ServiceData
{
  Map<String, dynamic> data;
  SendPort sendPort;
  ServiceData(this.data, this.sendPort);
}