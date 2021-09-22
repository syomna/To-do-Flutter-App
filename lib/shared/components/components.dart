import 'package:conditional/conditional.dart';
import 'package:flutter/material.dart';
import 'package:todo/shared/cubit/cubit.dart';

Widget defaultTextField(
    {@required String label,
    @required TextEditingController controller,
    @required IconData prefixIcon,
    @required String validationString,
    bool readOnly = false,
    Function onTap}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextFormField(
      readOnly: readOnly,
      controller: controller,
      validator: (value) {
        if (value.isEmpty) {
          return validationString;
        }
      },
      onTap: onTap,
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderSide: BorderSide(),
          borderRadius: BorderRadius.circular(10),
        ),
        labelText: label,
      ),
    ),
  );
}

Color color = Color(0xFFe3d83b);

Widget taskCard(
    {@required Map tasks,
    @required BuildContext context,
    @required bool isDone}) {
  return Dismissible(
    key: Key(tasks['id'].toString()),
    direction: DismissDirection.startToEnd,
    background: Container(
      color: Colors.red,
      padding: const EdgeInsets.only(left: 40.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
    ),
    onDismissed: (direction) {
      AppCubit.get(context).deleteItemFormDatabase(tasks['id']);
    },
    child: Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 40,
            child: Text(
              tasks['time'],
              textAlign: TextAlign.center,
            ),
          ),
          Column(
            children: [
              Text(
                tasks['title'],
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none),
              ),
              Text(
                tasks['date'],
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
            ],
          ),
          isDone
              ? Container()
              : IconButton(
                  icon: Icon(
                    Icons.check_box,
                    size: 30,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    AppCubit.get(context)
                        .updateItem(status: 'done', id: tasks['id']);
                  }),
          isDone
              ? Container()
              : IconButton(
                  icon: Icon(
                    Icons.archive,
                    size: 30,
                  ),
                  onPressed: () {
                    AppCubit.get(context)
                        .updateItem(status: 'archived', id: tasks['id']);
                  }),
        ],
      ),
    ),
  );
}

Widget tasksBuilder({@required List tasks, bool isDone = false}) {
  return Conditional(
    condition: tasks.length <= 0,
    onConditionTrue: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book,
            size: 40,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'No tasks, Please add some',
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    ),
    onConditionFalse: ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(
            height: 1.5,
            color: color,
          );
        },
        itemBuilder: (context, index) {
          return taskCard(
              tasks: tasks[index], context: context, isDone: isDone);
        },
        itemCount: tasks.length),
  );
}
