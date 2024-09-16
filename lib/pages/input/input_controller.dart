import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_reccuring_reminder/common/database/firebase.dart';
import 'package:flutter_reccuring_reminder/common/entities/task.dart';
import 'package:flutter_reccuring_reminder/common/values/constant.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'bloc/input_bloc.dart';

class InputController {
  final BuildContext context;
  InputController({required this.context});
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void init() {
    tz.initializeTimeZones();
    _getLocalTimeZone();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title ?? ''),
        content: Text(body ?? ''),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ok'),
            onPressed: () async {
              // Navigator.of(context, rootNavigator: true).pop();
              // await Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => SecondScreen(payload),
              //   ),
              // );
            },
          )
        ],
      ),
    );
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }

  Future _getLocalTimeZone() async {
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  }

  NotificationDetails _androidNotificationDetails() {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('notification', 'notification',
            channelDescription: 'notification',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    return notificationDetails;
  }

  Future generateZonedSchedule(
      int id, String title, String body, int time) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(Duration(seconds: time)),
        _androidNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future generateRecurrciveTask(
      int id, String title, String body, RepeatInterval repeatInterval) async {
    await flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      _androidNotificationDetails(),
    );
  }

  Future<void> cancelNotification(String id) async {
    await flutterLocalNotificationsPlugin.cancel(int.parse(id));
  }

  void generateTask() {
    var state = context.read<InputBloc>().state;
    String? body = state.task;
    DateTime? dateTime = state.dateTime;
    String? list = state.list;
    String? duration = state.duration;
    String id = Random().nextInt(10000).toString();

    int pick = (dateTime!.millisecondsSinceEpoch ~/ 1000);
    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int time = pick - now;
    if (duration == AppConstant.INITIAL_RECURRENCE) {
      generateZonedSchedule(int.parse(id), list!, body!, time);
    } else if (duration == AppConstant.RECURRENCE[1]) {
      generateRecurrciveTask(
          int.parse(id), list!, body!, RepeatInterval.hourly);
    } else if (duration == AppConstant.RECURRENCE[2]) {
      generateRecurrciveTask(int.parse(id), list!, body!, RepeatInterval.daily);
    } else if (duration == AppConstant.RECURRENCE[3]) {
      generateRecurrciveTask(
          int.parse(id), list!, body!, RepeatInterval.weekly);
    }
    final task = Task(
      id: id,
      title: list!,
      body: body!,
      user: FirebaseAuth.instance.currentUser!.uid,
      recurrence: duration!,
      dateTime: pick,
    );

    print(
        'id= ${task.id} , title=${task.title} , body=${task.body} , repeat= ${task.recurrence} , date=${task.dateTime} , user=${task.user}');
    TasksDatabase.instance.create(task);
    print('data save');
  }
}
