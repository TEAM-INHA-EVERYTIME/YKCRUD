import 'package:flutter/material.dart';
import 'package:crud/database/db.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _todoList = [];
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshTodoList();
  }

  void _refreshTodoList() async {
    final data = await _dbHelper.getTodos();
    setState(() {
      _todoList = data;
    });
  }

  void _addTodo() async {
    await _dbHelper.insertTodo({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'isDone': 0,
    });
    _titleController.clear();
    _descriptionController.clear();
    _refreshTodoList();
  }

  void _deleteTodoConfirmation(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Confirmation'),
        content: Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // 다이얼로그 닫기
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteTodo(id);
              Navigator.of(ctx).pop(); // 다이얼로그 닫기
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteTodo(int id) async {
    await _dbHelper.deleteTodo(id);
    _refreshTodoList();
  }

  void _toggleTodoCompletion(Map<String, dynamic> todo) async {
    todo['isDone'] = todo['isDone'] == 1 ? 0 : 1;
    await _dbHelper.updateTodo(todo);
    _refreshTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: Text('Add To-Do'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                final todo = _todoList[index];
                return ListTile(
                  title: Text(todo['title']),
                  subtitle: Text(todo['description']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      _deleteTodoConfirmation(todo['id']);
                    },
                  ),
                  onTap: () {
                    _toggleTodoCompletion(todo);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
