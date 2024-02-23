import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pin_theme.dart';

class OTPTextField extends StatefulWidget {
  /// The [BuildContext] of the application
  final BuildContext appContext;

  ///Box Shadow
  final List<BoxShadow>? boxShadows;

  /// length of how many cells there should be. 3-8 is recommended by me
  final int length;

  /// you already know what it does i guess :P default is false
  final bool obscureText;

  final String obscuringCharacter;

  /// Widget used to obscure text
  ///
  /// it overrides the obscuringCharacter
  final Widget? obscuringWidget;

  /// Decides whether typed character should be
  /// briefly shown before being obscured
  final bool blinkWhenObscuring;

  /// Blink Duration if blinkWhenObscuring is set to true
  final Duration blinkDuration;

  /// returns the current typed text in the fields
  final ValueChanged<String> onChanged;

  /// returns the typed text when all pins are set
  final ValueChanged<String>? onCompleted;

  /// returns the typed text when user presses done/next action on the keyboard
  final ValueChanged<String>? onSubmitted;

  /// the style of the text, default is [ fontSize: 20, fontWeight: FontWeight.bold]
  final TextStyle textStyle;

  /// background color for the whole row of pin code fields.
  final Color backgroundColor;

  /// This defines how the elements in the pin code field align. Default to [MainAxisAlignment.spaceBetween]
  final MainAxisAlignment mainAxisAlignment;

  /// Duration for the animation. Default is [Duration(milliseconds: 150)]
  final Duration animationDuration;

  /// [Curve] for the animation. Default is [Curves.easeInOut]
  final Curve animationCurve;

  /// [TextInputType] for the pin code fields. default is [TextInputType.visiblePassword]
  final TextInputType keyboardType;

  /// If the pin code field should be autofocused or not. Default is [false]
  final bool autoFocus;

  /// Should pass a [FocusNode] to manage it from the parent
  final FocusNode? focusNode;

  /// A list of [TextInputFormatter] that goes to the TextField
  final List<TextInputFormatter> inputFormatters;

  /// Enable or disable the Field. Default is [true]
  final bool enabled;

  /// [TextEditingController] to control the text manually. Sets a default [TextEditingController()] object if none given
  final TextEditingController? controller;

  /// Enabled Color fill for individual pin fields, default is [false]
  final bool enableActiveFill;

  /// Auto dismiss the keyboard upon inputting the value for the last field. Default is [true]
  final bool autoDismissKeyboard;

  /// Auto dispose the [controller] and [FocusNode] upon the destruction of widget from the widget tree. Default is [true]
  final bool autoDisposeControllers;

  final TextCapitalization textCapitalization;

  final TextInputAction textInputAction;

  /// Method for detecting a pin_code form tap
  /// work with all form windows
  final Function? onTap;

  /// Theme for the pin cells. Read more [PinTheme]
  final PinTheme pinTheme;

  /// Brightness dark or light choices for iOS keyboard.
  final Brightness keyboardAppearance;

  /// Validator for the [TextFormField]
  final FormFieldValidator<String>? validator;

  /// An optional method to call with the final value when the form is saved via
  /// [FormState.save].
  final FormFieldSetter<String>? onSaved;

  /// enables auto validation for the [TextFormField]
  /// Default is false
  final AutovalidateMode autovalidateMode;

  /// The vertical padding from the [OTPTextField] to the error text
  /// Default is 16.
  final double errorTextSpace;

  /// Enables pin autofill for TextFormField.
  /// Default is true
  final bool enablePinAutofill;

  /// Error animation duration
  final int errorAnimationDuration;

  /// Whether to show cursor or not
  final bool showCursor;

  /// width of the cursor, default to 2
  final double cursorWidth;

  /// Height of the cursor, default to FontSize + 8;
  final double? cursorHeight;

  /// Autofill cleanup action
  final AutofillContextAction onAutoFillDisposeAction;

  /// Use external [AutoFillGroup]
  final bool useExternalAutoFillGroup;

