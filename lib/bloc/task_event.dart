abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}
class ClearAllTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final String title;
  AddTask(this.title);
}

class ToggleTask extends TaskEvent {
  final int index;
  ToggleTask(this.index);
}

class DeleteTask extends TaskEvent {
  final int index;
  DeleteTask(this.index);
}

class UpdateTask extends TaskEvent {
  final int index;
  final String newTitle;

  UpdateTask(this.index, this.newTitle);
}