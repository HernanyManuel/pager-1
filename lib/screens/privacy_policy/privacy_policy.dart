// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PrivacyPolicyScreen extends StatefulWidget {
//   const PrivacyPolicyScreen({super.key});

//   @override
//   State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
// }

// class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
//   bool isAccepted = false;
//   @override
//   void initState() {
//     super.initState();
//     _loadPrivacyStatus();
//   }

//   Future<void> _loadPrivacyStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isAccepted = prefs.getBool('privacyAccepted') ?? false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("privacyPolicy".tr())),
//       body: Column(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('privacy_policy.line1'.tr()),
//               SizedBox(height: 10),

//               Text('privacy_policy.point1'.tr()),
//               Text('privacy_policy.point2'.tr()),
//               Text('privacy_policy.point3'.tr()),
//               Text('privacy_policy.point4'.tr()),

//               SizedBox(height: 12),
//               Text('privacy_policy.footer'.tr()),
//             ],
//           ),
//           Divider(height: 1),
//           // ✅ Checkbox + Agree Button
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: isAccepted,
//                       onChanged: (value) {
//                         setState(() {
//                           isAccepted = value ?? false;
//                         });
//                       },
//                     ),
//                     Expanded(child: Text("agreePrivacyPolicy".tr())),
//                   ],
//                 ),

//                 const SizedBox(height: 10),

//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: isAccepted
//                         ? () {
//                             Navigator.pop(context, true);
//                           }
//                         : null,
//                     child: Text("iAgree".tr()),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool isAccepted = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacyStatus();
  }

  Future<void> _loadPrivacyStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAccepted = prefs.getBool('privacyAccepted') ?? false;
    });
  }

  Future<void> _savePrivacyStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacyAccepted', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("privacyPolicyTitle".tr()), // ✅ updated
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "privacyPolicyLine1".tr(), // ✅ updated
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 15),

                  Text("privacyPolicyPoint1".tr()),
                  Text("privacyPolicyPoint2".tr()),
                  Text("privacyPolicyPoint3".tr()),
                  Text("privacyPolicyPoint4".tr()),

                  const SizedBox(height: 15),

                  Text(
                    "privacyPolicyFooter".tr(), // ✅ updated
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isAccepted,
                      onChanged: (value) {
                        setState(() {
                          isAccepted = value ?? false;
                        });
                      },
                    ),
                    Expanded(child: Text("agreePrivacyPolicy".tr())),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isAccepted
                        ? () async {
                            await _savePrivacyStatus(); // ✅ save status
                            Navigator.pop(context, true);
                          }
                        : null,
                    child: Text("iAgree".tr()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