  final String? hintCharacter;

  final TextStyle? hintStyle;

  OTPTextField({
    Key? key,
    required this.appContext,
    required this.length,
    this.controller,
    this.obscureText = false,
    this.obscuringCharacter = '●',
    this.obscuringWidget,
    this.blinkWhenObscuring = false,
    this.blinkDuration = const Duration(milliseconds: 500),
    required this.onChanged,
    this.onCompleted,
    required this.backgroundColor,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.animationDuration = const Duration(milliseconds: 5),
    this.animationCurve = Curves.easeInOut,
    this.keyboardType = TextInputType.visiblePassword,
    this.autoFocus = false,
    this.focusNode,
    this.onTap,
    this.enabled = true,
    this.inputFormatters = const <TextInputFormatter>[],
    required this.textStyle,
    this.enableActiveFill = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.autoDismissKeyboard = true,
    this.autoDisposeControllers = true,
    this.onSubmitted,
    this.pinTheme = const PinTheme.defaults(),
    required this.keyboardAppearance,
    this.validator,
    this.onSaved,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.errorTextSpace = 16,
    this.enablePinAutofill = true,
    this.errorAnimationDuration = 500,
    this.boxShadows,
    this.showCursor = true,
    this.cursorWidth = 2,
    this.cursorHeight,
    this.hintCharacter,
    this.hintStyle,

    /// Default for [AutofillGroup]
    this.onAutoFillDisposeAction = AutofillContextAction.commit,

    /// Default create internal [AutofillGroup]
    this.useExternalAutoFillGroup = false,
  })  : assert(obscuringCharacter.isNotEmpty),
        super(key: key);

  @override
  _OTPTextFieldState createState() => _OTPTextFieldState();
}

