import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onError: (error) => print('Speech error: ${error.errorMsg}'),
      onStatus: (status) => print('Speech status: $status'),
    );
    return _isInitialized;
  }

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isInitialized;

  Future<void> startListening({
    required Function(String recognizedText, bool isFinal) onResult,
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      localeId: 'fa_IR',
      listenMode: stt.ListenMode.confirmation,
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(seconds: 30),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
  }

  Future<bool> isPersianAvailable() async {
    if (!_isInitialized) await initialize();
    final locales = await _speech.locales();
    return locales.any((l) => l.localeId.startsWith('fa'));
  }
}
