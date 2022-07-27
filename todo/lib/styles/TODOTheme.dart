import 'package:flutter/material.dart';


abstract class TextStyles{
  ColorTable colorTable;
  abstract TextStyle normal24;
  abstract TextStyle normal20;
  abstract TextStyle normal18;
  abstract TextStyle normal16;
  abstract TextStyle normal14;
  abstract TextStyle normal12;
  abstract TextStyle semiBold20;
  abstract TextStyle semiBold18;
  abstract TextStyle bold20;
  abstract TextStyle bold24;
  abstract TextStyle bold18;
  abstract TextStyle subTitle16;
  abstract TextStyle subTitle14;
  abstract TextStyle subTitle12;
  abstract TextStyle link14;
  abstract TextStyle link16;
  abstract TextStyle link18;

  void loadStyles();

  TextStyles(this.colorTable){
    loadStyles();
  }
}

abstract class WidgetStyles{
  ColorTable colorTable;
  abstract ShapeBorder cardBorder;
  abstract ButtonStyle viewGoalsButton;
  abstract ButtonStyle goalsDialogButton;
  abstract ButtonStyle taskDoneButton;
  abstract ShapeBorder goalBorder;
  abstract ShapeBorder popupMenuBorder;

  void loadStyles();

  WidgetStyles(this.colorTable){
    this.loadStyles();
  }
}

class ColorTable{
  Color mainColor;
  Color mainShadeColor;
  Color secondaryColor;
  Color backgroundColor;
  Color mainTextColor;
  Color subtitleTextColor;

  ColorTable(this.mainColor, this.mainShadeColor, this.secondaryColor, this.backgroundColor, this.mainTextColor, this.subtitleTextColor);
}


class DefaultTextStyles extends TextStyles{
  ColorTable colorTable;
  late TextStyle normal24;
  late TextStyle normal20;
  late TextStyle normal18;
  late TextStyle normal16;
  late TextStyle normal14;
  late TextStyle normal12;
  late TextStyle semiBold20;
  late TextStyle semiBold18;
  late TextStyle bold20;
  late TextStyle bold24;
  late TextStyle bold18;
  late TextStyle subTitle16;
  late TextStyle subTitle14;
  late TextStyle subTitle12;
  late TextStyle link14;
  late TextStyle link16;
  late TextStyle link18;


  DefaultTextStyles(this.colorTable) : super(colorTable);


  @override
  void loadStyles(){
    this.normal24 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 24,
      fontWeight: FontWeight.normal,
      color: colorTable.mainTextColor,
    );

    this.normal20 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 20,
      fontWeight: FontWeight.normal,
      color: colorTable.mainTextColor,
    );

    this.normal18 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: colorTable.mainTextColor,
    );

    this.normal16 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: colorTable.mainTextColor,
    );

    this.normal14 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: colorTable.mainTextColor,
    );

    this.normal12 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: colorTable.mainTextColor,
    );

    this.semiBold20 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: colorTable.mainTextColor,
    );

    this.semiBold18 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: colorTable.mainTextColor,
    );

    this.bold24 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: colorTable.mainTextColor,
    );

    this.bold20 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: colorTable.mainTextColor,
    );

    this.bold18 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: colorTable.mainTextColor,
    );

    this.subTitle16 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: colorTable.subtitleTextColor,
    );

    this.subTitle14 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: colorTable.subtitleTextColor,
    );

    this.subTitle12 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: colorTable.subtitleTextColor,
    );

    this.link14 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: colorTable.secondaryColor,
      decoration: TextDecoration.underline
    );

    this.link16 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: colorTable.secondaryColor,
      decoration: TextDecoration.underline
    );

    this.link18 = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: colorTable.secondaryColor,
      decoration: TextDecoration.underline
    );
  }
  
}

class DefaultWidgetStyles extends WidgetStyles{
  ColorTable colorTable;
  late ShapeBorder cardBorder;
  late ButtonStyle viewGoalsButton;
  late ButtonStyle goalsDialogButton;
  late ButtonStyle taskDoneButton;
  late ShapeBorder goalBorder;
  late ShapeBorder popupMenuBorder;

  DefaultWidgetStyles(this.colorTable) : super(colorTable);

  @override
  void loadStyles(){
    this.cardBorder = 
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorTable.secondaryColor)
      );
    
    this.viewGoalsButton = 
      OutlinedButton.styleFrom(
        primary: colorTable.secondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),),
        side: BorderSide(color: colorTable.secondaryColor),
        padding: EdgeInsets.symmetric(horizontal: 80 ,vertical: 10)
      );
    
    this.goalsDialogButton = 
      OutlinedButton.styleFrom(
      side: BorderSide(color: colorTable.secondaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20 ,vertical: 5)
      );
    
    this.taskDoneButton = 
      OutlinedButton.styleFrom(
        side: BorderSide(color: colorTable.secondaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 5 ,vertical: 5)
      );
    
    this.popupMenuBorder = 
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorTable.secondaryColor),
      );
    

  }
}


class TODOTheme{
  ColorTable colorTable;
  late TextStyles textStyles;
  late WidgetStyles widgetStyles;
  late String name;
  late String id;
  late String type;
  bool isCustom;

  TODOTheme(this.colorTable, this.name, this.id, this.type, this.isCustom, {TextStyles? customTextStyles, WidgetStyles? customWidgetStyles}){
    if(customTextStyles != null){
      this.textStyles = customTextStyles;
    }else{
      this.textStyles = DefaultTextStyles(colorTable);
    }

    if(customWidgetStyles != null){
      this.widgetStyles = customWidgetStyles;
    }else{
      this.widgetStyles = DefaultWidgetStyles(colorTable);
    }
  }
}
