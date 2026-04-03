import 'package:accountant/pages/Home_paged/user_pages.dart';
import 'package:accountant/pages/data/customer.dart';
import 'package:accountant/pages/data/transaction.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class UserDetails extends StatefulWidget {
  final Transaction transaction;
  final Customer transaction2;
  const UserDetails({
    super.key,
    required this.transaction,
    required this.transaction2,
  });

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  @override
  Widget build(BuildContext context) {
    final data = widget.transaction;
    final data2 = widget.transaction2;
    final isCredite = data.isCradit;
    final isCredite2 = data2.isCradit;

    double balance = data2.amounta - data2.paidamount;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 250,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Get.offAll(() => UserPages(transaction: data));
              },
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: isCredite ? Colors.green : Colors.red,
              backgroundImage:
                  data.image != null ? MemoryImage(data.image!) : null,
              child:
                  data.image == null
                      ? Text(
                        data.title.isNotEmpty ? data.title[0] : "?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            SizedBox(width: 10),
            Text(
              " ${data.title}  বিবরণ",
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              data.title,

              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              textDirection: TextDirection.ltr,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder.all(width: 1, color: Colors.black),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "প্যণের নাম",
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text("নোট", style: TextStyle(fontSize: 10)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text("মোট টাকা", style: TextStyle(fontSize: 10)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "টাকা দিয়েছেন",
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          balance == 0
                              ? "পরিশোধ 0.0"
                              : (balance > 0 ? "মোট পাবো " : "মোট পাবে "),
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
