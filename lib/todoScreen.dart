import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models/todo.dart';
import 'taskScreen.dart';

class TodoList extends StatelessWidget {
    final List<Todo> todos;

    TodoList({
        this.todos
    });

    @override 
    Widget build(BuildContext buildContext) {
        return new ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
                return new GestureDetector(
                    child: new Container(
                        padding: const EdgeInsets.all(10.0),
                        color: index.isEven ? Colors.greenAccent : Colors.cyan,
                        child: new Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                new Text(
                                    todos[index].name,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0
                                    )
                                ),
                                new Text(
                                    'Date ${todos[index].dueDate}',
                                    style: new TextStyle(
                                        fontSize: 16.0
                                    )
                                )
                            ],
                        ),
                    ),
                    onTap: () {
                        final pageRouteTaskScreen = new MaterialPageRoute(
                            builder: (context) => new TaskScreen(todoId: todos[index].id)
                        );
                        Navigator.of(context).push(pageRouteTaskScreen);
                    },
                );
            },
        );
    }
}

class TodoScreen extends StatefulWidget {
    @override 
    State<StatefulWidget> createState() {
        return new TodoScreenState();
    }   
}

class TodoScreenState extends State<TodoScreen> {
    @override 
    Widget build(BuildContext buildContext) {
        return new Scaffold(
            appBar: new AppBar(
                title: new Text('TodoApp'),
            ),
            body: new FutureBuilder(
                future: fetchTodos(new http.Client()),
                builder: (context, snapshot) {
                    if (snapshot.hasError) {
                        print(snapshot.error);
                    }
                    return snapshot.hasData ? new TodoList(todos: snapshot.data) : new Center(
                        child: new CircularProgressIndicator(),
                    );
                },
            ),
        );
    }
}