// @dart=2.12
import 'package:flutter/material.dart';

class AddressBar extends StatefulWidget {
  const AddressBar({
    required this.addressController,
    required this.enabled
  });

  final TextEditingController addressController;
  final bool enabled;
  @override
  _AddressBarState createState() => _AddressBarState();
}

class _AddressBarState extends State<AddressBar> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: widget.enabled
          ? TextFormField(
            controller: widget.addressController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black12,
              // fillColor: AppColors.purpleDark2,
              contentPadding: EdgeInsets.all(4),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          )
          : Container(),
      ),
    );
  }
}
