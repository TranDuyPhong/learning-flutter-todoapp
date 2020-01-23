import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models/task.dart';

class DetailTask extends StatefulWidget {
    final Task task;

    DetailTask({
        this.task
    });

    @override 
    State<StatefulWidget> createState() {
        return new DetailTaskState();
    }
}

class DetailTaskState extends State<DetailTask> {
    Task task = new Task();
    bool isLoadedTask = false;

    @override 
    Widget build(BuildContext buildContext) {
        if (isLoadedTask == false) {
            setState(() {
                this.isLoadedTask = true;
                this.task = Task.fromTask(widget.task);
            });
        }
        final TextField _txtTaskName = new TextField(
            decoration: new InputDecoration(
                hintText: 'Enter task name',
                contentPadding: const EdgeInsets.all(10.0),
                border: new OutlineInputBorder(borderSide: new BorderSide(
                    color: Colors.black
                )),
            ),
            autocorrect: false,
            controller: new TextEditingController(
                text: this.task.name
            ),
            textAlign: TextAlign.left,
            onChanged: (text) {
                setState(() {
                    this.task.name = text;
                });
            },
        );
        final Text _txtFinised = new Text('Finished:', style: new TextStyle(fontSize: 16.0));
        final Checkbox _cbFinished = new Checkbox(
            value: this.task.isFinished,
            onChanged: (bool value) {
                setState(() {
                    this.task.isFinished = value;
                });
            },
        );
        final _btnSave = new RaisedButton(
            child: new Text(
                'Save',
                style: new TextStyle(
                    color: Colors.white
                ),
            ),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            onPressed: () async {
                Map<String, dynamic> params = new Map<String, dynamic>();
                params['id'] = this.task.id.toString();
                params['name'] = this.task.name;
                params['isFinished'] = this.task.isFinished.toString();
                params['todo_id'] = this.task.todoId.toString();
                await updateTask(new http.Client(), params);
                Navigator.pop(context);
            },
        );
        final _btnDelete = new RaisedButton(
            child: new Text(
                'Delete',
                style: new TextStyle(
                    color: Colors.white
                ),
            ),
            color: Colors.redAccent,
            elevation: 4.0,
            onPressed: () {
                showDialog(
                    context: buildContext,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                        return new AlertDialog(
                            title: new Text('Confirmation'),
                            content: new SingleChildScrollView(
                                child: new ListBody(
                                    children: <Widget>[
                                        new Text('Are you sure you want to delete this ?')
                                    ],
                                ),
                            ),
                            actions: <Widget>[
                                new FlatButton(
                                    child: new Text('Yes'),
                                    onPressed: () async {
                                        await deleteTask(new http.Client(), this.task.id);
                                        await Navigator.pop(context);
                                        Navigator.pop(context);
                                    },
                                ),
                                new FlatButton(
                                    child: new Text('No'),
                                    onPressed: () {
                                        Navigator.pop(context);
                                    },
                                )
                            ],
                        );
                    }
                );
            },
        );
        final _column = new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
                _txtTaskName,
                new Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: new Row(
                        children: <Widget>[
                            _txtFinised,
                            _cbFinished
                        ],
                    ),
                ),
                new Row(
                    children: <Widget>[
                        new Expanded(
                            child: _btnSave,
                        ),
                        new Expanded(
                            child: _btnDelete,
                        )
                    ],
                )
            ],
        );
        return new Container(
            margin: const EdgeInsets.all(10.0),
            child: _column,
        );
    }
}

class DetailTaskScreen extends StatefulWidget {
    final int id;

    DetailTaskScreen({
        this.id
    }); 

    @override 
    State<StatefulWidget> createState() {
        return new DetailTaskScreenState();
    }
}

class DetailTaskScreenState extends State<DetailTaskScreen> {
    @override 
    Widget build(BuildContext buildContext) {
        return new Scaffold(
            appBar: new AppBar(
                title: new Text('Detail Task'),
            ),
            body: new FutureBuilder(
                future: fetchTaskById(new http.Client(), widget.id),
                builder: (context, snapshot) {
                    if (snapshot.hasError) {
                        print(snapshot.error);
                    } 
                    return snapshot.hasData ? new DetailTask(task: snapshot.data) : new Center(
                        child: new CircularProgressIndicator(),
                    );
                },
            ),
        );
    }
}