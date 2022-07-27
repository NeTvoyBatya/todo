import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';

String zeroPadded(String string){
  string="00"+string;
  return string.substring(string.length-2);
}

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

class DailyTask{
  late String name;
  late bool isEveryday;
  late int doneTime;
  late String forDay;
  late int id;
  late int showIndex;

  DailyTask({required this.name, this.isEveryday=true, this.doneTime=0, this.forDay="None", this.showIndex=0});

  Map<String, dynamic> toMap(){
    return {'name': this.name, 'isEveryday': this.isEveryday? 1:0, 'doneTime': this.doneTime,
            'forDay': this.forDay, 'showIndex': this.showIndex
           };
  }

  DailyTask.fromMap(Map<dynamic, dynamic> dbMap){
    this.name = dbMap["name"];
    this.isEveryday = dbMap["isEveryday"] == 1;
    this.doneTime = dbMap["doneTime"];
    this.forDay = dbMap["forDay"];
    this.id = dbMap["id"];
    this.showIndex = dbMap["showIndex"];
  }

  void done(){
    this.doneTime = DateTime.now().millisecondsSinceEpoch;
  }

  bool available(){
    if(this.isEveryday){
      return true;
    }
    Map<String, dynamic>forDay = jsonDecode(this.forDay);
    String type = forDay["type"];
    DateTime now = DateTime.now();
    switch (type) {
      case "oneday":
        String dateString = forDay["date"];
        return "${zeroPadded(now.day.toString())}.${zeroPadded(now.month.toString())}.${now.year}" == dateString? true : false;
      case "weekdays":
        List<int> activeDays = forDay["days"].cast<int>();
        return activeDays.contains(now.weekday-1);
      default:
        return false;
    }}

  bool isDoneToday(){
    DateTime done = DateTime.fromMillisecondsSinceEpoch(this.doneTime).toLocal();
    DateTime now = DateTime.now().toLocal();

    if (done.year == now.year && done.month == now.month && done.day == now.day){
      return true;
    }
    //done.year < now.year || (done.year == now.year && done.month < now.month) || (done.year == now.year && done.month == now.month && done.day < now.day)
    return false;
  }

  String nextAvailableTime(Map<String, dynamic> localization){
    String type = jsonDecode(this.forDay)["type"];
    switch (type) {
      case "oneday":
      String weekday = localization['schedule']['longWeekdays'][DateFormat("d.M.y").parse(jsonDecode(this.forDay)["date"]).weekday-1];
        return localization["schedule"]["taskWillBeAvailable"]+jsonDecode(this.forDay)["date"]+" (${weekday})";
      case "weekdays":
        List<int> remainingWeek = [for (int i = DateTime.now().weekday+1; i < 7; i+=1) i];
        List<int> activeWeekdays = jsonDecode(this.forDay)["days"].cast<int>();
        for (int day in remainingWeek){
          if (activeWeekdays.contains(day)){
            DateTime nextDate = DateTime.now().add(Duration(days: day+1-DateTime.now().weekday));
            return localization["schedule"]["taskWillBeAvailable"]+localization["schedule"]["longWeekdays"][day]+" (${zeroPadded(nextDate.day.toString())}.${zeroPadded(nextDate.month.toString())}.${nextDate.year.toString().substring(2)})";
          }
        }
        int nextDay = activeWeekdays[0];
        DateTime nextDate = DateTime.now().add(Duration(days: 7-DateTime.now().weekday+activeWeekdays[0]+1));
        return localization["schedule"]["taskWillBeAvailable"]+localization["schedule"]["longWeekdays"][nextDay]+" (${zeroPadded(nextDate.day.toString())}.${zeroPadded(nextDate.month.toString())}.${nextDate.year.toString().substring(2)})";
      default:
        return "Undefined";
    }
  }

   @override
  String toString(){
    return '(${this.id}) Task by name $name, IsEveryday: ${isEveryday}, Type: ${jsonDecode(forDay)['type']}';
  }

}
