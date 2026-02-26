import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String _selectedType = 'report_2'.tr;

  @override
  void dispose() {
    _detailController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('report_3'.tr)),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('report_1'.tr),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'report_4'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedType,
                        isExpanded: true,
                        items:  [
                          DropdownMenuItem(
                            value: 'report_2'.tr,
                            child: Text('report_2'.tr),
                          ),
                          DropdownMenuItem(
                            value: 'report_5'.tr,
                            child: Text('report_5'.tr),
                          ),
                          DropdownMenuItem(
                            value: 'report_6'.tr,
                            child: Text('report_6'.tr),
                          ),
                          DropdownMenuItem(
                            value: 'report_7'.tr,
                            child: Text('report_7'.tr),
                          ),
                          DropdownMenuItem(
                            value: 'report_8'.tr,
                            child: Text('report_8'.tr),
                          ),
                          DropdownMenuItem(
                            value: 'report_9'.tr,
                            child: Text('report_9'.tr),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedType = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'report_10'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _detailController,
                  maxLines: 5,
                  decoration:  InputDecoration(
                    hintText: 'report_11'.tr,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'report_12'.tr;
                    }
                    if (text.length < 10) {
                      return 'report_13'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'report_14'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contactController,
                  decoration:  InputDecoration(
                    hintText: 'report_15'.tr,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child:  Text('report_16'.tr),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'report_17'.tr,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
