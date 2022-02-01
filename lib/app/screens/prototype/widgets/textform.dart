import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class AppTextFormField extends StatefulWidget {

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
  final String hintText;
  final FloatingLabelBehavior floatingLabelBehavior;
  final TextInputType keyboardType;
  final EdgeInsets contentPadding;
  final bool isDense;
  final TextAlign textAlign;
  final int maxLength;
  final TextInputAction textInputAction;

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
    this.hintText,
    this.contentPadding = const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 12
    ),
    this.maxLength,
    this.textInputAction
  }) : super(key: key);

  @override
  _AppTextFormFieldState createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> with TickerProviderStateMixin {
  bool hideFloatingIcon = false;
  FocusNode myFocus;
  AnimationController animation;
  Animation<double> fade;
  @override
  void initState() {
    super.initState();

    myFocus = FocusNode();
    animation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    fade = Tween<double>(begin: 1, end: 0).animate(animation);
    myFocus.addListener(() {
      if(hideFloatingIcon)
        animation.reverse();
      else
        animation.forward();
      setState(() {
        hideFloatingIcon = !hideFloatingIcon;
      });
    });
    if(widget.controller != null)
    {
      if(widget.maxLength != null)
        widget.controller.addListener(() {
          setState(() {});
        });
    }

  }
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    myFocus = widget.focusNode ?? myFocus;
    Color cLabelStyle = AppColors.labelDefaultColor;
    FontWeight fLabelStyle = FontWeight.w900;
    OutlineInputBorder fieldBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: BorderSide(
            width: 2
        )
    );

    EdgeInsets contentPadding = widget.contentPadding;
    contentPadding = EdgeInsets.only(top:16, bottom: 16, left:12, right: !hideFloatingIcon && widget.icon != null ? 40 : 12);
    // contentPadding = EdgeInsets.only(top:16, bottom: 16, left:12, right: hideFloatingIcon ? 12 : 40);

    ///Testing if isDense is true, we set same as the default in
    ///"flutter: material/input_decorator.dart", since the padding ain't
    ///being set by the framework
    contentPadding = widget.isDense ? EdgeInsets.fromLTRB(8, 8, 0, 8) : contentPadding;

    cLabelStyle = myFocus.hasFocus ? AppColors.purple : AppColors.labelDefaultColor;
    fLabelStyle = myFocus.hasFocus ? FontWeight.w900 : FontWeight.w500;

    return Stack(
      children: [
        Column(
          children: [
            TextFormField(
              textInputAction: widget.textInputAction,
              maxLength: widget.maxLength,
              maxLengthEnforcement: widget.maxLength != null
                ? MaxLengthEnforcement.enforced
                : MaxLengthEnforcement.none,
              enabled: widget.enabled,
              validator: widget.validator,
              controller: widget.controller,
              cursorColor: widget.cursorColor,
              obscureText: widget.obscureText,
              initialValue: widget.initialValue,
              textAlign: widget.textAlign,
              focusNode: myFocus,
              keyboardType: widget.keyboardType,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                isDense: widget.isDense,
                filled: true,
                hintText: widget.hintText,
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
                labelText: widget.labelText,
                floatingLabelBehavior: widget.floatingLabelBehavior,
                contentPadding: contentPadding,
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
                  fontSize: SizeConfig.fontSize
                ),
                focusedBorder: fieldBorder.copyWith(
                  borderSide: BorderSide(
                    width: 2,
                    color: AppColors.purple
                  ),
                ),
                counter: widget.maxLength != null
                  ? Align(
                      alignment: Alignment.centerRight.add(Alignment(SizeConfig.blockSizeHorizontal / 100 * 1.5, 0)),
                      child: Container(
                        // color:Colors.red,
                        child: Text("${widget.controller.text.length}/${widget.maxLength}",
                          textDirection: TextDirection.rtl,
                          style: AppTextStyles.span.copyWith(fontSize: SizeConfig.fontSize),
                        )
                      ),
                    )
                  : null
              )
            ),
          ],
        ),
        widget.icon != null
            ? Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: FadeTransition(
                  opacity: fade,
                  child: GestureDetector(
                    onTap: widget.iconOnTap,
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
                              padding: const EdgeInsets.all(9),
                              child: Container(
                                color: AppColors.darkBlue,
                                child: widget.icon),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                )
              )
            : Container()
      ],
    );
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }
}

