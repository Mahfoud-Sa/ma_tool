import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:system_info2/system_info2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, String> systemInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getSystemInfo();
  }

  Future<void> _getSystemInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final Map<String, String> info = {};

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        info['Operating System'] = 'Android ${androidInfo.version.release}';
        info['Device'] = '${androidInfo.brand} ${androidInfo.model}';
        info['SDK Version'] = 'API ${androidInfo.version.sdkInt}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        info['Operating System'] = 'iOS ${iosInfo.systemVersion}';
        info['Device'] = '${iosInfo.name} ${iosInfo.model}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        info['Operating System'] = 'Windows ${windowsInfo.displayVersion}';
        info['Device'] = windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfoPlugin.macOsInfo;
        info['Operating System'] = 'macOS ${macInfo.osRelease}';
        info['Device'] = macInfo.computerName;
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
        info['Operating System'] = '${linuxInfo.name} ${linuxInfo.version}';
        info['Device'] = linuxInfo.prettyName;
      }

      // Add RAM information
      info['Total RAM'] = '${(SysInfo.getTotalPhysicalMemory() / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
      info['Available RAM'] = '${(SysInfo.getFreePhysicalMemory() / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';

      // Add CPU information
      info['CPU Cores'] = SysInfo.cores.length.toString();
      info['CPU Architecture'] = Platform.operatingSystem;

    } catch (e) {
      info['Error'] = 'Unable to get system information: $e';
    }

    setState(() {
      systemInfo = info;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("System Information"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text(
                    'System Details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ...systemInfo.entries.map((entry) => _buildInfoCard(entry.key, entry.value)),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '$title:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}