import 'package:flutter/material.dart';
import 'package:todo/UserData.dart';
import 'package:todo/databaseService.dart';
import 'package:todo/dataClasses.dart';
import 'package:todo/styles/TODOTheme.dart';
import 'package:collection/collection.dart';
import 'package:todo/coloredExpansionPanelList.dart' as colored;


class GoalsPanel extends StatefulWidget {
  const GoalsPanel({ Key? key }) : super(key: key);

  @override
  _GoalsPanelState createState() => _GoalsPanelState();
}

class _GoalsPanelState extends State<GoalsPanel> {
  late UserData user;
  late DatabaseService db;
  late TODOTheme theme;
  int? expandedGoalIndex;
  List<Goal>? allGoalsList;


  void loadUserGoals() async{
    //Loading user's goals from local Database
    List<Goal> userGoals = await db.getAllGoals();
    setState(() {
      this.allGoalsList = userGoals;
    }); 
  }

  void showGoal(int index){
    //This function expands a goal card to show tasks
      setState(() {
        if(index < this.allGoalsList!.length && index != this.expandedGoalIndex){
          this.expandedGoalIndex = index;
        }else{
          this.expandedGoalIndex = null;
        }
      });
    }

  void taskDone(int goalIndex, int taskIndex){
    setState(() {
      this.allGoalsList![goalIndex].taskDone(taskIndex);
    });
    this.db.taskDone(this.allGoalsList![goalIndex].dbId, taskIndex);
  }



