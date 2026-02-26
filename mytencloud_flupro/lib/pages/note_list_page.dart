import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/models/note.dart';
import 'package:mytencloud_flupro/pages/note_edit_page.dart';
import 'package:mytencloud_flupro/stylesutil/SharedPreferenceUtil.dart';
import 'package:mytencloud_flupro/tools/my_colors.dart';
import 'dart:convert';
import 'dart:math';
import '../widget/empty_view.dart';

class NoteListPage extends StatefulWidget {
  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  List<Note> _notes = [];
  late DailyQuote _dailyQuote;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _loadDailyQuote();
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
        centerTitle: true,
        backgroundColor: MyColors.color_main2,
        title: const Text('随笔记录',
            style: TextStyle(color: Colors.black, fontSize: 20)),
      ),
      body: Column(
        children: [
          _buildDailyQuote(),
          Expanded(
            child: _notes.isEmpty
                ? Center(
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: EmptyView(title: '暂无记录，点击右下角添加')),
                  )
                : ListView.builder(
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return Container(
                        height: 80,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: note.getTypeColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Center(
                          child: ListTile(
                            leading: Icon(
                              note.getTypeIcon(),
                              color: Colors.black54,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  note.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    note.getTypeName(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  note.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${note.updatedAt.year}-${note.updatedAt.month}-${note.updatedAt.day}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteNote(note),
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoteEditPage(note: note),
                                ),
                              );
                              if (result == true) {
                                _loadNotes();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.color_main2,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditPage(),
            ),
          );
          if (result == true) {
            _loadNotes();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _loadDailyQuote() {
    final random = Random();
    _dailyQuote = DailyQuote.quotes[random.nextInt(DailyQuote.quotes.length)];
  }

  Future<void> _loadNotes() async {
    final String? notesJson = await SharedPreferenceUtil.getString('notes');
    if (notesJson != null) {
      final List<dynamic> decoded = json.decode(notesJson);
      setState(() {
        _notes = decoded.map((item) => Note.fromJson(item)).toList();
        _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      });
    }
  }

  Future<void> _saveNotes() async {
    final String encoded =
        json.encode(_notes.map((note) => note.toJson()).toList());
    await SharedPreferenceUtil.setString('notes', encoded);
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除这条随笔吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('删除'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _notes.removeWhere((n) => n.id == note.id);
      });
      await _saveNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已删除随笔')),
      );
    }
  }

  Widget _buildDailyQuote() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _dailyQuote.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _dailyQuote.type == 'thought'
                    ? Icons.psychology
                    : _dailyQuote.type == 'inspiration'
                        ? Icons.lightbulb
                        : _dailyQuote.type == 'reading'
                            ? Icons.book
                            : Icons.favorite,
                color: Colors.black54,
              ),
              SizedBox(width: 8),
              Text(
                _dailyQuote.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            _dailyQuote.content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
