import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PinTheme {
  /// Colors of the input fields which have inputs. Default is [Colors.green]
  final Color activeColor;

  /// Color of the input field which is currently selected. Default is [Colors.blue]
  final Color selectedColor;

  /// Colors of the input fields which don't have inputs. Default is [Colors.red]
  final Color inactiveColor;

  /// Colors of the input fields which have inputs. Default is [Colors.green]
  final Color activeFillColor;

  /// Color of the input field which is currently selected. Default is [Colors.blue]
  final Color selectedFillColor;

  /// Border radius of each pin code field
  final BorderRadius borderRadius;

  /// [height] for the pin code field. default is [50.0]
  final double fieldHeight;

  /// [width] for the pin code field. default is [40.0]
  final double fieldWidth;

  /// Border width for the each input fields. Default is [2.0]
  final double borderWidth;

  /// this defines the shape of the input fields. Default is underlined
  final OTPFieldShape shape;

  /// this defines the padding of each enclosing container of an input field. Default is [0.0]
  final EdgeInsetsGeometry fieldOuterPadding;

  const PinTheme.defaults({
    this.borderRadius = BorderRadius.zero,
    this.fieldHeight = 50,
    this.fieldWidth = 40,
    this.borderWidth = 2,
    this.fieldOuterPadding = EdgeInsets.zero,
    this.shape = OTPFieldShape.box,
    this.activeColor = Colors.green,
    this.selectedColor = Colors.white,
    this.inactiveColor = Colors.white,
    this.activeFillColor = Colors.green,
    this.selectedFillColor = Colors.white,
  });

  factory PinTheme(
      {
        Color? activeColor,
        Color? selectedColor,
        Color? inactiveColor,
        Color? activeFillColor,
        Color? selectedFillColor,
        BorderRadius? borderRadius,
        double? fieldHeight,
        double? fieldWidth,
        double? borderWidth,
        OTPFieldShape? shape,
        EdgeInsetsGeometry? fieldOuterPadding}) {
    const defaultValues = PinTheme.defaults();
    return PinTheme.defaults(
      activeColor: activeColor ?? defaultValues.activeColor,
      activeFillColor: activeFillColor ?? defaultValues.activeFillColor,
      borderRadius: borderRadius ?? defaultValues.borderRadius,
      borderWidth: borderWidth ?? defaultValues.borderWidth,
      fieldHeight: fieldHeight ?? defaultValues.fieldHeight,
      fieldWidth: fieldWidth ?? defaultValues.fieldWidth,
      inactiveColor: inactiveColor ?? defaultValues.inactiveColor,
      selectedColor: selectedColor ?? defaultValues.selectedColor,
      selectedFillColor: selectedFillColor ?? defaultValues.selectedFillColor,
      shape: shape ?? defaultValues.shape,
      fieldOuterPadding: fieldOuterPadding ?? defaultValues.fieldOuterPadding,
    );
  }
}

enum OTPFieldShape { box, underline, circle }