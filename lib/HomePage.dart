import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CallLogEntry> callLogs = [];
  late SharedPreferences prefs;
  late DateTime lastOpenedTime;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _checkAndLoadCallLogs();
  }

  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    lastOpenedTime = DateTime.now();
    prefs.setString('lastOpenedTime', lastOpenedTime.toIso8601String());
  }

  Future<void> _checkAndLoadCallLogs() async {
    var status = await Permission.phone.request();
    if (status.isGranted) {
      _loadCallLogs();
    } else {
        }
  }

  Future<void> _loadCallLogs() async {
    String? lastOpenedTimeString = prefs.getString('lastOpenedTime');
    DateTime lastOpenedTime = DateTime.parse(lastOpenedTimeString ?? '');

    Iterable<CallLogEntry> entries = await CallLog.get();

    List<CallLogEntry> newCallLogs = entries
        .where((entry) {
          DateTime entryTime = DateTime.fromMillisecondsSinceEpoch(entry.timestamp! * 1000);
          return entryTime.isAfter(lastOpenedTime);
        })
        .toList();

    setState(() {
      callLogs = newCallLogs;
    });

    prefs.setString('lastOpenedTime', DateTime.now().toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Logs'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the Call Logs!',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Your Call Logs:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: callLogs.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        callLogs[index].name ?? '',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        callLogs[index].number ?? 'No Number',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Text(
                        callLogs[index].callType.toString(),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontStyle: FontStyle.italic,
                          color: _getColorForCallType(callLogs[index].callType),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForCallType(CallType? callType) {
    switch (callType) {
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return Colors.blue;
      case CallType.missed:
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
