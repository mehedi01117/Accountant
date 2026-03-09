import 'package:accountant/pages/Home_paged/home_page.dart';
import 'package:accountant/pages/data/transaction.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';

class UserPages extends StatefulWidget {
  final Transaction transaction;
  const UserPages({super.key, required this.transaction});

  @override
  State<UserPages> createState() => _UserPagesState();
}

class _UserPagesState extends State<UserPages> {
  @override
  Widget build(BuildContext context) {
    final data = widget.transaction;
    return Scaffold(
      appBar: AppBar(
        elevation: 15,
        leadingWidth: 200,
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_outlined, color: Colors.black),
                    Text("add", style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  updateTransaction(context, data);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.black),
                    Text("edit", style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  deleteTransaction(context, data);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outlined, color: Colors.red),
                    Text("delete", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],

        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Get.offAll(() => HomePage());
              },
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: data.isCradit ? Colors.green : Colors.red,
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
          Container(
            color: data.isCradit ? Colors.green : Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "লেনদেনের বিবরণ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 35),
                Expanded(
                  child: Text(
                    "কেনা",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),

                Expanded(
                  child: Text(
                    "পরিশোধ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "পণ্যর নাম : ${data.productname}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "+880${data.phonenumber.toString()}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Date : ${data.date.day}-${data.date.month}-${data.date.year}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 35),
                Expanded(
                  child: Text(
                    data.amount.toString(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    data.paidamount.toString(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void deleteTransaction(BuildContext context, Transaction data) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Center(
              child: Text(
                "লেনদেনটি কি মুছে ফেলতে চান?",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),

            content: Text(
              "${data.title} এর এই লেনদেনটি কি চিরতরে মুছে ফেলতে চান?",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text("না", style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                onPressed: () async {
                  await data.delete();
                  Get.back();
                  Get.back();

                  Get.snackbar(
                    "ডিলিট হয়েছে",
                    "লেনদেনটি সফলভাবে মুছে ফেলা হয়েছে",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                  );
                },
                child: Text("হ্যাঁ", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
    );
  }

  void updateTransaction(BuildContext context, Transaction data) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Center(
              child: Text(
                "লেনদেনটি কি পরিবর্তন করতে চান?",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),

            content: Text(
              "${data.title} এর এই লেনদেনটি কি পরিবর্তন করতে চান?",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            actions: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: "${data.amount}",
                  hintStyle: TextStyle(color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(
                    Icons.attach_money_outlined,
                    color: Colors.black,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  TextEditingController amountController = TextEditingController();
  TextEditingController paidamountController = TextEditingController();
}
