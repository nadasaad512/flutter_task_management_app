import 'package:flutter/material.dart';

class TaskItem {
  TaskItem({required this.title, required this.category, required this.dueLabel, this.isCompleted = false});
  final String title;
  final String category;
  final String dueLabel;
  bool isCompleted;
}

class TaskDashboardScreen extends StatefulWidget {
  @override
  State<TaskDashboardScreen> createState() => _TaskDashboardScreenState();
}

class _TaskDashboardScreenState extends State<TaskDashboardScreen> {
  final List<TaskItem> _tasks = <TaskItem>[
    TaskItem(title: 'Prepare project proposal', category: 'Work', dueLabel: 'Today · 11:30 AM'),
    TaskItem(title: 'Review Flutter UI components', category: 'Development', dueLabel: 'Today · 2:00 PM'),
    TaskItem(title: 'Send weekly progress update', category: 'Work', dueLabel: 'Tomorrow · 9:00 AM'),
    TaskItem(title: 'Organize project resources', category: 'Personal', dueLabel: 'Tomorrow · 4:30 PM', isCompleted: true),
  ];
  String _filter = 'All';
  static const Color bg = Color(0xFF0B1220);
  static const Color surface = Color(0xFF151F32);
  static const Color muted = Color(0xFF91A0B7);
  static const Color accent = Color(0xFF6C8CFF);

  int get _completed => _tasks.where((TaskItem task) => task.isCompleted).length;
  int get _active => _tasks.length - _completed;

  List<TaskItem> get _visible {
    if (_filter == 'Active') return _tasks.where((TaskItem task) => !task.isCompleted).toList();
    if (_filter == 'Completed') return _tasks.where((TaskItem task) => task.isCompleted).toList();
    return _tasks;
  }

  void _addTask() {
    final TextEditingController controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: surface,
        title: const Text('Create a task', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'What needs to get done?',
            hintStyle: const TextStyle(color: muted),
            filled: true,
            fillColor: bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white),
            onPressed: () {
              final String title = controller.text.trim();
              if (title.isNotEmpty) {
                setState(() {
                  _tasks.insert(0, TaskItem(title: title, category: 'Personal', dueLabel: 'Just added'));
                  _filter = 'All';
                });
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Add task'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width >= 760;
    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        backgroundColor: accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: wide ? 36 : 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _header(),
                  const SizedBox(height: 30),
                  const Text('MONDAY, NOVEMBER 2', style: TextStyle(color: muted, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 9),
                  const Text('Good morning, Nada 👋', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 7),
                  const Text('Here’s your overview for today.', style: TextStyle(color: muted, fontSize: 14)),
                  const SizedBox(height: 24),
                  _overview(wide),
                  const SizedBox(height: 30),
                  Row(children: <Widget>[
                    const Text('My tasks', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 9),
                    _pill('${_tasks.length}'),
                    const Spacer(),
                    const Icon(Icons.tune_rounded, color: muted, size: 19),
                  ]),
                  const SizedBox(height: 14),
                  _filters(),
                  const SizedBox(height: 14),
                  Expanded(child: _taskList()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() => Row(children: <Widget>[
    Container(width: 42, height: 42, decoration: BoxDecoration(color: accent.withOpacity(0.16), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.checklist_rounded, color: accent)),
    const SizedBox(width: 12),
    const Text('TaskFlow', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
    const Spacer(),
    Container(width: 42, height: 42, decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.notifications_none_rounded, color: Colors.white70)),
    const SizedBox(width: 10),
    const CircleAvatar(radius: 21, backgroundColor: Color(0xFF293957), child: Text('NS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
  ]);

  Widget _pill(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)), child: Text(text, style: const TextStyle(color: muted, fontSize: 11)));

  Widget _overview(bool wide) {
    final List<Widget> cards = <Widget>[
      _stat('Total tasks', '${_tasks.length}', Icons.layers_outlined, accent),
      _stat('In progress', '$_active', Icons.timelapse_rounded, const Color(0xFFF4B860)),
      _stat('Completed', '$_completed', Icons.check_circle_outline_rounded, const Color(0xFF50C7A5)),
    ];
    if (wide) return Row(children: cards.map((Widget card) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 14), child: card))).toList());
    return Column(children: cards.map((Widget card) => Padding(padding: const EdgeInsets.only(bottom: 10), child: card)).toList());
  }

  Widget _stat(String label, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.045))),
    child: Row(children: <Widget>[
      Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withOpacity(0.13), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color, size: 21)),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text(label, style: const TextStyle(color: muted, fontSize: 12)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
      ])),
    ]),
  );

  Widget _filters() => Wrap(spacing: 9, children: <String>['All', 'Active', 'Completed'].map((String item) {
    final bool selected = _filter == item;
    return ChoiceChip(
      label: Text(item),
      selected: selected,
      onSelected: (_) => setState(() => _filter = item),
      backgroundColor: surface,
      selectedColor: accent.withOpacity(0.22),
      labelStyle: TextStyle(color: selected ? const Color(0xFFB9C8FF) : muted, fontWeight: FontWeight.w600, fontSize: 12),
      side: BorderSide(color: selected ? accent.withOpacity(0.45) : Colors.transparent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }).toList());

  Widget _taskList() {
    final List<TaskItem> tasks = _visible;
    if (tasks.isEmpty) return const Center(child: Text('Nothing here yet', style: TextStyle(color: muted)));
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final TaskItem task = tasks[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.04))),
          child: Row(children: <Widget>[
            Checkbox(
              value: task.isCompleted,
              activeColor: const Color(0xFF50C7A5),
              checkColor: bg,
              side: const BorderSide(color: muted),
              onChanged: (bool value) => setState(() => task.isCompleted = value),
            ),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(task.title, style: TextStyle(color: task.isCompleted ? muted : Colors.white, fontSize: 14, fontWeight: FontWeight.w600, decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none)),
              const SizedBox(height: 7),
              Row(children: <Widget>[
                Text(task.category, style: const TextStyle(color: muted, fontSize: 11)),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 7), child: Icon(Icons.circle, color: Color(0xFF53627A), size: 4)),
                Text(task.dueLabel, style: const TextStyle(color: muted, fontSize: 11)),
              ]),
            ])),
            IconButton(tooltip: 'Delete task', icon: const Icon(Icons.delete_outline_rounded, color: muted), onPressed: () => setState(() => _tasks.remove(task))),
          ]),
        );
      },
    );
  }
}
