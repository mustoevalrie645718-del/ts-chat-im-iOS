import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/bean/invoice.dart';
import 'package:mytencloud_flupro/stylesutil/SharedPreferenceUtil.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../tools/my_colors.dart';

class AddInvoicePage extends StatefulWidget {
  @override
  _AddInvoicePageState createState() => _AddInvoicePageState();
}

class _AddInvoicePageState extends State<AddInvoicePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _typeController = TextEditingController();
  final _numberController = TextEditingController();
  final _companyController = TextEditingController();
  final _taxNumberController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveInvoice() async {
    if (_formKey.currentState!.validate()) {
      final invoice = Invoice(
        id: Uuid().v4(),
        title: _titleController.text,
        amount: _amountController.text,
        date: _dateController.text,
        type: _typeController.text,
        number: _numberController.text,
        company: _companyController.text,
        taxNumber: _taxNumberController.text,
      );

      final String invoicesJson = await SharedPreferenceUtil.getString('invoices') ?? '[]';
      final List<dynamic> decoded = json.decode(invoicesJson);
      final List<Invoice> invoices = decoded.map((item) => Invoice.fromJson(item)).toList();
      
      invoices.add(invoice);
      final String encoded = json.encode(invoices.map((e) => e.toJson()).toList());
      await SharedPreferenceUtil.setString('invoices', encoded);

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color_main2,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        backgroundColor: MyColors.color_main2,
        title: const Text('添加发票',style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: buildInputDecoration("发票抬头"),
              validator: (value) {
                if (value!.isEmpty) {
                  return '请输入发票抬头';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: buildInputDecoration("金额"),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return '请输入金额';
                }
                if (double.tryParse(value) == null) {
                  return '请输入有效的金额';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: '开票日期',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _typeController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: '发票类型',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return '请输入发票类型';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _numberController,
              decoration: InputDecoration( filled: true,
                fillColor: Colors.white,
                labelText: '发票号码',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return '请输入发票号码';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _companyController,
              decoration: InputDecoration( filled: true,
                fillColor: Colors.white,
                labelText: '开票单位',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return '请输入开票单位';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _taxNumberController,
              decoration: InputDecoration( filled: true,
                fillColor: Colors.white,
                labelText: '税号',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return '请输入税号';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveInvoice,
              child: Text('保存',style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.color_main3,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration(str) {
    return InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: str,
              border: OutlineInputBorder(),
            );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _typeController.dispose();
    _numberController.dispose();
    _companyController.dispose();
    _taxNumberController.dispose();
    super.dispose();
  }
} 