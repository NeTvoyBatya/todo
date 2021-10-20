import 'package:flutter/material.dart';



class SettingsItem extends StatefulWidget{
  final Icon settingIcon;
  final Text settingName;
  final Text settingDescription;
  final Widget settingButton;

  const SettingsItem({
    Key? key,
    required this.settingIcon,
    required this.settingName,
    required this.settingDescription,
    required this.settingButton
  }) : super(key: key);

  @override
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  @override
  Widget build(BuildContext context){
    return Container(
      height: 70.0,
      child: 
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(right: 5)),
            widget.settingIcon,
            Padding(padding: EdgeInsets.only(right: 25)),
            Expanded(
              child: 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        widget.settingName,
                        widget.settingDescription
                      ]
                    ),
                    widget.settingButton,
                  ]
                )
              ),
            Padding(padding: EdgeInsets.only(right: 20))

          ],
        ),
    );
  }
}
//--------------------------
class InkWellSettingsItem extends StatefulWidget{
  final Icon settingIcon;
  final Text settingName;
  final Text settingDescription;
  final void Function() onTap;


  const InkWellSettingsItem({
    Key? key,
    required this.settingIcon,
    required this.settingName,
    required this.settingDescription,
    required this.onTap
  }) : super(key: key);

  @override
  State<InkWellSettingsItem> createState() => _InkWellSettingsItemState();
}

class _InkWellSettingsItemState extends State<InkWellSettingsItem> {
  @override
  Widget build(BuildContext context){
    return InkWell(
      onTap: widget.onTap,
      child: 
        Container(
          height: 70.0,
          child: 
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.only(right: 5)),
                widget.settingIcon,
                Padding(padding: EdgeInsets.only(right: 25)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.settingName,
                    widget.settingDescription
                  ]
                ),
              ]
            )
        ),
    );

  }
}