import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:image_picker/image_picker.dart';

Future<http.Client> obtainCredentials() async {
  // final serviceAcountJson = await _loadServiceAccountJson();
  final serviceAccountJson =
      await rootBundle.loadString('assets/service_account.json');

  final account = ServiceAccountCredentials.fromJson(serviceAccountJson);
  final scopes = ['https://www.googleapis.com/auth/drive.file'];

  final client = await clientViaServiceAccount(account, scopes);
  return client;
}

Future<String?> uploadImageToGoogleDrive(XFile image) async {
  try {
    final client = await obtainCredentials();
    final driveApi = drive.DriveApi(client);

    File file = File(image.path);

    final driveFile = drive.File(name: image.name, mimeType: image.mimeType);

    final media = drive.Media(file.openRead(), file.lengthSync());

    final uploadedFile = await driveApi.files.create(
      driveFile,
      uploadMedia: media,
    );

    await driveApi.permissions.create(
      drive.Permission()
        ..type = 'anyone'
        ..role = 'reader',
      uploadedFile.id!,
    );

    final fileId = uploadedFile.id;
    final fileLink = 'https://drive.google.com/uc?id=$fileId';

    client.close();
    return fileLink;
  } catch (e) {
    print('Error uploading file: $e');
    return null;
  }
}
