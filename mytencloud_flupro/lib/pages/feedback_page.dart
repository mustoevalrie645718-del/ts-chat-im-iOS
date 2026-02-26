import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:mytencloud_flupro/tools/my_colors.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  late File _image;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _reasonController = TextEditingController();
  final _suggestionController = TextEditingController();
  String _selectedType = '工具';

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('反馈已提交')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.color_main2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        title: Text(
          "提交反馈",
          style: const TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: MyColors.color_main2,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 100,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                //const Text('如果您有想使用的功能，欢迎随时告诉我们，我们会认真考虑并不断优化产品体验。',
                child: Text.rich(TextSpan(children: [
                  WidgetSpan(
                    child: Image.asset(
                      'assets/images/applogo.jpg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  const TextSpan(
                    text: ' 非常欢迎您的使用：\n',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text: '如果您有想使用的功能，欢迎随时告诉我们。\n',
                    style: TextStyle(fontSize: 12),
                  ),
                  TextSpan(
                      text: '我们会认真考虑并不断优化产品体验\n',
                      style: TextStyle(fontSize: 12))
                ])),
              ),
              // 图片选择
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_image, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:  [
                            Icon(Icons.add_photo_alternate,
                                size: 50, color: Colors.blueAccent[100]),
                            SizedBox(height: 8),
                            Text('点击选择图片',
                                style: TextStyle(color: Colors.blueAccent[50])),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 16),

              // 标题
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: '标题',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入标题';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // 内容
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: '内容',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入内容';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // 类型选择
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: '类型',
                  border: OutlineInputBorder(),
                ),
                items: ['工具', '服务', '其他'].map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),

              // 需求原因
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: '为什么需要这个功能',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请说明需求原因';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // 建议
              TextFormField(
                controller: _suggestionController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: '对我们的建议',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入您的建议';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.color_main3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _submitFeedback,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('提交反馈', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _reasonController.dispose();
    _suggestionController.dispose();
    super.dispose();
  }
}