class _OTPTextFieldState extends State<OTPTextField>
    with TickerProviderStateMixin {
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  late List<String> _inputList;
  int _selectedIndex = 0;

  // Whether the character has blinked
  bool _hasBlinked = false;

  // AnimationController for the error animation
  late AnimationController _controller;

  late AnimationController _cursorController;

  // Animation for the error animation
  late Animation<Offset> _offsetAnimation;

  late Animation<double> _cursorAnimation;

  PinTheme get _pinTheme => widget.pinTheme;

  Timer? _blinkDebounce;

  TextStyle get _textStyle => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ).merge(widget.textStyle);

  TextStyle get _hintStyle => _textStyle
      .copyWith(
    color: _pinTheme.inactiveColor,
  )
      .merge(widget.hintStyle);

  bool get _hintAvailable => widget.hintCharacter != null;

  @override
  void initState() {
    _checkForInvalidValues();
    _assignController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    }); // Rebuilds on every change to reflect the correct color on each field.
    _inputList = List<String>.filled(widget.length, "");

    _hasBlinked = true;

    _cursorController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _cursorAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _cursorController,
      curve: Curves.easeIn,
    ));
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.errorAnimationDuration),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(.1, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ));
    if (widget.showCursor) {
      _cursorController.repeat();
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });

    // If a default value is set in the TextEditingController, then set to UI
    if (_textEditingController.text.isNotEmpty)
      _setTextToInput(_textEditingController.text);
    super.initState();
  }

  // validating all the values
  void _checkForInvalidValues() {
    assert(widget.length > 0);
    assert(_pinTheme.fieldHeight > 0);
    assert(_pinTheme.fieldWidth > 0);
    assert(_pinTheme.borderWidth >= 0);
  }

  // Assigning the text controller, if empty assiging a new one.
  void _assignController() {
    if (widget.controller == null) {
      _textEditingController = TextEditingController();
    } else {
      _textEditingController = widget.controller!;
    }

    _textEditingController.addListener(() {

      _debounceBlink();

      var currentText = _textEditingController.text;

      if (widget.enabled && _inputList.join("") != currentText) {
        if (currentText.length >= widget.length) {
          if (widget.onCompleted != null) {
            if (currentText.length > widget.length) {
              // removing extra text longer than the length
              currentText = currentText.substring(0, widget.length);
            }
            //  delay the onComplete event handler to give the onChange event handler enough time to complete
            Future.delayed(const Duration(milliseconds: 300),
                    () => widget.onCompleted!(currentText));
          }

          if (widget.autoDismissKeyboard) _focusNode.unfocus();
        }
        widget.onChanged(currentText);
      }

      _setTextToInput(currentText);
    });
  }

  void _debounceBlink() {
    // set has blinked to false and back to true
    // after duration
    if (widget.blinkWhenObscuring &&
        _textEditingController.text.length >
            _inputList.where((x) => x.isNotEmpty).length) {
      setState(() {
        _hasBlinked = false;
      });

      if (_blinkDebounce != null) {
        if (_blinkDebounce?.isActive ?? false) {
          _blinkDebounce!.cancel();
        }
      }

      _blinkDebounce = Timer(widget.blinkDuration, () {
        setState(() {
          _hasBlinked = true;
        });
      });
    }
  }

  @override
  void dispose() {
    if (widget.autoDisposeControllers) {
      _textEditingController.dispose();
      _focusNode.dispose();
    }

    _cursorController.dispose();

    _controller.dispose();
    super.dispose();
  }

  // selects the right color for the field
  Color _getColorFromIndex(int index) {
    if (!widget.enabled) {
      return _pinTheme.inactiveColor;
    }
    if (((_selectedIndex == index) ||
        (_selectedIndex == index + 1 && index + 1 == widget.length)) &&
        _focusNode.hasFocus) {
      return _pinTheme.selectedColor;
    } else if (_selectedIndex > index) {
      return _pinTheme.activeColor;
    }
    return _pinTheme.inactiveColor;
  }

  Widget _renderPinField({
    required int index,
  }) {
    assert(index != null);

    bool showObscured = !widget.blinkWhenObscuring ||
        (widget.blinkWhenObscuring && _hasBlinked) ||
        index != _inputList.where((x) => x.isNotEmpty).length - 1;

    if (widget.obscuringWidget != null) {
      if (showObscured) {
        if (_inputList[index].isNotEmpty) {
          return widget.obscuringWidget!;
        }
      }
    }

    if (_inputList[index].isEmpty && _hintAvailable) {
      return Text(
        widget.hintCharacter??'',
        key: ValueKey(_inputList[index]),
        style: _hintStyle,
      );
    }

    return Text(
      widget.obscureText && _inputList[index].isNotEmpty && showObscured
          ? widget.obscuringCharacter
          : _inputList[index],
      key: ValueKey(_inputList[index]),
      style: _textStyle,
    );
  }

