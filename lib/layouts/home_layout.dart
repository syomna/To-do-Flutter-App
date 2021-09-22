import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo/shared/components/components.dart';
import 'package:todo/shared/cubit/cubit.dart';
import 'package:todo/shared/cubit/states.dart';

class HomeLayout extends StatefulWidget {
  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var taskController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertToDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          var cubit = AppCubit.get(context);
          return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                title: Text(
                  cubit.screenTitle[cubit.currentIndex],
                  style: TextStyle(color: Colors.white),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(cubit.isBottomSheetShown ? Icons.check : Icons.add),
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {
                  if (cubit.isBottomSheetShown) {
                    if (formKey.currentState.validate()) {
                      cubit.insertToDatabase(
                          title: taskController.text,
                          time: timeController.text,
                          date: dateController.text);
                    }
                  } else {
                    scaffoldKey.currentState
                        .showBottomSheet(
                          (context) => Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultTextField(
                                    label: 'Task',
                                    prefixIcon: Icons.border_color,
                                    controller: taskController,
                                    validationString:
                                        'task label must not be empty'),
                                defaultTextField(
                                    label: 'time',
                                    prefixIcon: Icons.timer_rounded,
                                    controller: timeController,
                                    readOnly: true,
                                    validationString: 'enter a time',
                                    onTap: () {
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      ).then((value) => timeController.text =
                                          value.format(context));
                                    }),
                                defaultTextField(
                                    label: 'date',
                                    prefixIcon: Icons.date_range_rounded,
                                    controller: dateController,
                                    validationString: 'enter a date',
                                    readOnly: true,
                                    onTap: () {
                                      showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(2101))
                                          .then((value) => dateController.text =
                                              DateFormat.yMMMd().format(value));
                                    })
                              ],
                            ),
                          ),
                        )
                        .closed
                        .then((value) {
                      cubit.bottomSheetShown(false);
                    });
                    cubit.bottomSheetShown(true);
                  }
                },
              ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 17,
                selectedIconTheme: IconThemeData(size: 25),
                currentIndex: cubit.currentIndex,
                onTap: (value) {
                  cubit.changeIndexValue(value);
                },
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.menu_rounded), title: Text('New')),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.check_circle_outline),
                      title: Text('Done')),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.archive), title: Text('Archived')),
                ],
              ),
              body: cubit.children[cubit.currentIndex]);
        },
      ),
    );
  }
}
