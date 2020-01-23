const http = require('http');
const fs = require('fs');

const getTodos = async () => {
    return await fs.readFileSync('todos.json');
}

const getTasksByTodoId = async todoId => {
    const tasks = await fs.readFileSync('tasks.json');
    const taskJsons = JSON.parse(tasks.toString());
    return taskJsons.filter(task => task.todo_id === todoId);
}

const getTaskById = async id => {
    const tasks = await fs.readFileSync('tasks.json');
    const taskJsons = JSON.parse(tasks.toString());
    return taskJsons.find(task => task.id === id);
}

const updateTask = async task => {
    const findTask = await getTaskById(task.id);
    if (!findTask) {
        throw new Error('Data not found');
    } else {
        const tasks = await fs.readFileSync('tasks.json');
        const taskJsons = JSON.parse(tasks.toString());
        const tasksExceptTask = taskJsons.filter(task => task.id !== findTask.id);
        findTask.name = task.name;
        findTask.isFinished = task.isFinished;
        tasksExceptTask.push(findTask);
        await fs.writeFileSync('tasks.json', JSON.stringify(tasksExceptTask));
        return findTask;
    }
}

const deleteTask = async id => {
    const findTask = await getTaskById(id);
    if (!findTask) {
        throw new Error('Data not found');
    } else {
        const tasks = await fs.readFileSync('tasks.json');
        const taskJsons = JSON.parse(tasks.toString());
        const tasksExceptTask = taskJsons.filter(task => task.id !== findTask.id);
        await fs.writeFileSync('tasks.json', JSON.stringify(tasksExceptTask));
        return findTask;
    }
}

const server = http.createServer((req, res, next) => {
    switch (req.method) {
        case 'GET':
            if (req.url === '/todos') {
                getTodos().then(todos => res.end(JSON.stringify({
                    result: 'ok',
                    data: JSON.parse(todos.toString())
                }))).catch(err => res.end(JSON.stringify({
                    result: 'fail',
                    data: []
                })));
            } else if (req.url.includes('/tasks/todoid/')) {
                const splits = req.url.split('/');
                const todoId = splits[splits.length - 1];
                if (todoId === '') {
                    res.end(JSON.stringify({
                        result: 'fail',
                        data: []
                    }));
                } else {
                    getTasksByTodoId(parseInt(todoId)).then(todos => {
                        res.end(JSON.stringify({
                            result: 'ok',
                            data: todos || []
                        }));
                    }).catch(err => {
                        console.log(err);
                        res.end(JSON.stringify({
                            result: 'fail',
                            data: []
                        }))
                    });
                }
            } else if (req.url.includes('/tasks/')) {
                const splits = req.url.split('/');
                const id = splits[splits.length - 1];
                if (id === '') {
                    res.end(JSON.stringify({
                        result: 'fail',
                        data: {}
                    }));
                } else {
                    getTaskById(parseInt(id)).then(task => {
                        res.end(JSON.stringify({
                            result: 'ok',
                            data: task || {}
                        }));
                    }).catch(err => {
                        console.log(err);
                        res.end(JSON.stringify({
                            result: 'fail',
                            data: {}
                        }))
                    });
                }
            }
            break;
        case 'PUT':
            req.on('data', chunk => {
                if (req.url.includes('/tasks/')) {
                    const splits = req.url.split('/');
                    const id = splits[splits.length - 1];
                    if (id === '') {
                        res.end(JSON.stringify({
                            result: 'fail',
                            data: {}
                        }));
                    } else {
                        console.log(chunk.toString());
                        const task = JSON.parse(chunk.toString());
                        task.id = parseInt(id);
                        task.isFinished = Boolean(task.isFinished);
                        updateTask(task).then(taskUpdate => {
                            res.end(JSON.stringify({
                                result: 'ok',
                                data: taskUpdate || {}
                            }));
                        }).catch(err => {
                            console.log(err);
                            res.end(JSON.stringify({
                                result: 'fail',
                                data: {}
                            }));
                        });
                    }
                }
            });
            break;
        case 'DELETE':
            if (req.url.includes('/tasks/')) {
                const splits = req.url.split('/');
                const id = splits[splits.length - 1];
                if (id === '') {
                    res.end(JSON.stringify({
                        result: 'fail',
                        data: {}
                    }));
                } else {
                    deleteTask(parseInt(id)).then(taskDelete => {
                        res.end(JSON.stringify({
                            result: 'ok',
                            data: taskDelete || {}
                        }));
                    }).catch(err => {
                        console.log(err);
                        res.end(JSON.stringify({
                            result: 'fail',
                            data: {}
                        }));
                    });
                }
            }
            break;    
    }
});

const PORT = 3000;

server.listen(PORT, err => {
    if (err) throw err;
    console.log(`Server is running on port ${PORT}`);
});