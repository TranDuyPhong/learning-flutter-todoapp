import 'dart:convert';
import 'package:http/http.dart' as http;

import '../global.dart';

class Todo {
    int id;
    String name;
    String description;
    String dueDate;
    int priority;

    Todo({
        this.id,
        this.name,
        this.description,
        this.dueDate,
        this.priority
    });

    factory Todo.fromJson(Map<String, dynamic> json) {
        return Todo(
            id: json['id'],
            name: json['name'],
            description: json['description'],
            dueDate: json['dueDate'],
            priority: json['priority']
        );
    }
}

Future<List<Todo>> fetchTodos(http.Client client) async {
    final response = await client.get(URL_TODOS);
    if (response.statusCode == 200) {
        Map<String, dynamic> mapResponse = json.decode(response.body);
        if (mapResponse['result'] == 'ok') {
            final todoJsons = mapResponse['data'].cast<Map<String, dynamic>>();
            return await todoJsons.map<Todo>((todoJson) {
                return Todo.fromJson(todoJson);
            }).toList();
        } else {
            return [];
        }
    } else {
        throw new Exception('Failed to load Todo from the Internet');
    }
}   