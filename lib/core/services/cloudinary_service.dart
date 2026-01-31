import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {

  final String cloudName = "diqqlmass";
  final String uploadPreset = "erpsystem";

  Future<String> uploadFile(File file) async {

    final url =
    Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/upload");

    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

    final response = await request.send();

    final responseBody =
    await response.stream.bytesToString();

    final decoded = jsonDecode(responseBody);

    return decoded['secure_url'];
  }
}
