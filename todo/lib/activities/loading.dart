import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo/databaseService.dart';
import 'package:todo/UserData.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/styles/TODOTheme.dart';
import 'dart:convert';


class LoadingPanel extends StatefulWidget {
  @override
  State<LoadingPanel> createState() => _LoadingPanelState();
}

class _LoadingPanelState extends State<LoadingPanel> {
  Map<String, bool> loadingState = {'googleState': false, 'databaseState': false, 'sharedPrefsState': false, 'themeState': false, 'localizationState': false};

  late DatabaseService db;

  GoogleSignIn googleSignIn = GoogleSignIn();

  int loginAttempts = 1;

  late BuildContext ctx;

  late SharedPreferences sharedPreferences;

  late TODOTheme loadedTheme;

  late Map<String, dynamic> localization;

  String username = 'User';

  String userPhoto = 'https://www.google.com/images/branding/googleg/2x/googleg_standard_color_96dp.png';

  void signIn() async{
    Future future;
    print('Starting Login Process');
    try {
      if(googleSignIn.currentUser != null){
        print('User Already Logged In');
        onLoggedIn(googleSignIn.currentUser);
        return;
      }
      if(await googleSignIn.isSignedIn()){
        print('Logging Previously user');
        future = googleSignIn.signInSilently();
      }else{
        print('Logging New user');
        future = googleSignIn.signIn();
      }
      future.then((loggedUser) => onLoggedIn(loggedUser));
    }catch (error){reSignIn();}
  }

  void reSignIn(){
    if(this.loginAttempts <5){
      print('ERR: User not Logged In, trying ${this.loginAttempts} time');
      signIn();
      this.loginAttempts++;
    }else{
      print('ERR: User not Logged In, continuing without login');
      onLoggedIn(null);
    }
  }

  void onLoggedIn(GoogleSignInAccount? account) async{
    if(account != null){
      String? displayName = account.displayName;
      String? photoUrl = account.photoUrl;
      if(displayName != null){
        this.username = displayName;
      }
      if(photoUrl != null){
        this.userPhoto = photoUrl;
      }
    }else{
      if(await googleSignIn.isSignedIn()){
        await googleSignIn.signOut();
        signIn();
        return;
      }
    }
    print('Logged in with ${account?.displayName??'no account'}');
    this.loadingState['googleState'] = true;
    isLoadingDone();
    }

  void loadDatabase() async{
    WidgetsFlutterBinding.ensureInitialized();
    print('Starting DataBase loading process');
    print(join(await getDatabasesPath(), 'todo_goals.db'));
    try{
      Future<Database> future = openDatabase(
        join(await getDatabasesPath(), 'todo_goals.db'),
        onCreate: (db, version) {
          db.execute(
            'CREATE TABLE goals(id INTEGER PRIMARY KEY, name TEXT, desc TEXT, tasks TEXT, isDone INTEGER)',
          );
        },
        version: 1,
      );
      future.then((database) => onDatabaseLoaded(database));
    }catch(error){print('ERR: DataBase not loaded because of $error');}
  }

  void onDatabaseLoaded(Database db) async{
      print('DataBase loaded');
      this.db = DatabaseService(db);    
      this.loadingState['databaseState'] = true;
      isLoadingDone();
  }

  void loadLocalization() async{
    String? loc = sharedPreferences.getString('localization');
    if(loc == null){
      sharedPreferences.setString('localization', 'en');
      loc = 'en';
    }
    Map<String, dynamic> unformatedLocalization = jsonDecode(await rootBundle.loadString('assets/localization/$loc.json'));
    unformatedLocalization.forEach((screenKey, screen) {
      screen.forEach((key, text){
        unformatedLocalization[screenKey][key] = text.replaceAll('%apostrophe%', '\'s');
      });
     });
    this.localization = unformatedLocalization;
    this.loadingState['localizationState'] = true;
  }

  void loadTheme(String id, bool isCustom) async{
    String themeName;
    String themeType;
    List<String> colorList = [];
    if(isCustom){
      List<String> themeData = sharedPreferences.getStringList(id)!;
      themeName = themeData[0];
      themeType = themeData[2];
      for (var i = 3; i < 9; i++) {
        colorList.add(themeData[i]);
      }
    }else{
      Map<String, dynamic> themeData = jsonDecode(await rootBundle.loadString('assets/DefaultThemes.json'));
      themeName = themeData[id]['name'];
      themeType = themeData[id]['type'];
      themeData[id]['colors'].forEach((colorString) {
        colorList.add(colorString);
       });
    }
    List<Color> colors = [];
    colorList.forEach((colorString) {
      colors.add(Color(int.parse(colorString)));
    });
    this.loadedTheme = TODOTheme(
      ColorTable(colors[0], colors[1], colors[2], colors[3], colors[4], colors[5]),
      themeName,
      id,
      themeType,
      isCustom
    );
    this.loadingState['themeState'] = true;
  }

  void findTheme() async{
    Map<String, dynamic> defaultThemes = jsonDecode(await rootBundle.loadString('assets/DefaultThemes.json'));
    String? savedTheme = sharedPreferences.getString('theme');
    if(sharedPreferences.getStringList('customThemes') == null){
      sharedPreferences.setStringList('customThemes', []);
    }
    if(savedTheme != null){
      if(sharedPreferences.getStringList('customThemes')!.contains(savedTheme)){
        print('Found custom theme');
        loadTheme(savedTheme, true);
        return;
      }
      if(defaultThemes[savedTheme]!= null){
        print('Found default theme');
        loadTheme(savedTheme, false);
        return;
      }
    }
    print('Theme not found or not set, loading default');
    sharedPreferences.setString('theme', 'defaultTheme');
    loadTheme('defaultTheme', false);
  }

  void loadSharedPrefs() async{
    this.sharedPreferences = await SharedPreferences.getInstance();
    findTheme();
    loadLocalization();
    print('Prefs are loaded');
    this.loadingState['sharedPrefsState'] = true;
    }

  void isLoadingDone(){
    bool loaded = true;
    this.loadingState.forEach((key, value) {
      if(!value){
        loaded = false;
      }
     });
    if(!loaded){
      return;
    }
    print('Loading done, goind to Home');
    UserData user = UserData(this.username, this.userPhoto, loadedTheme, this.sharedPreferences, this.localization);
    Navigator.pushReplacementNamed(ctx, '/home', arguments: {'user': user, 'db': db});
  }

  @override
  Widget build(BuildContext context){
    this.ctx = context;
    signIn();
    loadDatabase();
    loadSharedPrefs();
    return SafeArea(child: Center(child: CircularProgressIndicator(),));
  }
}

  

  

  


  

  

