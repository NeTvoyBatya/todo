
import 'package:sqflite/sqflite.dart';
import 'package:todo/dataClasses.dart';

class DatabaseService {
  final Database db;

  DatabaseService(this.db);

  Future<List<Goal>> getAllGoals() async{
    List<Goal> goalsList = [];
    List<Map> goalsMaps = await db.query('goals');
    goalsMaps.forEach((map) {
      goalsList.add(Goal.fromMap(map));
    });
    return goalsList;
  }

  Future<List<Goal>?> getRandomGoals() async{
    List<Map> goalsList = await this.db.query('goals');
    if(goalsList.length == 1){
      List<Map> randomGoals = await db.rawQuery('SELECT * FROM goals ORDER BY RANDOM() LIMIT 1;');
      return [Goal.fromMap(randomGoals[0]), Goal(name: 'Set a new goal!', desc: 'Sample goal desc', tasks: [Task(desc: 'And it will be here')])];
    }else if(goalsList.length > 1){
      List<Map> randomGoals = await db.rawQuery('SELECT * FROM goals ORDER BY RANDOM() LIMIT 2;');
      return [Goal.fromMap(randomGoals[0]), Goal.fromMap(randomGoals[1])];
    }else{
      return null;
    }
  }

  Future<Map<dynamic, dynamic>>getGoal(int index)async {
    List<Map> query = await this.db.query('goals', where: 'id=?', whereArgs: [index]);
    return query[0];
  }

  Future<int> insertGoal(Goal goal) async{
    return this.db.insert('goals', goal.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> deleteGoal(int index) async{
    int deletedRows = await this.db.delete('goals', where: 'id=?', whereArgs: [index]);
    if(deletedRows > 0 ){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> deleteTask(int goalIndex, int taskIndex) async{
    Goal goal = Goal.fromMap(await this.getGoal(goalIndex));
    goal.tasks.removeAt(taskIndex);
    int updatedRows = await this.db.update('goals', goal.toMap(), where: 'id=?', whereArgs: [goalIndex]);
    if(updatedRows > 0){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> editGoal(int index, String newName, String newDesc) async{
    Goal goal = Goal.fromMap(await this.getGoal(index));
    goal.name = newName;
    goal.desc = newDesc;
    int updatedRows = await this.db.update('goals', goal.toMap(), where: 'id=?', whereArgs: [index]);
    if(updatedRows > 0){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> editTask(int goalIndex, int taskIndex,  String newDesc) async{
    Goal goal = Goal.fromMap(await this.getGoal(goalIndex));
    goal.tasks[taskIndex].desc = newDesc;
    int updatedRows = await this.db.update('goals', goal.toMap(), where: 'id=?', whereArgs: [goalIndex]);
    if(updatedRows > 0){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> taskDone(int goalIndex, int taskIndex) async{
    Goal goal = Goal.fromMap(await this.getGoal(goalIndex));
    goal.taskDone(taskIndex);
    int updatedRows = await this.db.update('goals', goal.toMap(), where: 'id=?', whereArgs: [goalIndex]);
    if(updatedRows > 0){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> addTask(int index, String task, {bool isDone=false}) async{
    Goal goal = Goal.fromMap(await this.getGoal(index));
    goal.newTask(task, isDone: isDone);
    int updatedRows = await this.db.update('goals', goal.toMap(), where: 'id=?', whereArgs: [index]);
    if(updatedRows > 0){
      return true;
    }else{
      return false;
    }
  }
}