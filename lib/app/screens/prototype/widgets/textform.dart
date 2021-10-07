import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {

  final Color cursorColor;
  final Function validator;
  final Function onChanged;
  final Function iconOnTap;
  final TextEditingController controller;
  final bool obscureText;
  final bool enabled;
  final FocusNode focusNode;
  final String labelText;
  final Widget icon;
  final Key formKey;
  final String initialValue;
  final FloatingLabelBehavior floatingLabelBehavior;
  final TextInputType keyboardType;
  final EdgeInsets contentPadding;
  final bool isDense;
  final TextAlign textAlign;

  const AppTextFormField({
    Key key,
    this.cursorColor = AppColors.purple,
    this.validator,
    this.onChanged,
    this.controller,
    this.obscureText = false,
    this.focusNode,
    this.labelText,
    this.enabled,
    this.icon,
    this.formKey,
    this.iconOnTap,
    this.floatingLabelBehavior = FloatingLabelBehavior.always,
    this.initialValue,
    this.keyboardType,
    this.isDense = false,
    this.textAlign = TextAlign.left,
    this.contentPadding = const EdgeInsets.symmetric(
      vertical: 16,
      horizontal: 12
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Color cLabelStyle = AppColors.labelDefaultColor;
    FontWeight fLabelStyle = FontWeight.w900;
    OutlineInputBorder fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.0),
        borderSide: BorderSide(
          width: 2
        )
    );


    if(this.focusNode != null)
    {
      cLabelStyle = this.focusNode.hasFocus ? AppColors.purple : AppColors.labelDefaultColor;
      fLabelStyle = this.focusNode.hasFocus ? FontWeight.w900 : FontWeight.w500;
    }

    return Form(
      key: this.formKey,
      child: Stack(
        children: [
          Column(
            children: [
              TextFormField(
                enabled: this.enabled,
                validator: this.validator,
                controller: this.controller,
                cursorColor: this.cursorColor,
                obscureText: this.obscureText,
                initialValue: this.initialValue,
                textAlign: this.textAlign,
                focusNode: this.focusNode,
                keyboardType: this.keyboardType,
                onChanged: this.onChanged,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.darkBlue,
                  focusedErrorBorder: fieldBorder.copyWith(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.red,
                      )
                  ),
                  errorBorder: fieldBorder.copyWith(
                      borderSide: BorderSide(
                        width: 2,
                        color: AppColors.labelDefaultColor,
                      )
                  ),
                  labelText: this.labelText,
                  floatingLabelBehavior: this.floatingLabelBehavior,
                  contentPadding: this.contentPadding,
                  enabledBorder: fieldBorder.copyWith(
                    borderSide: BorderSide(
                      width: 2,
                      color: cLabelStyle,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: fieldBorder.borderRadius,
                    borderSide: BorderSide(
                      width: 0,
                      color: Colors.transparent
                    )
                  ),
                  labelStyle: TextStyle(
                      color: cLabelStyle,
                      fontWeight: fLabelStyle,
                      fontSize: 20
                  ),
                  focusedBorder: fieldBorder.copyWith(
                    borderSide: BorderSide(
                        width: 2,
                        color: AppColors.purple
                    ),
                  ),
                )
              ),
            ],
          ),
          this.icon != null
          ? Positioned.fill(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: this.iconOnTap,
                    child: Container(
                      // color: Color.fromRGBO(255, 50, 50, 0.2),
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            // width: 48,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                color: AppColors.darkBlue,
                                child: this.icon)
                              ,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              )
          )
          : Container()
        ],
      ),
    );
  }
}
