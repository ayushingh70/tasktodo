import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'task_event.dart';
import 'task_state.dart';
import '../models/task.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final Box _taskBox = Hive.box('tasksBox');

  TaskBloc() : super(TaskState([])) {
    // Load existing tasks on start
    on<LoadTasks>((event, emit) {
      final storedTasks = _taskBox.values
          .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      emit(TaskState(storedTasks));
    });

    on<AddTask>((event, emit) {
      final updated = List<Task>.from(state.tasks)
        ..add(Task(title: event.title));
      _saveToHive(updated);
      emit(TaskState(updated));
    });

    on<ToggleTask>((event, emit) {
      final updated = List<Task>.from(state.tasks);
      updated[event.index].isCompleted = !updated[event.index].isCompleted;
      _taskBox.clear();
      for (var task in updated) {
        _taskBox.add(task.toMap());
      }

      emit(TaskState(updated));
    });

    on<DeleteTask>((event, emit) {
      final updated = List<Task>.from(state.tasks)..removeAt(event.index);
      _saveToHive(updated);
      emit(TaskState(updated));
    });

    on<ClearAllTasks>((event, emit) {
      _taskBox.clear(); // clears Hive storage
      emit(TaskState([])); // updates UI
    });

    // Load tasks immediately
    add(LoadTasks());
  }

  void _saveToHive(List<Task> tasks) {
    _taskBox.clear();
    for (var task in tasks) {
      _taskBox.add(task.toMap());
    }
  }
}