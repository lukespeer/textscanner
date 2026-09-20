import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

Future<RecognizedText> scanText(InputImage inputImage) async {
  final RecognizedText recognizedText = await recognizer.processImage(inputImage);
  
  return recognizedText;
}