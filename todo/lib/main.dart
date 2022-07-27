import 'package:flutter/material.dart';
import 'package:todo/activities/goals.dart';
import 'package:todo/activities/home.dart';
import 'package:todo/activities/loading.dart';
import 'package:todo/activities/settings.dart';
import 'package:todo/activities/schedule.dart';


void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  routes: {
    '/loading': (context) => LoadingPanel(),
    '/home': (context) => HomePanel(),
    '/goals': (context) => GoalsPanel(),
    '/settings': (context) => SettingsPanel(),
    '/schedule': (context) => SchedulePanel()
  },
  initialRoute: '/loading'
));

