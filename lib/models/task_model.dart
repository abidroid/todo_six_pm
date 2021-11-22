class TaskModel {
  late String taskId;
  late String taskName;
  late int dt;

  TaskModel({
    required this.taskId,
    required this.taskName,
    required this.dt,
  });

  static TaskModel fromMap(Map<String, dynamic> map) {
    return TaskModel(
      taskId: map['taskId'],
      taskName: map['taskName'],
      dt: map['dt'],
    );
  }
}
