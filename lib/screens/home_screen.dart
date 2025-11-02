import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/time_entry.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _storage = StorageService();
  List<TimeEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _storage.load();
    setState(() => _entries = items);
  }

  Future<void> _save() async {
    await _storage.save(_entries);
    setState(() {});
  }

  void _addEntry(TimeEntry e) {
    _entries.add(e);
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _StampPage(onSave: _addEntry, entries: _entries),
      _HoursPage(entries: _entries),
      _ExportPage(entries: _entries),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elektro-Technik Herold\nZeiterfassung', textAlign: TextAlign.center),
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer), label: 'Stempeln'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Stunden'),
          NavigationDestination(icon: Icon(Icons.picture_as_pdf), label: 'Export'),
        ],
      ),
    );
  }
}

class _StampPage extends StatefulWidget {
  final Function(TimeEntry) onSave;
  final List<TimeEntry> entries;
  const _StampPage({required this.onSave, required this.entries});

  @override
  State<_StampPage> createState() => _StampPageState();
}

class _StampPageState extends State<_StampPage> {
  DateTime date = DateTime.now();
  final startCtrl = TextEditingController(text: '07:00');
  final endCtrl = TextEditingController(text: '12:00');
  Activity activity = Activity.buero;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd. MMM. yyyy', 'de_DE');
    final todays = widget.entries.where((e) =>
      e.date.year==DateTime.now().year &&
      e.date.month==DateTime.now().month &&
      e.date.day==DateTime.now().day).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stempeln', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _Card(child: Column(children: [
            ListTile(
              title: const Text('Datum'),
              trailing: Text(df.format(date)),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  locale: const Locale('de'),
                );
                if (d != null) setState(() => date = d);
              },
            ),
            Row(children: [
              Expanded(child: _TimeField(controller: startCtrl, label: 'Start')),
              const SizedBox(width: 12),
              Expanded(child: _TimeField(controller: endCtrl, label: 'Ende')),
            ]),
            const SizedBox(height: 8),
            DropdownButtonFormField<Activity>(
              value: activity,
              items: Activity.values.map((a) => DropdownMenuItem(
                value: a, child: Text(activityLabel(a))
              )).toList(),
              onChanged: (v) => setState(()=> activity = v ?? Activity.buero),
              decoration: const InputDecoration(labelText: 'Tätigkeit', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onSave(TimeEntry(
                    date: date,
                    start: startCtrl.text,
                    end: endCtrl.text,
                    activity: activity,
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eintrag gespeichert')));
                },
                child: const Text('Speichern'),
              ),
            ),
          ])),
          const SizedBox(height: 16),
          Text('Heute', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...todays.map((e) => ListTile(
            leading: Text(e.start, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(activityLabel(e.activity)),
            subtitle: Text('Bis ${e.end}'),
          ))
        ],
      ),
    );
  }
}

class _HoursPage extends StatelessWidget {
  final List<TimeEntry> entries;
  const _HoursPage({required this.entries});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('E, dd.MM.yyyy','de_DE');
    final sorted = [...entries]..sort((a,b)=> a.date.compareTo(b.date));

    Duration total = Duration.zero;
    for (final e in sorted) { total += e.duration; }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Monatsübersicht', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...sorted.map((e) {
          final d = '${e.duration.inHours} h ${(e.duration.inMinutes%60).toString().padLeft(2,'0')} m';
          return ListTile(
            title: Text(df.format(e.date)),
            subtitle: Text(activityLabel(e.activity)),
            leading: Text(e.start),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(e.end), Text(d, style: const TextStyle(fontSize: 12))],
            ),
          );
        }),
        const Divider(),
        Align(
          alignment: Alignment.centerRight,
          child: Text('Summe: ${total.inHours} h ${(total.inMinutes%60).toString().padLeft(2,'0')} m',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}

class _ExportPage extends StatelessWidget {
  final List<TimeEntry> entries;
  const _ExportPage({required this.entries});

  @override
  Widget build(BuildContext context) {
    final pdfService = PdfService();
    DateTime selected = DateTime.now();

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Image.asset('assets/logo.png', height: 120),
              const SizedBox(height: 12),
              Text('Monatsübersicht exportieren', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Monat wählen'),
                subtitle: Text('${selected.month.toString().padLeft(2,'0')}.${selected.year}'),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: selected,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    locale: const Locale('de'),
                  );
                  if (d != null) setState(() => selected = d);
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final file = await pdfService.exportMonth(entries, selected);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('PDF gespeichert: ${file.path}'))
                      );
                    }
                  },
                  child: const Text('Export PDF'),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _TimeField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.access_time),
      ),
      keyboardType: TextInputType.datetime,
    );
  }
}
