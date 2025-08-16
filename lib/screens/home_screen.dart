import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../bloc/theme_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String filter = "All";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70,

        leading: IconButton(
          icon: Icon(
            Icons.person,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          tooltip: "Profile",
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile is not needed")),
            );
          },
        ),

        title: Text(
          "Task Manager",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black),
            tooltip: "Clear All Tasks",
            onPressed: () {
              if (context.read<TaskBloc>().state.tasks.isNotEmpty) {
                _confirmClearAll(context);
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.brightness_6,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            tooltip: "Toggle Theme",
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        ],
      ),

      // ✅ Gradient Background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F0F0F), const Color(0xFF2C2C2C)]
                : [const Color(0xFFFDFBFB), const Color(0xFFECE9E6)], // subtle warm white gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // ✅ Task Counter
                BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    return Text(
                      "You have ${state.tasks.length} tasks",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // ✅ Filter Tabs (Theme Adaptive)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.08) // darker container in dark mode
                        : Colors.black.withOpacity(0.05), // lighter container in light mode
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ["All", "Pending", "Completed"].map((tab) {
                      bool isActive = filter == tab;
                      return GestureDetector(
                        onTap: () {
                          setState(() => filter = tab);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 25,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.blueAccent.withOpacity(0.85) // active in dark
                                : Colors.deepPurple.withOpacity(0.8)) // active in light
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            tab,
                            style: TextStyle(
                              fontSize: 16,
                              color: isActive
                                  ? Colors.white
                                  : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black87), // adaptive text color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ Task List
                Expanded(
                  child: BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, state) {
                      // Apply filter
                      final tasks = state.tasks.where((task) {
                        if (filter == "Pending") return !task.isCompleted;
                        if (filter == "Completed") return task.isCompleted;
                        return true;
                      }).toList();

                      if (tasks.isEmpty) {
                        return Center(
                          child: Text(
                            "No tasks here 😴",
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 18,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          return Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 6),
                            child: ListTile(
                              leading: Transform.scale(
                                scale: 1.3, // ✅ Bigger Checkbox
                                child: Checkbox(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  activeColor: Colors.blueAccent,
                                  value: task.isCompleted,
                                  onChanged: (_) {
                                    context.read<TaskBloc>().add(ToggleTask(index));

                                    if (!task.isCompleted) {
                                      _showSnack(context, 'Task "${task.title}" Completed ✅', Colors.green);
                                    } else {
                                      _showSnack(context, 'Task "${task.title}" Marked Pending ⏳', Colors.orange);
                                    }
                                  },
                                ),
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: isDark
                                            ? Colors.amberAccent
                                            : Colors.blueAccent),
                                    onPressed: () {
                                      _showEditDialog(
                                          context, index, task.title);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      context
                                          .read<TaskBloc>()
                                          .add(DeleteTask(index));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ✅ Floating Add Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.blueAccent
            : Colors.indigoAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Task"),
        onPressed: () {
          _showAddTaskSheet(context);
        },
      ),
    );
  }

  // Confirm Clear All Dialog
  void _confirmClearAll(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          "Clear All Tasks?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          "Are you sure you want to delete all tasks? This cannot be undone.",
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              context.read<TaskBloc>().add(ClearAllTasks());
              Navigator.pop(context);
              _showSnack(context, "All tasks cleared 🧹", Colors.redAccent);
            },
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }

  // Add Task BottomSheet
  void _showAddTaskSheet(BuildContext context) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // for rounded+shadow container
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: "Enter new task",
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor:
                  isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isDark ? Colors.blueAccent : Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 52),
                  elevation: 2,
                ),
                icon: const Icon(Icons.check),
                label: const Text("Add Task"),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    context
                        .read<TaskBloc>()
                        .add(AddTask(controller.text.trim()));
                    Navigator.pop(context);
                    _showSnack(context, "Task added ✅", Colors.green);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Edit Task Dialog
  void _showEditDialog(BuildContext context, int index, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          "Edit Task",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: controller,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor:
            isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              isDark ? Colors.blueAccent : Colors.indigoAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<TaskBloc>().add(DeleteTask(index));
                context
                    .read<TaskBloc>()
                    .add(AddTask(controller.text.trim()));
                Navigator.pop(context);
                _showSnack(
                    context, "Task updated ✏️", isDark ? Colors.blueAccent : Colors.indigoAccent);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Snackbar
  void _showSnack(BuildContext context, String message, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isDark ? 8 : 4,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}