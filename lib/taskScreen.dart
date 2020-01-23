import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models/task.dart';
import 'detailTaskScreen.dart';

class TaskList extends StatelessWidget {
    final List<Task> tasks;

    TaskList({
        this.tasks
    });

    @override 
    Widget build(BuildContext buildContext) {
        return new ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
                return new GestureDetector(
                    child: new Container(
                        padding: const EdgeInsets.all(10.0),
                        child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                                new Text(
                                    tasks[index].name,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0
                                    ),
                                ),
                                new Text(
                                    'Finished: ${tasks[index].isFinished == true ? "Yes" : "No"}',
                                    style: new TextStyle(
                                        fontSize: 16.0
                                    ),
                                )
                            ],
                        ),
                    ),
                    onTap: () {
                        final pageRouteDetailTaskScreen = new MaterialPageRoute(
                            builder: (context) => new DetailTaskScreen(id: tasks[index].id)
                        );
                        Navigator.of(context).push(pageRouteDetailTaskScreen);
                    },
                );
            },
        );
    }
}

class TaskScreen extends StatefulWidget {
    final todoId;

    TaskScreen({
        this.todoId
    });

    @override 
    State<StatefulWidget> createState() {
        return new TaskScreenState();
    }
}

class TaskScreenState extends State<TaskScreen> {
    @override 
    Widget build(BuildContext buildContext) {
        return new Scaffold(
            appBar: new AppBar(
                title: new Text('List of Tasks'),
                actions: <Widget>[
                    new IconButton(
                        icon: new Icon(Icons.add),
                        onPressed: () {
                            print('Add Task');
                        },
                    )
                ],
            ),
            body: new FutureBuilder(
                future: fetchTask(new http.Client(), widget.todoId),
                builder: (context, snapshot) {
                    if (snapshot.hasError) {
                        print(snapshot.error);
                    } 
                    return snapshot.hasData ? new TaskList(tasks: snapshot.data) : new Center(
                        child: new CircularProgressIndicator(),
                    );
                },
            ),
        );
    }
}