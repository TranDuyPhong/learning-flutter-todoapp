import 'package:http/http.dart' as http;
import 'dart:convert';

import '../global.dart';

class Task {
    int id;
    String name;
    int todoId;
    bool isFinished;

    Task({
        this.id,
        this.name,
        this.todoId,
        this.isFinished
    });

    factory Task.fromJson(Map<String, dynamic> json) {
        return Task(
            id: json['id'],
            name: json['name'],
            todoId: json['todo_id'],
            isFinished: json['isFinished']
        );
    }

    factory Task.fromTask(Task anotherTask) {
        return Task(
            id: anotherTask.id,
            name: anotherTask.name,
            todoId: anotherTask.todoId,
            isFinished: anotherTask.isFinished
        );
    }
}

Future<List<Task>> fetchTask(http.Client client, int todoId) async {
    final response = await client.get('$URL_TASKS_BY_TODOID$todoId');
    if (response.statusCode == 200) {
        Map<String, dynamic> mapResponse = json.decode(response.body);
        if (mapResponse['result'] == 'ok') {
            final taskJsons = mapResponse['data'].cast<Map<String, dynamic>>();
            return await taskJsons.map<Task>((taskJson) {
                return Task.fromJson(taskJson);
            }).toList();
        } else {
            return [];
        }
    } else {
        throw new Exception('Failed to load Task from the Internet');
    }
}

Future<Task> fetchTaskById(http.Client client, int id) async {
    final response = await client.get('$URL_TASKS/$id');
    if (response.statusCode == 200) {
        Map<String, dynamic> mapResponse = json.decode(response.body);
        if (mapResponse['result'] == 'ok') {
            final taskJson = mapResponse['data'];
            return Task.fromJson(taskJson);
        } else {
            return new Task();
        }
    } else {
        throw new Exception('Failed to load Task from the Internet');
    }
}

Future<Task> updateTask(http.Client client, Map<String, dynamic> params) async {
    final response = await client.put('$URL_TASKS/${params["id"]}', body: params);
    if (response.statusCode == 200) {
        final taskJson = await json.decode(response.body);
        return Task.fromJson(taskJson);
    } else {
        throw new Exception('Failed to update Task from the Internet');
    }
}

Future<Task> deleteTask(http.Client client, int id) async {
    final response = await client.delete('$URL_TASKS/$id');
    if (response.statusCode == 200) {
        final taskJson = await json.decode(response.body);
        return Task.fromJson(taskJson);
    } else {
        throw new Exception('Failed to delete Task from the Internet');
    }
}