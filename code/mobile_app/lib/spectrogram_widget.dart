import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class SpectrogramWidget extends StatelessWidget {
  final List<Float64List>? spectrogram;
  final Uint8List? audioBytes;
  final String? localAudioPath;
  final double contrastFactor;
  final double brightnessFactor;
  final String colormap;

  const SpectrogramWidget({
    Key? key,
    required this.spectrogram,
    required this.audioBytes,
    required this.localAudioPath,
    required this.contrastFactor,
    required this.brightnessFactor,
    required this.colormap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (spectrogram!.isEmpty || spectrogram!.length < 2) {
      return const Text('Spectrogram data is incomplete');
    }

    final image = _generateSpectrogramImage(spectrogram!, colormap: colormap);
    final png = img.encodePng(image);
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () async {
        AudioPlayer player = AudioPlayer();

        if (Platform.isIOS) {
          await player.play(DeviceFileSource(localAudioPath!));
        }
        if (Platform.isAndroid) {
          await player.play(BytesSource(audioBytes!));
        }
        ;
      },
      child: Container(
        width: width,
        height: double.infinity,
        child: Image.memory(Uint8List.fromList(png), fit: BoxFit.fill),
      ),
    );
  }

  img.Image _generateSpectrogramImage(List<Float64List> spectrogramData,
      {String colormap = 'grayscale'}) {
    final int width = spectrogramData.length;
    final int height = spectrogramData[0].length;
    final image = img.Image(width: width, height: height);

    double maxVal = spectrogramData.fold(
        0, (double prevMax, list) => max(prevMax, list.reduce(max)));

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        double normalizedValue = spectrogramData[x][y] / maxVal;
        img.Color color = _getColorFromValue(normalizedValue, colormap);

        // Manually extract RGB values
        int r = color.r.toInt();
        int g = color.g.toInt();
        int b = color.b.toInt();

        // Apply contrast and brightness adjustments
        List<int> adjustedColors = [r, g, b].map((c) {
          double contrastAdjusted =
              pow((c.toDouble() / 255.0), contrastFactor.toDouble()).toDouble();
          return ((contrastAdjusted * brightnessFactor) * 255)
              .clamp(0, 255)
              .round();
        }).toList();

        // Reassemble the color
        color.setRgb(adjustedColors[0], adjustedColors[1], adjustedColors[2]);
        image.setPixel(x, height - y - 1, color);
      }
    }
    return image;
  }

  img.Color _getColorFromValue(double value, String colormap) {
    if (colormap == 'jet') {
      return mapValueToJetColor(value);
    } else {
      // Default to grayscale if no matching colormap found
      int pixelValue = (value * 255).round();
      return img.ColorRgb8(pixelValue, pixelValue, pixelValue);
    }
  }

// Function to map a value (0 to 1) to a color using the "jet" colormap
  img.Color mapValueToJetColor(double value) {
    //, double blueThreshold,
    // double redThreshold, double greenThresh//old) {
    // we will replace the static implementation here to a dynamic one in which
    // the thresholds are calculated based on the value of the spectrogram
    // data
    // then 0.35 will be replaced by the greenThreshold
    // 0.66 will be replaced by the redThreshold
    // and the rest will be calculated based on these thresholds
    int r, g, b;
    const int n = 255;
    if (value <= 0) {
      r = g = b = 0;
    } else if (value < 0.35) {
      r = 0;
      g = (value / 0.35 * n).round();
      b = n;
    } else if (value < 0.66) {
      r = ((value - 0.35) / (0.66 - 0.35) * n).round();
      g = n;
      b = n - ((value - 0.35) / (0.66 - 0.35) * n).round();
    } else if (value <= 1) {
      r = n;
      g = n - ((value - 0.66) / (1 - 0.66) * n).round();
      b = 0;
    } else {
      r = g = b = n;
    }
    return img.ColorRgb8(r, g, b);
  }
}
