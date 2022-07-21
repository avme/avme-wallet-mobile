import 'package:flutter/material.dart';

class Exchange extends StatefulWidget {
  const Exchange({Key? key}) : super(key: key);

  @override
  State<Exchange> createState() => _ExchangeState();
}

class _ExchangeState extends State<Exchange> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Exchange',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
