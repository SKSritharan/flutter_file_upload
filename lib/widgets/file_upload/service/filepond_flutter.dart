import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class FilepondFlutter extends StatefulWidget {
  final String serverUrl;
  final Map<String, dynamic> processOptions;
  final Map<String, dynamic> revertOptions;
  final bool allowMultiple;

  const FilepondFlutter({
    super.key,
    required this.serverUrl,
    required this.processOptions,
    required this.revertOptions,
    this.allowMultiple = false,
  });

  @override
  State<FilepondFlutter> createState() => _FilepondFlutterState();
}

class _FilepondFlutterState extends State<FilepondFlutter> {
  List<String> uploadedFiles = [];
  bool isLoading = false;

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: widget.allowMultiple,
    );

    setState(() {
      isLoading = true;
    });

    if (result != null) {
      for (var file in result.files) {
        String fileName = file.name;
        String filePath = file.path!;

        try {
          File fileToUpload = File(filePath);
          List<int> fileBytes = await fileToUpload.readAsBytes();

          // Create a new http.MultipartRequest
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('${widget.serverUrl}${widget.processOptions['url']}'),
          );

          // Add headers to the request if provided
          if (widget.processOptions['headers'] != null) {
            var headers = widget.processOptions['headers'];
            headers.forEach((key, val) {
              request.headers[key] = val;
            });
          }

          // Create the http.MultipartFile with fileBytes
          var fileUpload = http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: fileName,
          );

          // Add the MultipartFile to the request
          request.files.add(fileUpload);

          // Send the request
          var response = await request.send();

          if (response.statusCode == 200) {
            String fileId = await response.stream.bytesToString();
            setState(() {
              uploadedFiles.add(fileId);
            });
            print('File uploaded successfully: $fileId');
          } else {
            print('Error uploading $fileName: ${response.statusCode}');
          }
        } catch (e) {
          print('Error reading the file: $e');
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _revertFile(String fileId) async {
    try {
      var headers = {};
      // Add headers to the request if provided
      if (widget.revertOptions['headers'] != null) {
        headers = widget.revertOptions['headers'];
      }

      // Send the request
      var response = await http.delete(
        Uri.parse('${widget.serverUrl}${widget.revertOptions['url']}'),
        headers: headers as Map<String, String>,
        body: fileId,
      );

      if (response.statusCode == 200) {
        setState(() {
          uploadedFiles.remove(fileId);
        });
        print('File deleted successfully');
      } else {
        print(
            'Error while deleting file : ${response.statusCode}, FileId: $fileId');
      }
    } catch (e) {
      print('Error while deleting file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 5.0, color: Colors.black12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          TextButton(
            onPressed: _uploadFile,
            child: const Text('Select and Upload File'),
          ),
          const SizedBox(height: 16),
          if (isLoading) CircularProgressIndicator(),
          if (uploadedFiles.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              itemCount: 1,
              itemBuilder: (context, index) {
                String fileId = uploadedFiles[index];
                return ListTile(
                  title: Text(fileId),
                  trailing: ElevatedButton.icon(
                    onPressed: () {
                      _revertFile(fileId);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Revert'),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