// selects the right fill color for the field
  Color _getFillColorFromIndex(int index) {
    if (!widget.enabled) {
      return _pinTheme.inactiveColor;
    }
    if (((_selectedIndex == index) ||
        (_selectedIndex == index + 1 && index + 1 == widget.length)) &&
        _focusNode.hasFocus) {
      return _pinTheme.selectedFillColor;
    } else if (_selectedIndex > index) {
      return _pinTheme.activeFillColor;
    }
    return _pinTheme.inactiveColor;
  }

  /// Builds the widget to be shown
  Widget buildChild(int index) {
    if (((_selectedIndex == index) ||
        (_selectedIndex == index + 1 && index + 1 == widget.length)) &&
        _focusNode.hasFocus &&
        widget.showCursor) {

      final cursorHeight = widget.cursorHeight ?? _textStyle.fontSize! + 8;

      if ((_selectedIndex == index + 1 && index + 1 == widget.length)) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(left: _textStyle.fontSize! / 1.5),
                child: FadeTransition(
                  opacity: _cursorAnimation,
                  child: CustomPaint(
                    size: Size(0, cursorHeight),
                  ),
                ),
              ),
            ),
            _renderPinField(
              index: index,
            ),
          ],
        );
      } else
        return Center(
          child: FadeTransition(
            opacity: _cursorAnimation,
            child: CustomPaint(
              size: Size(0, cursorHeight),
            ),
          ),
        );
    }
    return _renderPinField(
      index: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    var textField = TextFormField(
      textInputAction: widget.textInputAction,
      controller: _textEditingController,
      focusNode: _focusNode,
      enabled: widget.enabled,
      autofillHints: widget.enablePinAutofill && widget.enabled
          ? <String>[AutofillHints.oneTimeCode]
          : null,
      autofocus: widget.autoFocus,
      autocorrect: false,
      keyboardType: widget.keyboardType,
      keyboardAppearance: widget.keyboardAppearance,
      textCapitalization: widget.textCapitalization,
      validator: widget.validator,
      onSaved: widget.onSaved,
      autovalidateMode: widget.autovalidateMode,
      inputFormatters: [
        ...widget.inputFormatters,
        LengthLimitingTextInputFormatter(
          widget.length,
        ), // this limits the input length
      ],
      // trigger on the complete event handler from the keyboard
      onFieldSubmitted: widget.onSubmitted,
      enableInteractiveSelection: false,
      showCursor: false,
      // using same as background color so tha it can blend into the view
      cursorWidth: 0.01,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        fillColor: widget.backgroundColor,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      style: const TextStyle(
        color: Colors.transparent,
        height: .01,
        fontSize: 0.01, // it is a hidden textfield which should remain transparent and extremely small
      ),
    );

    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
        // adding the extra space at the bottom to show the error text from validator
        height: widget.pinTheme.fieldHeight + widget.errorTextSpace,
        color: widget.backgroundColor,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            AbsorbPointer(
              // this is a hidden textfield under the pin code fields.
              absorbing: true, // it prevents on tap on the text field
              child: widget.useExternalAutoFillGroup
                  ? textField
                  : AutofillGroup(
                onDisposeAction: widget.onAutoFillDisposeAction,
                child: textField,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  if (widget.onTap != null) widget.onTap!();
                  _onFocus();
                },
                onLongPress: widget.enabled
                    ? () async {
                  var data = await Clipboard.getData("text/plain");
                  if (data?.text?.isNotEmpty ?? false) {

                  }
                }
                    : null,
                child: Row(
                  mainAxisAlignment: widget.mainAxisAlignment,
                  children: _generateFields(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _generateFields() {
    var result = <Widget>[];
    for (int i = 0; i < widget.length; i++) {
      result.add(
        Container(
            padding: _pinTheme.fieldOuterPadding,
            child: AnimatedContainer(
              curve: widget.animationCurve,
              duration: widget.animationDuration,
              width: _pinTheme.fieldWidth,
              height: _pinTheme.fieldHeight,
              decoration: BoxDecoration(
                color: widget.enableActiveFill
                    ? _getFillColorFromIndex(i)
                    : Colors.transparent,
                boxShadow: widget.boxShadows,
                shape: BoxShape.rectangle,
                // borderRadius: borderRadius,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: _pinTheme.activeColor/*_getColorFromIndex(i)*/,
                  width: _pinTheme.borderWidth,
                ),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  switchInCurve: widget.animationCurve,
                  switchOutCurve: widget.animationCurve,
                  duration: widget.animationDuration,
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, .5),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: buildChild(i),
                ),
              ),
            )),
      );
    }
    return result;
  }

  void _onFocus() {
    if (_focusNode.hasFocus &&
        MediaQuery.of(widget.appContext).viewInsets.bottom == 0) {
      _focusNode.unfocus();
      Future.delayed(
          const Duration(microseconds: 1), () => _focusNode.requestFocus());
    } else {
      _focusNode.requestFocus();
    }
  }

  void _setTextToInput(String data) async {
    var replaceInputList = List<String>.filled(widget.length, "");

    for (int i = 0; i < widget.length; i++) {
      replaceInputList[i] = data.length > i ? data[i] : "";
    }

    if (mounted)
      setState(() {
        _selectedIndex = data.length;
        _inputList = replaceInputList;
      });
  }

}