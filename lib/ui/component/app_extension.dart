import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rate_review/helper/method_channel_handler.dart';
import 'dart:math' as math;

extension DateTimeExtensions on DateTime {


  String get formatDate => DateFormat.yMMMd().format(this);

}

extension StringExtensions on String {
  String get inCaps =>
      '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  String get allInCaps => toUpperCase();

  String get allInSmall => toLowerCase();

  String get capitalizeFirstofEach =>
      split(" ").map((str) => str.inCaps).join(" ");

  String get letsStartWithHTTP =>
      startsWith('http') ? this : 'http://' + this;

  String get nullAware => this == null ? '' : this;

  String get trim => this.trim();

  String get decimalValue => double.parse(this).toStringAsFixed(2);

  String get firstChar => this[0];

  bool get isTrue => toLowerCase() == (true.toString().toLowerCase());

  bool get isFalse => toLowerCase() == (false.toString().toLowerCase());

  bool get isStartWithHTTP => (startsWith('http://') || startsWith('https://'));

  DateTime get toDate => DateTime.fromMillisecondsSinceEpoch(int.parse(this));

  String formatBytes(int decimals) {
    int bytes = int.parse(this);
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  Future<String> get getEncrptedString async {
    MethodChannelHandler methodChannelHandler = MethodChannelHandler();
    String key = await methodChannelHandler.getEncryptionKey();
    String secretStr = await methodChannelHandler.getSecretKey();
    List<int> plaintext  = utf8.encode("${this}$key");
    List<int> iv = AesGcm.with128bits().newNonce();
    List<int> passphrase = utf8.encode(secretStr);
    SecretKey secretKey = SecretKey(passphrase);

    SecretBox secretBox = await AesGcm.with128bits().encrypt(plaintext, nonce: iv, secretKey: secretKey);
    String ivCiphertextMacB64 = base64.encode(secretBox.concatenation()); // Base64 encoding of: IV | ciphertext | MAC
    dev.log('encrypted- $ivCiphertextMacB64');
    return ivCiphertextMacB64;
  }

 /* Future<String> decode() async {
    return await (Get.find() as MethodChannelHandler).decode(this);
  }

  Future<String> encode() async {
    return await (Get.find() as MethodChannelHandler).encode(this);
  }*/

  String capitalize() {
    var t = "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    return t;
  }

  int get toInt => int.parse(this);
}


class CircularNotched extends NotchedShape {
  /// Creates a [CircularNotched].
  ///
  /// The same object can be used to create multiple shapes.
  const CircularNotched();

  /// Creates a [Path] that describes a rectangle with a smooth circular notch.
  ///
  /// `host` is the bounding box for the returned shape. Conceptually this is
  /// the rectangle to which the notch will be applied.
  ///
  /// `guest` is the bounding box of a circle that the notch accommodates. All
  /// points in the circle bounded by `guest` will be outside of the returned
  /// path.
  ///
  /// The notch is curve that smoothly connects the host's top edge and
  /// the guest circle.
  // TODO(amirh): add an example diagram here.
  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    // The guest's shape is a circle bounded by the guest rectangle.
    // So the guest's radius is half the guest width.
    final double notchRadius = guest.width / 2.0;

    // We build a path for the notch from 3 segments:
    // Segment A - a Bezier curve from the host's top edge to segment B.
    // Segment B - an arc with radius notchRadius.
    // Segment C - a Bezier curve from segment B back to the host's top edge.
    //
    // A detailed explanation and the derivation of the formulas below is
    // available at: https://goo.gl/Ufzrqn

    const double s1 = 15.0;
    const double s2 = 40.0;

    final double r = notchRadius;
    final double a = -1.0 * r - s2;
    final double b = host.top - guest.center.dy;

    final double n2 = math.sqrt(b * b * r * r * (a * a + b * b - r * r));
    final double p2xA = ((a * r * r) - n2) / (a * a + b * b);
    final double p2xB = ((a * r * r) + n2) / (a * a + b * b);
    final double p2yA = math.sqrt(r * r - p2xA * p2xA);
    final double p2yB = math.sqrt(r * r - p2xB * p2xB);

    final List<Offset?> p = List<Offset?>.filled(6, null);

    // p0, p1, and p2 are the control points for segment A.
    p[0] = Offset(a - s1, b);
    p[1] = Offset(a - s1, b);
    final double cmp = b < 0 ? -1.0 : 1.0;
    p[2] = cmp * p2yA > cmp * p2yB ? Offset(p2xA, p2yA) : Offset(p2xB, p2yB);

