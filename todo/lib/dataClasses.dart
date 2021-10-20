import 'dart:math';

extension TasksParsing on String{
  List<Task> parseTasks(){
    List<Task> list = [];
    List<String> parsedTasks = this.split('*');
    parsedTasks.removeLast();
    parsedTasks.forEach((element) {
      List<String> taskElements = element.split('~');
      Task parsedTask = Task(desc:taskElements[0], isDone: taskElements[1]=='true');
      list.add(parsedTask);
    });
  return list;
  }
}

class Task{
  String desc;
  bool isDone;

  Task({required this.desc, this.isDone=false});

  void done(){
    this.isDone = true;
  }
}

class Goal{
  late String name;
  late String desc;
  late List<Task> tasks;
  late bool isDone;
  late int dbId;

  Goal({required this.name, required this.desc, required this.tasks, this.isDone=false});

  Goal.fromMap(Map<dynamic, dynamic> dbMap){
    this.name = dbMap['name'];
    this.desc = dbMap['desc'];
    this.tasks = (dbMap['tasks'] as String).parseTasks();
    this.isDone = dbMap['isDone']==1;
    this.dbId = dbMap['id'];
  }

  Task getLastTask(){
    return this.tasks.last;
  }

  Task getFirstTask(){
    return this.tasks.first;
  }

  Task getRandomTask(){
    if(this.tasks.isEmpty){
      return Task(desc: 'No tasks right now!', isDone: false);
    }
    if(this.tasks.length == 1){
      return this.tasks[0];
    }
    return this.tasks[Random().nextInt(this.tasks.length-1)];
  }

  void checkIfDone(){
    this.tasks.forEach((task) {
      if(task.isDone == false){
        this.isDone = false;
        return;
      }
    });
    this.isDone = true;
    return;
  }

  void newTask(String desc, {bool isDone=false}){
    this.tasks.add(Task(desc: desc, isDone: isDone));
    this.checkIfDone();
  }

  void taskDone(int taskIndex){
    this.tasks[taskIndex].done();
    this.checkIfDone();
  }

  double getProgress(){
    if(tasks.length == 0){
      return 0.0;
    }
    int tasksCount = this.tasks.length;
    int doneTasksCount = 0;
    this.tasks.forEach((task) {
      if(task.isDone){
        doneTasksCount++;
      }
     });
    if(doneTasksCount == 0){
      return 0.0;
    }
    return doneTasksCount/tasksCount;
  }

  String tasksToString(){
    String str = '';
    this.tasks.forEach((element) { 
      element.desc = element.desc.replaceAll('~', ' ');
      element.desc = element.desc.replaceAll('*', ' ');
      str+='${element.desc}~${element.isDone.toString()}*';
    });
    return str;
  }

  Map<String, dynamic>toMap(){
    this.name.replaceAll('~', ' ');
    this.name.replaceAll('*', ' ');
    this.desc.replaceAll('~', ' ');
    this.desc.replaceAll('*', ' ');
    return{'name':name, 'desc':desc, 'tasks':this.tasksToString(), 'isDone': isDone? 1:0};
  }

  @override
  String toString(){
    return 'Goal by name $name have ${tasks.length} tasks and is ${isDone? 'done': 'not done'}';
  }
}
