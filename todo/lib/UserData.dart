import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/styles/TODOTheme.dart';

class UserData{
  final String username;
  final String userphoto;
  final TODOTheme theme;
  final SharedPreferences sharedPreferences;
  final Map<String, dynamic> localization;
  UserData(this.username, this.userphoto, this.theme, this.sharedPreferences, this.localization);

  
}