  void newGoal() async{
    Map goalDialogData = {'name': null, 'desc': null};
    Map? dialogResult = await showDialog(
      context: context,
      builder: (BuildContext context){
        return SimpleDialog(
          backgroundColor: theme.colorTable.backgroundColor,
          elevation: 2.0,
          titlePadding: EdgeInsets.fromLTRB(8, 8, 0, 0),
          contentPadding: EdgeInsets.fromLTRB(10, 15, 15, 10),
          title: Text(user.localization["goals"]["setNewGoal"], style: this.theme.textStyles.normal24 ,),
          children: [
            TextField(cursorColor: theme.colorTable.secondaryColor, minLines: 1, maxLines: 4, style: this.theme.textStyles.normal18, decoration: InputDecoration(focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorTable.secondaryColor)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorTable.mainShadeColor)), labelText: user.localization["goals"]["goalName"], labelStyle: theme.textStyles.subTitle12), onChanged: (String name) {goalDialogData['name'] = name;},),
            TextField(cursorColor: theme.colorTable.secondaryColor, minLines: 1, maxLines: 4, style: this.theme.textStyles.normal18, decoration: InputDecoration(focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorTable.secondaryColor)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorTable.mainShadeColor)),labelText: user.localization["goals"]["goalDescription"], labelStyle: theme.textStyles.subTitle12), onChanged: (String desc) {goalDialogData['desc'] = desc;}),
            SimpleDialogOption(child: OutlinedButton(style: this.theme.widgetStyles.goalsDialogButton, onPressed: () {Navigator.pop(context, goalDialogData);}, child: Text(user.localization["goals"]["createGoalButton"], style: this.theme.textStyles.normal18,)), onPressed: () {Navigator.pop(context, goalDialogData);},)
          ],
        );
      }
    );
    if(dialogResult == null || dialogResult['name'] == null || dialogResult['name'].isEmpty || dialogResult['desc'] == null || dialogResult['desc'].isEmpty){
      print('bad data in dialog');
      return;
    }

    Goal goal = Goal(name: dialogResult['name'], desc: dialogResult['desc'],tasks: []);
    int newGoalIndex = this.allGoalsList!.length;
    setState(() {
      this.allGoalsList!.add(goal);
    });

    int newGoalId = await db.insertGoal(goal);
    print(newGoalId);
    this.allGoalsList![newGoalIndex].dbId = newGoalId;
  }

  void newTask(int goalIndex) async{
    Map taskDialogData = {'desc': null};
    Map? dialogResult = await showDialog(
      context: context,
      builder: (BuildContext context){
        return SimpleDialog(
          backgroundColor: theme.colorTable.backgroundColor,
          elevation: 2.0,
          titlePadding: EdgeInsets.fromLTRB(8, 8, 0, 0),
          contentPadding: EdgeInsets.fromLTRB(10, 15, 15, 10),
          title: Text(user.localization["goals"]["addNewTask"], style: this.theme.textStyles.normal24),
          children: [
            TextField(cursorColor: theme.colorTable.secondaryColor, minLines: 1, maxLines: 4, style: this.theme.textStyles.normal18, decoration: InputDecoration(focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorTable.secondaryColor)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorTable.mainShadeColor)), labelText: user.localization["goals"]["shortTaskDescription"], labelStyle:theme.textStyles.subTitle12), onChanged: (String desc) {taskDialogData['desc'] = desc;}),
            SimpleDialogOption(child: OutlinedButton(style: theme.widgetStyles.goalsDialogButton, onPressed: () {Navigator.pop(context, taskDialogData);}, child: Text(user.localization["goals"]["addNewTask"], style: this.theme.textStyles.normal18,)), onPressed: () {Navigator.pop(context, taskDialogData);},)
          ],
        );
      }
    );
    if(dialogResult == null || dialogResult['desc'] == null || dialogResult['desc'].isEmpty){
      return;
    }
    setState(() {
      this.allGoalsList![goalIndex].newTask(dialogResult['desc']);
    });
    this.db.addTask(this.allGoalsList![goalIndex].dbId, dialogResult['desc']);
  }

  void goalLongPress(int index) async{
    var result =  await showModalBottomSheet(backgroundColor: theme.colorTable.backgroundColor, context: context, builder: (BuildContext context){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {Navigator.pop(context, 'delete');}, 
            child: Row(
              children: [
                Icon(Icons.delete, color: theme.colorTable.secondaryColor),
                Padding(padding: EdgeInsets.only(right: 8)),
                Text(user.localization["goals"]["deleteGoalButton"], style: this.theme.textStyles.normal20,)
              ],
            )
          ),
          TextButton(
            onPressed: () {Navigator.pop(context, 'edit');}, 
            child: Row(
              children: [
                Icon(Icons.edit, color: theme.colorTable.secondaryColor),
                Padding(padding: EdgeInsets.only(right: 8)),
                Text(user.localization["goals"]["editGoalButton"], style: this.theme.textStyles.normal20,)
              ],
            )
          )
        ],
      );
    });
    if(result == null){
      return;
    }
    switch (result) {
      case 'delete':
        deleteGoal(index);
        break;
      case'edit':
        editGoal(index);
        break;
      default:
        return;
    }
  }

  void taskLongPress(int goalIndex, int taskIndex) async{
    var result =  await showModalBottomSheet(backgroundColor: theme.colorTable.backgroundColor, context: context, builder: (BuildContext context){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {Navigator.pop(context, 'delete');}, 
            child: Row(
              children: [
                Icon(Icons.delete, color: theme.colorTable.secondaryColor),
                Padding(padding: EdgeInsets.only(right: 8)),
                Text(user.localization["goals"]["deleteTaskButton"], style: this.theme.textStyles.normal20,)
              ],
            )
          ),
          TextButton(
            onPressed: () {Navigator.pop(context, 'edit');}, 
            child: Row(
              children: [
                Icon(Icons.edit, color: theme.colorTable.secondaryColor),
                Padding(padding: EdgeInsets.only(right: 8)),
                Text(user.localization["goals"]["editTaskButton"], style: this.theme.textStyles.normal20,)
              ],
            )
          )
        ],
      );
    });
    if(result == null){
      return;
    }
    switch (result) {
      case 'delete':
        deleteTask(goalIndex, taskIndex);
        break;
      case'edit':
        editTask(goalIndex, taskIndex);
        break;
      default:
        return;
    }
  }

  void deleteGoal(int index) async{
    Goal deletedGoal = this.allGoalsList![index];
    bool res = await db.deleteGoal(this.allGoalsList![index].dbId);
    if(res){
      setState(() {
        allGoalsList!.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: theme.colorTable.backgroundColor,
          elevation: 2.0,
          content: Text(user.localization["goals"]["goalDeleted"].replaceAll("%goalName%", deletedGoal.name), style: theme.textStyles.normal18,),
          action: SnackBarAction(
            textColor: theme.colorTable.mainTextColor,
            label: user.localization["goals"]["snackbarUndo"],
            onPressed: () async {
              await db.insertGoal(deletedGoal);
              setState(() {
                allGoalsList!.add(deletedGoal);
              });
            },
          ),
        )
      );
    }
  }

  void deleteTask(int goalIndex, int taskIndex) async{
    bool res = await this.db.deleteTask(this.allGoalsList![goalIndex].dbId, taskIndex);
    Task deletedTask = this.allGoalsList![goalIndex].tasks[taskIndex];
    if(res){
      setState(() {
      this.allGoalsList![goalIndex].tasks.removeAt(taskIndex);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: theme.colorTable.backgroundColor,
          elevation: 2.0,
          content: Text(user.localization["goals"]["taskDeleted"].replaceAll("%taskName%", deletedTask.desc), overflow: TextOverflow.ellipsis,  style: theme.textStyles.normal18,),
          action: SnackBarAction(
            textColor: theme.colorTable.mainTextColor,
            label: user.localization["goals"]["snackbarUndo"],
            onPressed: () async {
              await db.addTask(this.allGoalsList![goalIndex].dbId, deletedTask.desc, isDone: deletedTask.isDone);
              setState(() {
                allGoalsList![goalIndex].newTask(deletedTask.desc, isDone: deletedTask.isDone);
              });
            },
          ),
        )
      );
    }
    
    
  }

  void editGoal(int index) async{
    String name = this.allGoalsList![index].name;
    TextEditingController nameController = new TextEditingController();
    nameController.value = TextEditingValue(
      text: name,
      selection: TextSelection.fromPosition(
        TextPosition(offset: name.length),
      ),
    );
    String desc = this.allGoalsList![index].desc;
    TextEditingController descController = new TextEditingController();
    descController.value = TextEditingValue(
      text: desc,
      selection: TextSelection.fromPosition(
        TextPosition(offset: desc.length),
      ),
    );
    Map goalDialogData = {'name': null, 'desc': null};
    Map? dialogResult = await showDialog(
      context: context,
      builder: (BuildContext context){
        return SimpleDialog(
          backgroundColor: theme.colorTable.backgroundColor,
          elevation: 2.0,
          titlePadding: EdgeInsets.fromLTRB(8, 8, 0, 0),
          contentPadding: EdgeInsets.fromLTRB(10, 15, 15, 10),
          title: Text(user.localization["goals"]["editGoalButton"], style: this.theme.textStyles.normal24,),
          children: [
            TextField(cursorColor: theme.colorTable.secondaryColor, controller: nameController, minLines: 1, maxLines: 4, style: this.theme.textStyles.normal18, decoration: InputDecoration(focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorTable.secondaryColor)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorTable.mainShadeColor)), labelText: user.localization["goals"]["goalName"], labelStyle:theme.textStyles.subTitle12), onChanged: (String name) {goalDialogData['name'] = name;},),
            TextField(cursorColor: theme.colorTable.secondaryColor, controller: descController, minLines: 1, maxLines: 4, style: this.theme.textStyles.normal18, decoration: InputDecoration(focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorTable.secondaryColor)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorTable.mainShadeColor)), labelText: user.localization["goals"]["goalDescription"], labelStyle:theme.textStyles.subTitle12), onChanged: (String desc) {goalDialogData['desc'] = desc;}),
            SimpleDialogOption(child: OutlinedButton(style: this.theme.widgetStyles.goalsDialogButton, onPressed: () {Navigator.pop(context, goalDialogData);}, child: Text(user.localization["goals"]["editGoalButton"], style: this.theme.textStyles.normal18,)), onPressed: () {Navigator.pop(context, goalDialogData);},)
          ],
        );
      }
    );
    if(dialogResult == null || dialogResult['name'] == null || dialogResult['name'].isEmpty || dialogResult['desc'] == null || dialogResult['desc'].isEmpty){
      print('bad data in dialog');
      return;
    }

    setState(() {
      this.allGoalsList![index].name = dialogResult['name'];
      this.allGoalsList![index].desc = dialogResult['desc'];
    });

    this.db.editGoal(this.allGoalsList![index].dbId, dialogResult['name'], dialogResult['desc']);
  }

  void editTask(int goalIndex, int taskIndex) async{
    String desc = this.allGoalsList![goalIndex].tasks[taskIndex].desc;
    TextEditingController descController = new TextEditingController();
    descController.value = TextEditingValue(
      text: desc,
      selection: TextSelection.fromPosition(
        TextPosition(offset: desc.length),
      ),
    );
    Map taskDialogData = {'desc': null};
    Map? dialogResult = await showDialog(
      context: context,
      builder: (BuildContext context){
        return SimpleDialog(
          backgroundColor: theme.colorTable.backgroundColor,
          elevation: 2.0,
          titlePadding: EdgeInsets.fromLTRB(8, 8, 0, 0),
          contentPadding: EdgeInsets.fromLTRB(10, 15, 15, 10),
          title: Text(user.localization["goals"]["editTaskButton"], style: this.theme.textStyles.normal24,),
          children: [
            TextField(cursorColor: theme.colorTable.secondaryColor, controller: descController, minLines: 1, maxLines: 4, style: this.theme.textStyles.normal18, decoration: InputDecoration(focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorTable.secondaryColor)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorTable.mainShadeColor)), labelText: user.localization["goals"]["shortTaskDescription"], labelStyle: theme.textStyles.subTitle12), onChanged: (String desc) {taskDialogData['desc'] = desc;}),
            SimpleDialogOption(child: OutlinedButton(style: this.theme.widgetStyles.goalsDialogButton, onPressed: () {Navigator.pop(context, taskDialogData);}, child: Text(user.localization["goals"]["editTaskButton"], style: this.theme.textStyles.normal18,)), onPressed: () {Navigator.pop(context, taskDialogData);},)
          ],
        );
      }
    );
    if(dialogResult == null || dialogResult['desc'] == null || dialogResult['desc'].isEmpty){
      print('bad data in dialog');
      return;
    }
    setState(() {
      this.allGoalsList![goalIndex].tasks[taskIndex].desc = dialogResult['desc'];
    });
    this.db.editTask(this.allGoalsList![goalIndex].dbId, taskIndex, dialogResult['desc']);
  }

  void expansionPanelListCallback(int index, bool isExpanded) {
    setState(() {
      if(isExpanded){
        this.expandedGoalIndex = null;
      }else{
        this.expandedGoalIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    this.db = args['db'];
    this.user = args['user'];
    this.theme = this.user.theme;

    if(this.allGoalsList == null){
      loadUserGoals();
    }

    List<Goal>? goalsList = this.allGoalsList;
    if(goalsList != null && goalsList.isNotEmpty){
      return Scaffold(
      backgroundColor: theme.colorTable.backgroundColor,
      appBar: AppBar(title: Text('TODO', style: theme.textStyles.bold24,), backgroundColor: theme.colorTable.mainColor,),
      body:
        Align(
            alignment: Alignment.topCenter,
            child:
              SingleChildScrollView(
                child:colored.ColoredExpansionPanelList(
                    color: theme.colorTable.secondaryColor,
                    expansionCallback: this.expansionPanelListCallback,
                    children: this.allGoalsList!.mapIndexed<colored.ExpansionPanel>((int goalIndex, Goal goal) {
                      return colored.ExpansionPanel(
                        backgroundColor: theme.colorTable.backgroundColor,
                        headerBuilder: (BuildContext context, bool isExpanded){
                          return InkWell(
                              onLongPress: () {goalLongPress(goalIndex);},
                              onTap: () {this.expansionPanelListCallback(goalIndex, isExpanded);},
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(goal.name, style: this.theme.textStyles.normal20,),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(goal.desc, style: this.theme.textStyles.subTitle14,),
                                        Padding(padding: EdgeInsets.symmetric(vertical: 3, horizontal: 0)),
                                        if(goal.getProgress() >0.0) LinearProgressIndicator(
                                          backgroundColor: theme.colorTable.mainShadeColor,
                                          color: theme.colorTable.secondaryColor,
                                          value: goal.getProgress(),
                                        ),Padding(padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0)),
                                        
                                      ],
                                    )
                                  )
                                ],
                                ),
                            );
                        },
                        body: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: goal.tasks.length+1,
                          itemBuilder: (BuildContext context, int taskIndex){
                            return taskIndex == goal.tasks.length?
                              Align(
                                alignment: Alignment.centerLeft,
                                child:
                                ListTile(
                                  leading: Icon(Icons.add_task, color: theme.colorTable.mainColor,),
                                  title: Text(user.localization["goals"]["addNewTask"], style: theme.textStyles.normal18),
                                  trailing: OutlinedButton(onPressed: () {newTask(goalIndex);}, style: theme.widgetStyles.taskDoneButton, child: Text(user.localization["goals"]["addButton"], style: theme.textStyles.normal16,)),
                                )
                              ):
                              Align(
                                alignment: Alignment.centerLeft,
                                child:
                                ListTile(
                                  onLongPress: () {taskLongPress(goalIndex, taskIndex);},
                                  leading: goal.tasks[taskIndex].isDone ? Icon(Icons.done, color: theme.colorTable.mainColor,): Icon(Icons.construction, color: theme.colorTable.mainColor,),
                                  title: Text(goal.tasks[taskIndex].desc, style: theme.textStyles.normal18),
                                  trailing: OutlinedButton(onPressed: () {taskDone(goalIndex, taskIndex);}, style: theme.widgetStyles.taskDoneButton, child: Text(user.localization["goals"]["taskDone"], style: theme.textStyles.normal16,)),
                                )
                              );
                          }),
                      isExpanded: goalIndex==this.expandedGoalIndex
                      );
                    }).toList(),
                )
            )
          ),
        floatingActionButton: 
          FloatingActionButton(
            backgroundColor: theme.colorTable.mainColor,
            onPressed: () {newGoal();},
            child: Icon(Icons.add, color: theme.colorTable.secondaryColor,),
          ),
        );
  }else{
      return Scaffold(
      backgroundColor: theme.colorTable.backgroundColor,
      appBar: AppBar(title: Text('TODO', style: theme.textStyles.bold24,), backgroundColor: theme.colorTable.mainColor),
      body: Center(child: Text(user.localization["goals"]["addFirstGoal"], style: this.theme.textStyles.normal20, textAlign: TextAlign.center,)),
      floatingActionButton: 
          FloatingActionButton(
            onPressed: () {newGoal();},
            child: Icon(Icons.add),
          ),
      );
    }
  }
}
