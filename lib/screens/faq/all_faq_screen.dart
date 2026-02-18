import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('userManual'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ManualStep(
              title: "1. What is this App?",
              description:
                  "This app allows you to manage devices, monitor sensors and communicate through chats and groups.",
            ),

            ManualStep(
              title: "2. How to Add Device",
              description:
                  "Go to Scan screen → Scan QR → Device will automatically connect.",
            ),

            ManualStep(
              title: "3. Device Appearance",
              description:
                  "After successful connection, device will appear on dashboard automatically.",
            ),

            ManualStep(
              title: "4. Change Theme",
              description: "Open Settings → Select Light or Dark mode.",
            ),

            ManualStep(
              title: "5. View Sensors Data",
              description:
                  "Open device details to monitor live sensor readings.",
            ),

            ManualStep(
              title: "6. Group Management",
              description:
                  "Create groups, add members and manage permissions easily.",
            ),
          ],
        ),
      ),
    );
  }
}

class ManualStep extends StatelessWidget {
  final String title;
  final String description;

  const ManualStep({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}
