import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:todo/UserData.dart';
import 'package:todo/databaseService.dart';
import 'package:todo/dataClasses.dart';
import 'package:todo/styles/TODOTheme.dart';
import 'dart:convert';
import 'package:flutter/services.dart';


class HomePanel extends StatefulWidget {
  const HomePanel({Key? key}) : super(key: key);
  
  @override
  _HomePanelState createState() => _HomePanelState();
  
}

class _HomePanelState extends State<HomePanel> {
  late UserData user;
  late DatabaseService db;
  late TODOTheme theme;
  bool themesLoaded = false;
  List<TODOTheme> defaultThemes = [];
  List<TODOTheme> customThemes = [];
  List<Goal>? randomGoalsList;
  int goals = 0;
  int navigationIndex = 1;

  void viewGoalsScreen(){
    Navigator.pushNamed(context, '/goals', arguments: {'user': this.user, 'db': db});
  }

  void checkUserGoals() async{
    print('Checking for user\'s goals');
    List<Goal>? randomGoals = await this.db.getRandomGoals();
    if(randomGoals != null){
      setState(() {
        this.randomGoalsList = randomGoals;
      });
    }
  }

  void getAllThemes() async{
    Map<String, dynamic> defaultThemeMap = jsonDecode(await rootBundle.loadString('assets/DefaultThemes.json'));
    defaultThemeMap.forEach((key, value) {
      List<dynamic> colorList = value['colors'];
      List<String> castedList = colorList.cast<String>();
      defaultThemes.add(TODOTheme(
        ColorTable(
          Color(int.parse(castedList[0])),
          Color(int.parse(castedList[1])),
          Color(int.parse(castedList[2])),
          Color(int.parse(castedList[3])),
          Color(int.parse(castedList[4])),
          Color(int.parse(castedList[5]))
        ),
        value['name'],
        key,
        value['type'],
        false
      ));
    });
    List<List<String>> customThemesList = [];
    user.sharedPreferences.getStringList('customThemes')!.forEach((themeId) {
      customThemesList.add(user.sharedPreferences.getStringList(themeId)!);
     });

    customThemesList.forEach((customTheme) {
      customThemes.add(TODOTheme(
        ColorTable(
          Color(int.parse(customTheme[3])),
          Color(int.parse(customTheme[4])),
          Color(int.parse(customTheme[5])),
          Color(int.parse(customTheme[6])),
          Color(int.parse(customTheme[7])),
          Color(int.parse(customTheme[8])),
        ),
        customTheme[0],
        customTheme[1],
        customTheme[2],
        true
      ));
     });
    this.themesLoaded = true;
  }

  void setTheme(TODOTheme theme){
    user.sharedPreferences.setString('theme', theme.id);
    Navigator.pushNamedAndRemoveUntil(context, '/loading', (a) {return false;});
  }

