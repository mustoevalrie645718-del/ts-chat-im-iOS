import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/bean/invoice.dart';
import 'package:mytencloud_flupro/viewpages/add_invoice_page.dart';
import 'package:mytencloud_flupro/stylesutil/SharedPreferenceUtil.dart';
import 'dart:convert';

import 'package:mytencloud_flupro/widget/empty_view.dart';

import '../tools/my_colors.dart';

class InvoiceListPage extends StatefulWidget {
  @override
  _InvoiceListPageState createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  List<Invoice> _invoices = [];

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final String invoicesJson = await SharedPreferenceUtil.getString('invoices') ?? '[]';
    final List<dynamic> decoded = json.decode(invoicesJson);
    setState(() {
      _invoices = decoded.map((item) => Invoice.fromJson(item)).toList();
    });
  }

  Future<void> _saveInvoices() async {
    final String encoded = json.encode(_invoices.map((e) => e.toJson()).toList());
    await SharedPreferenceUtil.setString('invoices', encoded);
  }

  void _deleteInvoice(int index) {
    setState(() {
      _invoices.removeAt(index);
    });
    _saveInvoices();
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
        title: const Text('发票助手',style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
      ),
      body: _invoices.isEmpty
          ? Center(
              child: EmptyView(title:
              '暂无发票记录'
              ),
            )
          : ListView.builder(
              itemCount: _invoices.length,
              itemBuilder: (context, index) {
                final invoice = _invoices[index];
                return Dismissible(
                  key: Key(invoice.id!),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteInvoice(index);
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(invoice.title!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('金额: ¥${invoice.amount}'),
                          Text('日期: ${invoice.date}'),
                          Text('发票号码: ${invoice.number}'),
                        ],
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.color_main2,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddInvoicePage()),
          );
          if (result == true) {
            _loadInvoices();
          }
        },
        child: Icon(Icons.add),
        tooltip: '添加发票',
      ),
    );
  }
} 