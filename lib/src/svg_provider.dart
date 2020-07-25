import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgImage extends AssetBundleImageProvider {
  const SvgImage(
    this.assetName, {
    this.scale = 1.0,
    this.bundle,
    this.package,
  })  : assert(assetName != null),
        assert(scale != null);

  final String assetName;
  String get keyName =>
      package == null ? assetName : 'packages/$package/$assetName';
  final double scale;
  final AssetBundle bundle;
  final String package;

  @override
  Future<AssetBundleImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AssetBundleImageKey>(AssetBundleImageKey(
      bundle: bundle ?? configuration.bundle ?? rootBundle,
      name: keyName,
      scale: scale,
    ));
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is SvgImage &&
        other.keyName == keyName &&
        other.scale == scale &&
        other.bundle == bundle;
  }

  @override
  int get hashCode => hashValues(keyName, scale, bundle);

  @override
  ImageStreamCompleter load(AssetBundleImageKey key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
    );
  }

  Future<Codec> _loadAsync(
      AssetBundleImageKey key, DecoderCallback decode) async {
    Size size = Size(256, 256);

    final Uint8List bytes = await key.bundle
        .loadString(key.name)
        .then((String rawSvg) => svg.fromSvgString(rawSvg, rawSvg))
        .then((DrawableRoot svg) {
          final ratio = svg.viewport.viewBox.aspectRatio;
          size = (ratio > 1)
              ? Size(size.width, size.width / ratio)
              : Size(size.height * ratio, size.height);
          return svg.toPicture(size: size, clipToViewBox: false);
        })
        .then((Picture picture) {
          return picture.toImage(size.width.toInt(), size.height.toInt());
        })
        .then((image) => image.toByteData(format: ImageByteFormat.png))
        .then((ByteData byteData) => byteData.buffer.asUint8List());

    return decode(
      bytes,
      cacheHeight: size.height.toInt(),
      cacheWidth: size.width.toInt(),
    );
  }
}
