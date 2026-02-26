import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/models/note.dart';
import 'package:mytencloud_flupro/stylesutil/SharedPreferenceUtil.dart';
import 'package:mytencloud_flupro/tools/my_colors.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class NoteEditPage extends StatefulWidget {
  late Note? note;

  NoteEditPage({this.note});

  @override
  _NoteEditPageState createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedType = 'thought';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedType = widget.note!.type;
      _isEditing = true;
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入标题')),
      );
      return;
    }

    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入内容')),
      );
      return;
    }

    final String? notesJson = await SharedPreferenceUtil.getString('notes');
    List<Note> notes = [];
    
    if (notesJson != null) {
      final List<dynamic> decoded = json.decode(notesJson);
      notes = decoded.map((item) => Note.fromJson(item)).toList();
    }

    final now = DateTime.now();
    final note = Note(
      id: _isEditing ? widget.note!.id : const Uuid().v4(),
      title: _titleController.text,
      content: _contentController.text,
      type: _selectedType,
      createdAt: _isEditing ? widget.note!.createdAt : now,
      updatedAt: now,
    );

    if (_isEditing) {
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        notes[index] = note;
      }
    } else {
      notes.add(note);
    }

    await SharedPreferenceUtil.setString('notes', json.encode(notes.map((n) => n.toJson()).toList()));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color_main2,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        backgroundColor: MyColors.color_main2,
        centerTitle:  true,
        title: Text(_isEditing ? '编辑随笔' : '新建随笔',style: const TextStyle(color: Colors.black, fontSize: 20),),
        actions: [
          IconButton(
            icon: const Icon(Icons.save,color: Colors.black,),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '灵感',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: 'thought',
                      child: Row(
                        children: const [
                          Icon(Icons.psychology, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('思考'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'inspiration',
                      child: Row(
                        children: const [
                          Icon(Icons.lightbulb, color: Colors.green),
                          SizedBox(width: 8),
                          Text('灵感'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'reading',
                      child: Row(
                        children: const [
                          SizedBox(width: 8),
                          Icon(Icons.book, color: Colors.orange),
                          Text('读书'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'life',
                      child: Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.purple),
                          SizedBox(width: 8),
                          Text('生活'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '内容',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              style: const TextStyle(fontSize: 20),
              maxLines: null,
              minLines: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
} 