    // p3, p4, and p5 are the control points for segment B, which is a mirror
    // of segment A around the y axis.
    p[3] = Offset(-1.0 * p[2]!.dx, p[2]!.dy);
    p[4] = Offset(-1.0 * p[1]!.dx, p[1]!.dy);
    p[5] = Offset(-1.0 * p[0]!.dx, p[0]!.dy);

    // translate all points back to the absolute coordinate system.
    for (int i = 0; i < p.length; i += 1) {
      p[i] = p[i]! + guest.center;
    }

    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(p[0]!.dx, p[0]!.dy)
      ..quadraticBezierTo(p[1]!.dx, p[1]!.dy, p[2]!.dx, p[2]!.dy)
      ..arcToPoint(
        p[3]!,
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )
      ..quadraticBezierTo(p[3]!.dx, p[2]!.dy, p[4]!.dx, p[4]!.dy)
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}


/*
extension NS on NotchedShape {
  class CircularNotched extends NotchedShape {
  /// Creates a [CircularNotched].
  ///
  /// The same object can be used to create multiple shapes.
  const CircularNotched();

  /// Creates a [Path] that describes a rectangle with a smooth circular notch.
  ///
  /// `host` is the bounding box for the returned shape. Conceptually this is
  /// the rectangle to which the notch will be applied.
  ///
  /// `guest` is the bounding box of a circle that the notch accommodates. All
  /// points in the circle bounded by `guest` will be outside of the returned
  /// path.
  ///
  /// The notch is curve that smoothly connects the host's top edge and
  /// the guest circle.
  // TODO(amirh): add an example diagram here.
  @override
  Path getOuterPath(Rect host, Rect? guest) {
  if (guest == null || !host.overlaps(guest))
  return Path()..addRect(host);

  // The guest's shape is a circle bounded by the guest rectangle.
  // So the guest's radius is half the guest width.
  final double notchRadius = guest.width / 2.0;

  // We build a path for the notch from 3 segments:
  // Segment A - a Bezier curve from the host's top edge to segment B.
  // Segment B - an arc with radius notchRadius.
  // Segment C - a Bezier curve from segment B back to the host's top edge.
  //
  // A detailed explanation and the derivation of the formulas below is
  // available at: https://goo.gl/Ufzrqn

  const double s1 = 15.0;
  const double s2 = 1.0;

  final double r = notchRadius;
  final double a = -1.0 * r - s2;
  final double b = host.top - guest.center.dy;

  final double n2 = math.sqrt(b * b * r * r * (a * a + b * b - r * r));
  final double p2xA = ((a * r * r) - n2) / (a * a + b * b);
  final double p2xB = ((a * r * r) + n2) / (a * a + b * b);
  final double p2yA = math.sqrt(r * r - p2xA * p2xA);
  final double p2yB = math.sqrt(r * r - p2xB * p2xB);

  final List<Offset?> p = List<Offset?>.filled(6, null);

  // p0, p1, and p2 are the control points for segment A.
  p[0] = Offset(a - s1, b);
  p[1] = Offset(a, b);
  final double cmp = b < 0 ? -1.0 : 1.0;
  p[2] = cmp * p2yA > cmp * p2yB ? Offset(p2xA, p2yA) : Offset(p2xB, p2yB);

  // p3, p4, and p5 are the control points for segment B, which is a mirror
  // of segment A around the y axis.
  p[3] = Offset(-1.0 * p[2]!.dx, p[2]!.dy);
  p[4] = Offset(-1.0 * p[1]!.dx, p[1]!.dy);
  p[5] = Offset(-1.0 * p[0]!.dx, p[0]!.dy);

  // translate all points back to the absolute coordinate system.
  for (int i = 0; i < p.length; i += 1)
  p[i] = p[i]! + guest.center;

  return Path()
  ..moveTo(host.left, host.top)
  ..lineTo(p[0]!.dx, p[0]!.dy)
  ..quadraticBezierTo(p[1]!.dx, p[1]!.dy, p[2]!.dx, p[2]!.dy)
  ..arcToPoint(
  p[3]!,
  radius: Radius.circular(notchRadius),
  clockwise: false,
  )
  ..quadraticBezierTo(p[4]!.dx, p[4]!.dy, p[5]!.dx, p[5]!.dy)
  ..lineTo(host.right, host.top)
  ..lineTo(host.right, host.bottom)
  ..lineTo(host.left, host.bottom)
  ..close();
  }
  }
}*/
