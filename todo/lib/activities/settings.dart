import 'package:flutter/material.dart';
import 'package:todo/UserData.dart';
import 'package:todo/databaseService.dart';
import 'package:todo/settingsItemWidget.dart';
import 'package:todo/styles/TODOTheme.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({ Key? key }) : super(key: key);

  @override
  _SettingsPanelState createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late UserData user;
  late DatabaseService db;
  late TODOTheme theme;

  void languageChanged(String? lang){
    if(lang != null){
      user.sharedPreferences.setString('localization', lang);
      Navigator.pushNamedAndRemoveUntil(context, '/loading', (a) {return false;});
    }
  }

  void showInfo() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await showDialog(
        context: context,
        builder: (BuildContext context) =>
          SimpleDialog(
            titlePadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            backgroundColor: theme.colorTable.backgroundColor,
            title: Text(user.localization["settings"]["infoDialogTitle"], style: theme.textStyles.bold20, textAlign: TextAlign.center,),
            children: [
              //TODO: Add links and big icon here
              Text(user.localization["settings"]["infoDialogText"].replaceAll("%appVersion%", packageInfo.version).replaceAll("%buildVersion%", packageInfo.buildNumber), style: theme.textStyles.normal18, textAlign: TextAlign.center),
              OutlinedButton(style: theme.widgetStyles.goalsDialogButton, onPressed: () {Navigator.pop(context);}, child: Text(user.localization["settings"]["infoDialogClose"], style: theme.textStyles.normal18))
            ],
          )
        );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    this.db = args['db'];
    this.user = args['user'];
    this.theme = this.user.theme;

    return Scaffold(
      backgroundColor: theme.colorTable.backgroundColor,
      appBar: AppBar(
          title: Text('TODO', style: theme.textStyles.bold24,),
          backgroundColor: theme.colorTable.mainColor,
      ),
      body: 
        Column(
          children: [
            SettingsItem(
              settingIcon: Icon(Icons.translate, color: theme.colorTable.secondaryColor),
              settingName: Text(user.localization['settings']['localizationTitle'], style: theme.textStyles.normal18),
              settingDescription: Text(user.localization['settings']['localizationSubtitle'], style: theme.textStyles.subTitle16),
              settingButton: 
                DropdownButton(
                  iconEnabledColor: theme.colorTable.secondaryColor,
                  dropdownColor: theme.colorTable.backgroundColor,
                  value: user.sharedPreferences.getString('localization'),
                  items: [
                    DropdownMenuItem(value: 'en', child: Text('English', style: theme.textStyles.normal18,)),
                    DropdownMenuItem(value: 'ru', child: Text('Русский', style: theme.textStyles.normal18,)),
                  ],
                  onChanged: languageChanged,
                )
            ),
            //Insert new settings here
            InkWellSettingsItem(
              settingIcon: Icon(Icons.info_outlined, color: theme.colorTable.secondaryColor),
              settingName: Text(user.localization['settings']['infoTitle'], style: theme.textStyles.normal18,),
              settingDescription: Text(user.localization['settings']['infoSubtitle'], style: theme.textStyles.subTitle16,),
              onTap: showInfo
            )
            
          ],
        )
    );
  }
}