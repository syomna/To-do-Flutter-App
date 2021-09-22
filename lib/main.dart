import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:todo/layouts/home_layout.dart';
import 'package:todo/shared/components/components.dart';
import 'package:todo/shared/cubit/bloc_observer.dart';

void main() {
  Bloc.observer = MyBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: color),
      home: new SplashScreen(
          seconds: 4,
          navigateAfterSeconds: HomeLayout(),
          title: new Text(
            'Todo List',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: color),
          ),
          image: new Image.asset('assets/images/todo.png'),
          backgroundColor: Colors.white,
          styleTextUnderTheLoader: new TextStyle(),
          photoSize: 200.0,
          loaderColor: color),
    );
  }
}
