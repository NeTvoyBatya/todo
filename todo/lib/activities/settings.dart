import 'package:flutter/material.dart';
import 'package:todo/UserData.dart';
import 'package:todo/databaseService.dart';
import 'package:todo/settingsItemWidget.dart';
import 'package:todo/styles/TODOTheme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/link.dart';

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
              Image(image: AssetImage("assets/images/info_icon.png"), width:200, height: 200),
              Padding(padding: EdgeInsets.only(bottom: 10)),
              Link(
                uri: Uri.parse("https://github.com/NeTvoyBatya/todo"),
                builder: (context, followLink){
                  return RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: user.localization["settings"]["infoDialogText"].replaceAll("%appVersion%", packageInfo.version).replaceAll("%buildVersion%", packageInfo.buildNumber)+"\n",
                          style: user.theme.textStyles.normal18),
                        TextSpan(
                          text: "GitHub",
                          style: user.theme.textStyles.link18,
                          recognizer: TapGestureRecognizer()
                            ..onTap = followLink
                        )
                      ]
                    ),
                  );
                }
              ),
              Padding(padding: EdgeInsets.only(bottom: 10)),
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
                  underline: SizedBox(),
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