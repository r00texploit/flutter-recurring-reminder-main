import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reccuring_reminder/common/values/colors.dart';
import 'package:flutter_reccuring_reminder/common/values/constant.dart';
import 'package:flutter_reccuring_reminder/pages/home/home_page.dart';
import 'package:flutter_reccuring_reminder/pages/input/bloc/input_bloc.dart';
import 'package:flutter_reccuring_reminder/pages/input/bloc/input_event.dart';
import 'package:flutter_reccuring_reminder/pages/input/input_controller.dart';
import 'package:flutter_reccuring_reminder/pages/input/input_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'bloc/input_state.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  late InputController inputController;

  @override
  void initState() {
    super.initState();
    inputController = InputController(context: context);
    inputController.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black,
            height: 1.0.h,
          ),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.mainTheme,
        title: const Center(
            child: Text(
          'مهمة جديدة',
          style: TextStyle(color: Colors.white),
        )),
      ),
      body: BlocBuilder<InputBloc, InputState>(builder: (context, state) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 20.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeadingText(title: 'ما الذي يجب القيام به؟'),
                    SizedBox(height: 10.h),
                    buildTaskField(
                      onChanged: (task) {
                        context.read<InputBloc>().add(TaskEvent(task: task));
                      },
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeadingText(title: 'إضافة إلى قائمة'),
                    SizedBox(
                      height: 10.h,
                    ),
                    buildDropDown(
                      context: context,
                      selectedValue: state.list ?? AppConstant.INITIAL_LIST,
                      inital: AppConstant.INITIAL_LIST,
                      dropDownList: AppConstant.LIST,
                      onChanged: (list) {
                        context.read<InputBloc>().add(ListEvent(list: list));
                      },
                    )
                  ],
                ),
                SizedBox(height: 30.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeadingText(title: 'التكرار'),
                    SizedBox(
                      height: 10.h,
                    ),
                    buildDropDown(
                      context: context,
                      selectedValue:
                          state.duration ?? AppConstant.INITIAL_RECURRENCE,
                      inital: AppConstant.INITIAL_RECURRENCE,
                      dropDownList: AppConstant.RECURRENCE,
                      onChanged: (duration) {
                        context
                            .read<InputBloc>()
                            .add(RecurrenceEvent(duration: duration));
                      },
                    )
                  ],
                ),
                SizedBox(height: 30.h),
                state.duration == AppConstant.INITIAL_RECURRENCE
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildHeadingText(title: 'ما هو موعد الإنتهاء؟'),
                          SizedBox(height: 10.h),
                          buildDateTimePicker(
                            context: context,
                            onDateTimeChanged: (dateTime) {
                              context
                                  .read<InputBloc>()
                                  .add(DateAndTimeEvent(dateTime: dateTime));
                            },
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  buildHeadingText(title: 'موعد الإنتهاء : '),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.green,
                                        size: 18.w,
                                      ),
                                      SizedBox(
                                        width: 5.0.w,
                                      ),
                                      buildAlarmText(
                                          text:
                                              '${state.dateTime!.day.toString()}/${state.dateTime!.month.toString()}/${state.dateTime!.year.toString()}'),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  buildHeadingText(title: 'موعد الإنتهاء : '),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        color: Colors.green,
                                        size: 18.w,
                                      ),
                                      SizedBox(
                                        width: 5.0.w,
                                      ),
                                      state.dateTime!.minute < 10
                                          ? buildAlarmText(
                                              text:
                                                  '${state.dateTime!.hour.toString()}:0${state.dateTime!.minute.toString()}')
                                          : buildAlarmText(
                                              text:
                                                  '${state.dateTime!.hour.toString()}:${state.dateTime!.minute.toString()}'),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : buildDurationText(state.duration),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.mainTheme,
        onPressed: () {
          inputController.generateTask();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const Home()));
        },
        tooltip: 'تم',
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}
