import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FORM",
      home: GetDataTodos(),
    );
  }
}

Future<List<Todo>> fetchTodos() async {
  final response = await http
      .get(Uri.parse('https://calm-plum-jaguar-tutu.cyclic.app/todos'));
  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body)['data'];
    List<Todo> todos = body.map((item) => Todo.fromJson(item)).toList();
    return todos;
  } else {
    throw Exception('Failed to load Todos');
  }
}

class Todo {
  final String todoName;
  final bool isComplete;

  Todo({required this.todoName, required this.isComplete});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      todoName: json['todoName'] ?? '',
      isComplete: json['isComplete'] ?? false,
    );
  }
}

class GetDataTodos extends StatelessWidget {
  final Future<List<Todo>> Todos = fetchTodos();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todos from API'),
      ),
      body: Center(
        child: FutureBuilder<List<Todo>>(
          future: Todos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TodoDetailPage(todo: snapshot.data![index]),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5, // Add elevation for the shadow
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.data![index].todoName,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 23,
                              ),
                            ),
                            Text(
                              'Is Complete: ${snapshot.data![index].isComplete}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class TodoDetailPage extends StatelessWidget {
  final Todo todo;

  TodoDetailPage({required this.todo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              todo.todoName,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 23,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Is Complete: ${todo.isComplete}',
            ),
          ),
        ],
      ),
    );
  }
}
