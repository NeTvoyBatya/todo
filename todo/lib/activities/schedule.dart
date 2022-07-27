import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/UserData.dart';
import 'package:todo/databaseService.dart';
import 'package:todo/styles/TODOTheme.dart';
import 'package:todo/dataClasses.dart';
import 'package:intl/intl.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';


String zeroPadded(String string){
  string="00"+string;
  return string.substring(string.length-2);
}

class SchedulePanel extends StatefulWidget {
  const SchedulePanel({ Key? key }) : super(key: key);

  @override
  State<SchedulePanel> createState() => _SchedulePanelState();
}

class _SchedulePanelState extends State<SchedulePanel> {
  late UserData user;
  late DatabaseService db;
  late TODOTheme theme;
  List<DailyTask>? dailyList;
  int navigationIndex = 2;

  void moveToActivity(int page){
    if (this.navigationIndex == page) {
      return;
    }
    switch (page) {
      case 0:
        Navigator.pushReplacementNamed(context, '/goals', arguments: {'user': this.user, 'db': db});
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/home', arguments: {'user': this.user, 'db': db});
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/schedule', arguments: {'user': this.user, 'db': db});
        break;
    }
  }
  
  Future<DateTime> showDatePicker(DateTime currentDate) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String localeString = prefs.getString('localization') ?? 'en';
    List<String>LocaleTypesStrings = [for (int i=0; i<LocaleType.values.length; i+=1) LocaleType.values[i].toString()];
    LocaleType localeType = LocaleType.values[LocaleTypesStrings.indexOf("LocaleType.${localeString}") >=0? LocaleTypesStrings.indexOf("LocaleType.${localeString}"): 0];
    DateTime dt = DateTime.now();
    await DatePicker.showDatePicker(
      context,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(Duration(days: 365*5)),
      currentTime: currentDate,
      locale: localeType,
      theme: DatePickerTheme(
        backgroundColor: user.theme.colorTable.backgroundColor,
        headerColor: user.theme.colorTable.mainColor,
        cancelStyle: user.theme.textStyles.normal18,
        doneStyle: user.theme.textStyles.normal18,
        itemStyle: user.theme.textStyles.semiBold18),
      onChanged: (time) => dt = time,
    );
    return dt;
  }

  void newDailyTask() async{
    String dropDownValue = "everyday";
    Map dialogData = {'name': null, 'type': "everyday"};
    List<bool> weekdays = List.filled(7, true);
    DateTime oneDay = DateTime.now();
    Map? dialogResult = await showDialog(
      context: context,
      builder: (BuildContext context){
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState){
            return SimpleDialog(
              backgroundColor: theme.colorTable.backgroundColor,
              elevation: 2.0,
              titlePadding: EdgeInsets.fromLTRB(8, 8, 0, 0),
              contentPadding: EdgeInsets.fromLTRB(10, 15, 15, 10),
              title: Text(user.localization["schedule"]["addDaily"], style: this.theme.textStyles.normal24 ,),
              children: [
                TextField(cursorColor: theme.colorTable.secondaryColor, minLines: 1, maxLines: 4, style: this.theme.textStyles.normal18, decoration: InputDecoration(focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorTable.secondaryColor)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorTable.mainShadeColor)), labelText: user.localization["schedule"]["dailyName"], labelStyle: theme.textStyles.subTitle12), onChanged: (String name) {dialogData['name'] = name;},),
                Padding(padding: EdgeInsets.only(bottom:10))
                DropdownButton(
                  iconEnabledColor: theme.colorTable.secondaryColor,
                  dropdownColor: theme.colorTable.backgroundColor,
                  value: dropDownValue,
                  underline: SizedBox(),
                  items: [
                    DropdownMenuItem(value: "everyday", child: Text(user.localization["schedule"]["everydayTask"], style: theme.textStyles.normal18,)),
                    DropdownMenuItem(value: "tomorrow", child: Text(user.localization["schedule"]["tomorrowTask"], style: theme.textStyles.normal18,)),
                    DropdownMenuItem(value: "weekdays", child: Text(user.localization["schedule"]["weekdaysTask"], style: theme.textStyles.normal18,)),
                    DropdownMenuItem(value: "oneday", child: Text(user.localization["schedule"]["onedayTask"], style: theme.textStyles.normal18,))
                  ],
                  onChanged: (String? type) async {
                    if(type != null){
                      DateTime? datetime = null;
                      dialogData["type"]=type;
                      if(type == "oneday"){
                        datetime = await this.showDatePicker(oneDay)
                      }
                      setState(() {
                        if (datetime != null){
                          oneDay = datetime
                        }
                        dropDownValue=type
                      });}},),
                if (dropDownValue == "weekdays")
                WeekdaySelector(
                  selectedFillColor: user.theme.colorTable.mainColor,
                  fillColor: user.theme.colorTable.mainShadeColor,
                  color: user.theme.colorTable.mainTextColor,
                  selectedColor: user.theme.colorTable.mainTextColor,
                  firstDayOfWeek: 0,
                  shortWeekdays: List.from(user.localization["schedule"]["shortWeekdays"]),
                  values: weekdays,
                  onChanged: (int day){
                    setState((){
                      weekdays[day%7] = !weekdays[day%7];
                    })
                  },
                )
                Padding(padding: EdgeInsets.only(bottom:10))
                if (dialogData["type"] == "oneday")
                TextButton(
                  child: Text("${zeroPadded(oneDay.day.toString())}.${zeroPadded(oneDay.month.toString())}.${oneDay.year.toString().substring(2)}, ${user.localization['schedule']['shortWeekdays'][oneDay.weekday-1]}", style: user.theme.textStyles.normal16, textAlign: TextAlign.start),
                  onPressed: () async {
                    DateTime dt = await showDatePicker(oneDay)
                    setState((){
                      oneDay=dt
                    })
                  },
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                    padding: EdgeInsets.zero
                  ),
                )
                Padding(padding: EdgeInsets.only(bottom:10))
                SimpleDialogOption(child: OutlinedButton(style: this.theme.widgetStyles.goalsDialogButton, onPressed: () {Navigator.pop(context, dialogData);}, child: Text(user.localization["schedule"]["addDailyButton"], style: this.theme.textStyles.normal18,)), onPressed: () {Navigator.pop(context, dialogData);},)
              ],
            );
          }
          )
      }
    );
    if(dialogResult == null || dialogResult['name'] == null || dialogResult['name'].isEmpty){
      print('bad data in dialog');
      return;
    }

    DateTime tomorrow = DateTime.now().toLocal().add(Duration(days: 1));
    Map<String, dynamic> forDayMap = {"type": dialogResult["type"]};
    switch (dialogResult["type"]) {
      case "tomorrow":
        forDayMap["type"]="oneday";
        forDayMap["date"]="${zeroPadded(tomorrow.day.toString())}.${zeroPadded(tomorrow.month.toString())}.${tomorrow.year}";
        break;
      case "weekdays":
        List<int> activeWeekdays = [];
        weekdays.asMap().forEach((key, value) {if(value) activeWeekdays.add(key);});
        forDayMap["days"] = activeWeekdays;
        break;
      case "oneday":
        forDayMap["date"]="${zeroPadded(oneDay.day.toString())}.${zeroPadded(oneDay.month.toString())}.${oneDay.year}";
        break;
    }
    DailyTask task = DailyTask(
      name: dialogResult["name"].trim(),
      showIndex: this.dailyList!.length > 0 ? this.dailyList!.last.showIndex+1 : 0,
      isEveryday: dialogResult["type"] == "everyday" ? true : false,
      forDay: jsonEncode(forDayMap)
    );
    task.id = await db.insertDailyTask(task);
    setState(() {
      this.dailyList!.add(task);
    });
  }

  void getDailyTasks() async{
    List<DailyTask> collectedList = await db.getAllDailyTasks();
    collectedList.sort((a,b)=> a.showIndex.compareTo(b.showIndex));
    setState(() {
      this.dailyList = collectedList;
    });
  }


  void dailyTaskDone(int index){
    setState(() {
      this.dailyList![index].done();
    });
    this.db.updateDailyTask(dailyList![index]);
  }

  void deleteDailyTask(int index){
    this.db.deleteDailyTask(dailyList![index]);
    setState(() {
      this.dailyList!.removeAt(index);
    });
  }

  int countActive(){
    int active = 0;
    for(int i = 0; i <(this.dailyList?.length ?? 0); i+=1){
      if(this.dailyList?[i].available() ?? false){
        active+=1;
      }
    }
    return active;
  }

  int countInactive(){
    int inActive = 0;
    for(int i = 0; i <(this.dailyList?.length ?? 0); i+=1){
      if(!(this.dailyList?[i].available() ?? true)){
        inActive+=1;
      }
    }
    return inActive;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    this.db = args['db'];
    this.user = args['user'];
    this.theme = this.user.theme;

    if (this.dailyList == null){
      this.getDailyTasks();
    }else{
      this.dailyList!.sort((a,b)=> a.showIndex.compareTo(b.showIndex));
    }

    int activeTasks = this.countActive();
    int inactiveTasks = this.countInactive();


    return Scaffold(
      appBar: AppBar(
        title: Text('TODO', style: theme.textStyles.bold24,),
        backgroundColor: theme.colorTable.mainColor,
        actions: [
          IconButton(onPressed: newDailyTask, icon: Icon(Icons.add_circle_outline), color: user.theme.colorTable.mainTextColor)
        ]
        ),
      backgroundColor: theme.colorTable.backgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10.0,
        unselectedItemColor: user.theme.colorTable.mainTextColor,
        selectedItemColor: user.theme.colorTable.secondaryColor,
        backgroundColor: this.user.theme.colorTable.mainColor,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.first_page),
            label: user.localization["navbar"]["goalsLabel"],
            backgroundColor: Colors.blue
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: user.localization["navbar"]["homeLabel"],
            backgroundColor: Colors.red
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.last_page),
            label: user.localization["navbar"]["scheduleLabel"],
            backgroundColor: Colors.pink
          ),
        ],
      currentIndex: this.navigationIndex,
      onTap: moveToActivity,
      ),
      body: Column(
        children: [
          if (activeTasks > 0)
          Text(user.localization["schedule"]["activeTasksHeader"], style: user.theme.textStyles.bold18),
          if (activeTasks > 0)
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: user.theme.colorTable.mainShadeColor,
                child: ReorderableListView(
                  children: [
                    for (int index = 0; (index < (this.dailyList?.length ?? 0)); index+=1)
                    if(this.dailyList![index].available())
                      Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          deleteDailyTask(index);
                        },
                        background: Container(color: user.theme.colorTable.secondaryColor,),
                        child: ListTile(
                          title: Text(this.dailyList?[index].name ?? "", style: this.theme.textStyles.subTitle14),
                          trailing: (this.dailyList![index].doneTime > 0 && this.dailyList![index].isDoneToday()) ?
                            Icon(Icons.done_outlined, color: theme.colorTable.mainColor)
                            :
                            OutlinedButton(onPressed: () {dailyTaskDone(index);}, style: theme.widgetStyles.taskDoneButton, child: Text(user.localization["goals"]["taskDone"], style: theme.textStyles.normal16,)),
                          subtitle: this.dailyList![index].isDoneToday()? Text(user.localization["schedule"]["doneSubtitle"].replaceFirst("%time%", DateFormat("H:m").format(DateTime.fromMillisecondsSinceEpoch(this.dailyList![index].doneTime).toLocal())), style: theme.textStyles.subTitle12, textAlign: TextAlign.left, maxLines: 1, overflow: TextOverflow.ellipsis,): null,
                        )
                      )
                  ],
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final DailyTask item = dailyList!.removeAt(oldIndex);
                      dailyList!.insert(newIndex, item);

                      for (var i = 0; i < dailyList!.length; i++) {
                        dailyList![i].showIndex = i;
                      }
                    
                    });
                    for (var i = 0; i < dailyList!.length; i++) {
                      this.db.updateDailyTask(dailyList![i]);
                    }
                  }
                ),
              ),
            )
          ),
          if (inactiveTasks > 0)
          Text(user.localization["schedule"]["inactiveTasksHeader"], style: user.theme.textStyles.bold18),
          if (inactiveTasks > 0)
          Expanded(
            child: 
              ScrollConfiguration(
                behavior: ScrollBehavior(),
                child: GlowingOverscrollIndicator(
                  axisDirection: AxisDirection.down,
                  color: user.theme.colorTable.mainShadeColor,
                  child: ListView(
                    children: [
                      for (int index = 0; (index < (this.dailyList?.length ?? 0)); index+=1)
                      if(!this.dailyList![index].available())
                      Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          deleteDailyTask(index);
                        },
                        background: Container(color: user.theme.colorTable.secondaryColor,),
                        child: ListTile(
                          title: Text(this.dailyList?[index].name ?? "", style: this.theme.textStyles.subTitle14),
                          subtitle: Text(this.dailyList![index].nextAvailableTime(user.localization), style: theme.textStyles.subTitle12)
                        )
                      )
                    ],
                  ),
                ),
              )
          ),
          if(inactiveTasks < 1 && activeTasks < 1)
          Text(user.localization["schedule"]["noDailyTasks"], style: user.theme.textStyles.bold24, textAlign: TextAlign.center,)
        ],
      )
    );
  }
}