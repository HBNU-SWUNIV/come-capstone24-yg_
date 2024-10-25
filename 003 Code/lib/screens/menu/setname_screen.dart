import 'package:flutter/material.dart';

class SetNameScreen extends StatefulWidget {
  @override
  _SetNameScreenState createState() => _SetNameScreenState();
}

class _SetNameScreenState extends State<SetNameScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName(BuildContext context) {
    // 이름을 저장하고 Navigator를 통해 SetNameScreen을 닫습니다.
    String newName = _nameController.text;
    Navigator.pop(context, newName);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이름 설정'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '닉네임',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _saveName(context),
              child: Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}