import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {

  final cloudName = "diqqlmass";
  final uploadPreset = "erpsystem";

  Future<String> uploadFile(File file) async {

    final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/upload");

    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath(
          'file', file.path));

    final response = await request.send();
    final res = await response.stream.bytesToString();

    return jsonDecode(res)['secure_url'];
  }
}
