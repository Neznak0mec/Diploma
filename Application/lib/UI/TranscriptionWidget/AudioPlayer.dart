import 'dart:async';
import 'dart:io';


// import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../SnackBars/FlashMessageError.dart';

class AudioPlayerPage extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerPage({super.key, required this.audioUrl});

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late AudioPlayer audioPlayer;
  Duration _duration = const Duration();
  Duration _position = const Duration();
  bool isPlaying = false;
  bool isLoading = false;
  String? localFilePath;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
      });
    });
    audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _position = position;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _debounce?.cancel();

    super.dispose();
  }

  Future<String> _downloadFile(String url, String filename) async {
    if (!mounted) return ''; // Check if the widget is still mounted

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File('${documentDirectory.path}/$filename');
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        isLoading = false;
      });

      return file.path;
    } catch (e) {
      //
      ScaffoldMessenger.of(context).showSnackBar(FlashMessageError("Ошибка при загрузке файла", context));
      setState(() {
        isLoading = false;
      });
      return '';
    }
  }

  Future<void> _play() async {
    localFilePath ??= await _downloadFile(widget.audioUrl, 'audio.mp3');

    await audioPlayer.play(DeviceFileSource(localFilePath!));
    setState(() {
      isPlaying = true;
    });
  }

  Future<void> _pause() async {
    await audioPlayer.pause();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> _stop() async {
    await audioPlayer.stop();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> _seekToSecond(int second) async {
    Duration newPosition = Duration(seconds: second);
    await audioPlayer.seek(newPosition);
  }

  void _onSliderChanged(double value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _seekToSecond(value.toInt());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: isPlaying ? null : _play,
                      ),
                      IconButton(
                        icon: const Icon(Icons.pause),
                        onPressed: isPlaying ? _pause : null,
                      ),
                      // IconButton(
                      //   icon: const Icon(Icons.stop),
                      //   onPressed: isPlaying ? _stop : null,
                      // ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}',
                      ),
                      Slider(
                        value: _position.inSeconds.toDouble(),
                        min: 0.0,
                        max: _duration.inSeconds.toDouble(),
                        onChanged: _onSliderChanged,
                      ),
                      Text(
                        '${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
