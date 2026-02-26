import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/bean/blessing_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../tools/my_colors.dart';

class AddBlessingPage extends StatefulWidget {
  final String categoryId='';


  @override
  _AddBlessingPageState createState() => _AddBlessingPageState();
}

class _AddBlessingPageState extends State<AddBlessingPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveBlessing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final customBlessingsJson = prefs.getString('custom_blessings') ?? '{}';
      final customBlessings = Map<String, List<BlessingMessage>>.from(
        jsonDecode(customBlessingsJson).map(
          (key, value) => MapEntry(
            key,
            (value as List).map((e) => BlessingMessage.fromJson(e)).toList(),
          ),
        ),
      );

      final newBlessing = BlessingMessage(
        id: Uuid().v4(),
        categoryId: widget.categoryId,
        content: _contentController.text,
      );

      if (!customBlessings.containsKey(widget.categoryId)) {
        customBlessings[widget.categoryId] = [];
      }
      customBlessings[widget.categoryId]!.add(newBlessing);

      await prefs.setString(
        'custom_blessings',
        jsonEncode(customBlessings.map(
          (key, value) => MapEntry(
            key,
            value.map((e) => e.toJson()).toList(),
          ),
        )),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败：$e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color_main2,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        title:  Text("添加祝福语",style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: '祝福语内容',
                hintText: '请输入祝福语内容',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入祝福语内容';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveBlessing,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('保存'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 