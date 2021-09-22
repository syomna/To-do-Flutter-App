import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/modules/archived_tasks/archived_tasks.dart';
import 'package:todo/modules/done_tasks/done_tasks.dart';
import 'package:todo/modules/new_tasks/new_tasks.dart';
import 'package:todo/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  bool isBottomSheetShown = false;
  List<Widget> children = [NewTasks(), DoneTasks(), ArchivedTasks()];
  List<String> screenTitle = ['New Tasks', 'Done Tasks', 'Archived Tasks'];

  void changeIndexValue(int value) {
    currentIndex = value;
    emit(AppNavBarIndexState());
  }

  void bottomSheetShown(bool value) {
    isBottomSheetShown = value;
    emit(AppBottomSheetState());
  }

  Database database;
  List<Map<String, Object>> newTasks = [];
  List<Map<String, Object>> doneTasks = [];
  List<Map<String, Object>> archivedTasks = [];

  Future createDatabase() async {
    database = await openDatabase('tasks.db', version: 1, onOpen: (database) {
      getDatabase(database);
      print('database opened');
    }, onCreate: (database, version) async {
      await database.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, time TEXT, date TEXT, status TEXT)');
    });
    emit(AppCreateDatabaseState());
    print('database created');

    return database;
  }

  insertToDatabase({String title, String time, String date}) async {
    await database.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO tasks(title, time, date, status) VALUES("$title", "$time", "$date", "new")');
    }).then((value) {
      print('$value inserted !');
      emit(AppInsertToDatabaseState());
      getDatabase(database);
    }).catchError((error) => print('the error is ${error.toString()}'));
    return null;
  }

  void getDatabase(Database database) async {
    emit(AppDatabaseLoadingState());
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    await database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  void updateItem({@required String status, @required int id}) async {
    await database.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {
      print('$value updated');

      emit(AppUpateItemState());
      getDatabase(database);
    });
  }

  void deleteItemFormDatabase(int id) async {
    await database
        .rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      emit(AppDeleteItemState());
      getDatabase(database);
      print('$value deleted');
    });
  }
}
