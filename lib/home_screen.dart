import 'package:flutter/material.dart';

import './widgets/file_upload/service/filepond_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FilepondFlutter(
            serverUrl: 'https://lakbatik.com/api/file',
            processOptions: {
              'url': '/process',
              'headers': {
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization':
                    'Bearer 44|6Qo3unxP2eMMelLwQ6fN9FF6ayLReUrYo85dxcca',
              }
            },
            revertOptions: {
              'url': '/revert',
              'headers': {
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization':
                    'Bearer 44|6Qo3unxP2eMMelLwQ6fN9FF6ayLReUrYo85dxcca',
              }
            },
            allowMultiple: true,
          )
        ],
      ),
    );
  }
}