  void deleteTheme(int index){
    TODOTheme deletedTheme = customThemes[index];
    List<String> customSavedThemes = this.user.sharedPreferences.getStringList('customThemes')!;
    customSavedThemes.remove(deletedTheme.id);
    this.user.sharedPreferences.setStringList('customThemes', customSavedThemes);
    this.user.sharedPreferences.remove(deletedTheme.id);
    setState(() {
      customThemes.removeAt(index);
      Navigator.pop(context);
      if(deletedTheme.id == theme.id || deletedTheme.id == this.user.sharedPreferences.getString('theme')){
        this.user.sharedPreferences.setString('theme', 'defaultTheme');
        Navigator.pushNamedAndRemoveUntil(context, '/loading', (a) {return false;});
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: theme.colorTable.backgroundColor,
            elevation: 2.0,
            content: Text(user.localization["home"]['themeDeleted'].replaceAll("%themeName%", deletedTheme.name), style: theme.textStyles.normal18,),
            action: SnackBarAction(
              textColor: theme.colorTable.mainTextColor,
              label: user.localization["home"]["themeDeletedUndo"], 
              onPressed: (){
                List<String> customSavedThemes = this.user.sharedPreferences.getStringList('customThemes')!;
                customSavedThemes.add(deletedTheme.id);
                this.user.sharedPreferences.setStringList('customThemes', customSavedThemes);
                this.user.sharedPreferences.setStringList(
                  deletedTheme.id,
                  [
                    deletedTheme.name,
                    deletedTheme.id,
                    deletedTheme.type,
                    deletedTheme.colorTable.mainColor.value.toString(),
                    deletedTheme.colorTable.mainShadeColor.value.toString(),
                    deletedTheme.colorTable.secondaryColor.value.toString(),
                    deletedTheme.colorTable.backgroundColor.value.toString(),
                    deletedTheme.colorTable.mainTextColor.value.toString(),
                    deletedTheme.colorTable.subtitleTextColor.value.toString(),
                  ]);
                setState(() {
                  customThemes.add(deletedTheme);
                });
              }
            )
          )
        );
      }
    });
  }

  void popupSelected(int value){
    switch (value) {
      case 1:
        Navigator.pushNamed(context, '/settings', arguments: {'user': this.user, 'db': db});
        break;
      case 2:
        if(themesLoaded){
          showDialog(context: context, builder: (context) => 
            SimpleDialog(
              backgroundColor: theme.colorTable.backgroundColor,
              elevation: 2.0,
              titlePadding: EdgeInsets.fromLTRB(8, 8, 0, 0),
              contentPadding: EdgeInsets.fromLTRB(10, 15, 15, 10),
              title: Text(user.localization["home"]["chooseTheme"], style: this.theme.textStyles.normal24 ,),
              children: [
                Container(
                  width: double.maxFinite,
                  height: 250.0,
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior(),
                    child: GlowingOverscrollIndicator(
                      axisDirection: AxisDirection.down,
                      color: user.theme.colorTable.mainShadeColor,
                      child: ListView.builder(itemCount: defaultThemes.length+customThemes.length+1,itemBuilder: (BuildContext context, int index){
                        return index < defaultThemes.length ?
                        ListTile(
                          title: OutlinedButton(style: theme.widgetStyles.taskDoneButton, onPressed: () {setTheme(defaultThemes[index]);}, child: Text(defaultThemes[index].name, style: theme.textStyles.normal18,)),
                          subtitle: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.circle, color:  defaultThemes[index].colorTable.mainColor), Icon(Icons.circle, color:  defaultThemes[index].colorTable.mainTextColor), Icon(Icons.circle, color:  defaultThemes[index].colorTable.secondaryColor)],),
                        ):
                        index>(defaultThemes.length+customThemes.length)-1?
                        ListTile(
                          title: OutlinedButton(style: theme.widgetStyles.taskDoneButton, onPressed: () {createCustomTheme();}, child: Text(user.localization["home"]["createCustomTheme"], style: theme.textStyles.normal18,)), 
                        ):
                        ListTile(
                          title: OutlinedButton(style: theme.widgetStyles.taskDoneButton, onPressed: () {setTheme(customThemes[index-defaultThemes.length]);}, onLongPress: () {deleteTheme(index-defaultThemes.length);}, child: Text(customThemes[index-defaultThemes.length].name, style: theme.textStyles.normal18,)),
                          subtitle: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.circle, color:  customThemes[index-defaultThemes.length].colorTable.mainColor), Icon(Icons.circle, color:  customThemes[index-defaultThemes.length].colorTable.mainTextColor), Icon(Icons.circle, color:  customThemes[index-defaultThemes.length].colorTable.secondaryColor)],),
                        );
                      }),
                    ),
                  )
                )
                
              ],
            )
          );
        }
        break;
      default:
        return;
    }
  }



  void createCustomTheme() async{
    List<Map<String, dynamic>> colors = [
      {'id': 'mainColor', 'name': user.localization["home"]["mainColorName"], 'color': null},
      {'id': 'mainShadeColor', 'name': user.localization["home"]["mainShadeColorName"], 'color': null},
      {'id': 'secondaryColor', 'name': user.localization["home"]["secondaryColorName"], 'color': null},
      {'id': 'backgroundColor', 'name': user.localization["home"]["backgroundColorName"], 'color': null},
      {'id': 'mainTextColor', 'name': user.localization["home"]["mainTextColorName"], 'color': null},
      {'id': 'subtitleTextColor', 'name': user.localization["home"]["subtitleTextColorName"], 'color': null},
    ];
    bool isColorsSet = true;
    String? themeName;

    for (var i = 0; i < colors.length; i++) {
      await showDialog(
        context: context,
        builder: (BuildContext context) =>
          SimpleDialog(
            backgroundColor: theme.colorTable.backgroundColor,
            title: Text(user.localization["home"]["chooseColor"].replaceAll("%colorName%", colors[i]['name']), style: theme.textStyles.bold20,),
            children: [
              ColorPicker(
                showLabel: false,
                pickerColor: Color(0xFFFFFFFF),
                onColorChanged: (Color color) {colors[i]['color'] = color;}
              ),
              OutlinedButton(style: theme.widgetStyles.goalsDialogButton, onPressed: () {Navigator.pop(context);}, child: Text(user.localization["home"]["chooseColorButton"], style: theme.textStyles.normal18))
            ],
          )
        );
    }

    await showDialog(
        context: context,
        builder: (BuildContext context) =>
          SimpleDialog(
            backgroundColor: theme.colorTable.backgroundColor,
            title: Text(user.localization["home"]["chooseThemeName"], style: theme.textStyles.bold20,),
            children: [
              TextField(cursorColor: theme.colorTable.secondaryColor, minLines: 1, maxLines: 4, style: this.theme.textStyles.normal18, decoration: InputDecoration(labelText: user.localization["home"]["themeNameFieldLabel"], labelStyle: theme.textStyles.subTitle12), onChanged: (String name) {themeName = name;},),
              OutlinedButton(style: theme.widgetStyles.goalsDialogButton, onPressed: () {Navigator.pop(context);}, child: Text(user.localization["home"]["chooseThemeButton"], style: theme.textStyles.normal18))
            ],
          )
        );

    colors.forEach((element) {
      if(element['color'] is !Color){
        print('${element['name']} is not set!');
        isColorsSet = false;
      }
    });
    if(!isColorsSet || themeName == null){
      return;
    }
    List<String> customThemes = user.sharedPreferences.getStringList('customThemes')!;
    if(!customThemes.contains(themeName!.toLowerCase())){
      customThemes.add(themeName!.toLowerCase());
    }
    user.sharedPreferences.setStringList('customThemes', customThemes);

    user.sharedPreferences.setStringList(themeName!.toLowerCase(), [themeName!, themeName!.toLowerCase(), 'custom', colors[0]['color'].value.toString(), colors[1]['color'].value.toString(), colors[2]['color'].value.toString(), colors[3]['color'].value.toString(), colors[4]['color'].value.toString(), colors[5]['color'].value.toString()],);
    Navigator.pushNamedAndRemoveUntil(context, '/loading', (a) {return false;});
  }


  @override
  Widget build(BuildContext context){  
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    this.db = args['db'];
    this.user = args['user'];
    this.theme = this.user.theme;

    if(this.randomGoalsList == null){
      getAllThemes();
      checkUserGoals();
    }

    return this.buildHomeScreen();
    
  }
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

  Scaffold buildHomeScreen(){
    if(this.randomGoalsList != null){
      //Case with 2 random user's goals on main screen
      return Scaffold(
      appBar: 
        AppBar(
          title: Text('TODO', style: theme.textStyles.bold24,),
          backgroundColor: theme.colorTable.mainColor,
          actions: [
          PopupMenuButton(
            onSelected: popupSelected,
            shape: theme.widgetStyles.popupMenuBorder,
            color: theme.colorTable.backgroundColor,
            icon: Icon(Icons.more_vert, color: theme.colorTable.mainTextColor),
            itemBuilder:(context) =>
              [
                PopupMenuItem(value: 1, child: Text(user.localization["home"]["settings"], style: theme.textStyles.normal18,)),
                PopupMenuItem(value: 2, child: Text(user.localization["home"]["themes"], style: theme.textStyles.normal18,))
              ]
            
          )
        ],
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
      
      body:
        Align(
          alignment: Alignment.topCenter,
          child: 
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(user.localization["home"]['greetings'].replaceAll("%username%", this.user.username), style: theme.textStyles.normal24,),
                Padding(padding: EdgeInsets.only(top: 10)),
                CircleAvatar(
                  backgroundImage: NetworkImage(this.user.userphoto),
                  radius: 50,),
                Padding(padding: EdgeInsets.only(top: 50)),
                Text(user.localization["home"]['goalsOfToday'], textAlign: TextAlign.center, style: theme.textStyles.normal20,),
                Padding(padding: EdgeInsets.only(top: 60)),
                SizedBox(
                  width: 300,
                  height: 150,
                  child:
                    Card(
                      color: theme.colorTable.backgroundColor,
                      elevation: 10.5,
                      shape: theme.widgetStyles.cardBorder,
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 2,
                        itemBuilder: (BuildContext context, int index){return Align( alignment: Alignment.centerLeft, child: ListTile(
                        horizontalTitleGap: 0,
                        leading: randomGoalsList![index].isDone? Icon(Icons.done, color: theme.colorTable.mainColor): Icon(Icons.construction, color: theme.colorTable.mainColor),
                        title: Text(randomGoalsList![index].name, style: theme.textStyles.normal16, textAlign: TextAlign.left, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(randomGoalsList![index].getRandomTask().desc, style: theme.textStyles.subTitle12, textAlign: TextAlign.left, maxLines: 1, overflow: TextOverflow.ellipsis,),
                        ));}
                      )),
                    ),                
              ]
            )
          )
    );
    }else{
      //Case when user have no goals yet.
      return Scaffold(
      backgroundColor: theme.colorTable.backgroundColor,
      appBar: AppBar(
        title: Text('TODO'),
        backgroundColor: theme.colorTable.mainColor,
        actions: [
          PopupMenuButton(
            onSelected: popupSelected,
            shape: theme.widgetStyles.popupMenuBorder,
            color: theme.colorTable.backgroundColor,
            icon: Icon(Icons.more_vert, color: theme.colorTable.mainTextColor),
            itemBuilder:(context) =>
              [
                PopupMenuItem(value: 1, child: Text(user.localization["home"]["settings"], style: theme.textStyles.normal18,)),
                PopupMenuItem(value: 2, child: Text(user.localization["home"]["themes"], style: theme.textStyles.normal18,))
              ]
            
          )
        ],
      ),
      body:
        Align(
          alignment: Alignment.topCenter,
          child: 
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(user.localization["home"]['greetings'].replaceAll("%username%", this.user.username), style: theme.textStyles.normal24,),
                Padding(padding: EdgeInsets.only(top: 10)),
                CircleAvatar(
                  backgroundImage: NetworkImage(this.user.userphoto),
                  radius: 50,),
                Padding(padding: EdgeInsets.only(top: 50)),
                Text(user.localization["home"]["youHaveNoGoals"], textAlign: TextAlign.center, style: theme.textStyles.normal24,),
                Padding(padding: EdgeInsets.only(top: 210)),      
              ]
            )
          ),
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
      )
    );
    }
  }

}