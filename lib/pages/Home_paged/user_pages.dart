import 'package:accountant/pages/Home_paged/home_page.dart';
import 'package:accountant/pages/Home_paged/user_details.dart';
import 'package:accountant/pages/data/customer.dart';
import 'package:accountant/pages/data/transaction.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserPages extends StatefulWidget {
  final Transaction transaction;

  const UserPages({super.key, required this.transaction});

  @override
  State<UserPages> createState() => _UserPagesState();
}

class _UserPagesState extends State<UserPages> {
  final box = Hive.box<Customer>('customer_box');

  void additem(
    String title,
    String productname,
    double totalamount,
    double paidamountin,
    bool isCredita,
  ) {
    final newentery = Customer(
      title: title,
      productname: productname,
      amounta: totalamount,
      paidamount: paidamountin,
      isCradit: isCredita,
      date: DateTime.now(),
    );
    box.add(newentery);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.transaction;

    final isCredite = data.isCradit;

    double taka = 0.0;
    bool isCradit = false;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,

        leadingWidth: 250,
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  addTransaction(context, data);
                },
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
              " ${data.title}",
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      ),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Customer> box, _) {
          double totalpabo = 0;
          double totaldibo = 0;

          final customerTransactions =
              box.values
                  .where((item) => item.title == widget.transaction.title)
                  .toList();
          for (var item in customerTransactions) {
            totalpabo += item.paidamount;
            totaldibo += item.amounta;
          }
          double totaltaka = totaldibo - totalpabo;

          return Container(
            color: Colors.white,
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      summarycard(
                        "মোট লেনদেন",
                        totaldibo.toString(),
                        Colors.black,
                      ),
                      summarycard(
                        "মোট দিয়েছে",
                        totalpabo.toString(),
                        Colors.black,
                      ),
                      summarycard(
                        totaltaka == 0
                            ? "সমান"
                            : (totaltaka > 0 ? "মোট পাবো" : "মোট পাবে"),
                        totaltaka.abs().toString(),
                        totaltaka == 0
                            ? Colors.black
                            : (totaltaka > 0 ? Colors.red : Colors.black),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    "মোবাইল নাম্বার +880${data.phonenumber.toString()}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                Expanded(
                  child:
                      customerTransactions.isEmpty
                          ? Center(child: Text("কোনো লেনদেন পাওয়া যায়নি"))
                          : ListView.separated(
                            separatorBuilder:
                                (context, index) => SizedBox(height: 8),
                            itemCount: customerTransactions.length,
                            itemBuilder: (context, index) {
                              final alldata = customerTransactions[index];
                              double balance =
                                  alldata.amounta - alldata.paidamount;
                              double balancea = balance.abs();
                              return GestureDetector(
                                onTap: () {
                                  Get.offAll(
                                    () => UserDetails(
                                      transaction: data,
                                      transaction2: alldata,
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 1,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      "পণ্যের নাম ${alldata.productname}",
                                    ),
                                    subtitle: Text(
                                      "${alldata.date.day}/${alldata.date.month}/${alldata.date.year}",
                                    ),
                                    trailing: Column(
                                      children: [
                                        Text("মোট টাকা ${alldata.amounta}"),
                                        Text(
                                          "মোট দিয়েছে ${alldata.paidamount}",
                                        ),
                                        Text(
                                          balance == 0
                                              ? "পরিশোধ 0.0"
                                              : (balance > 0
                                                  ? "মোট পাবো ${balancea}"
                                                  : "মোট পাবে ${balancea}"),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                balance == 0
                                                    ? Colors.black
                                                    : (balance > 0
                                                        ? Colors.red
                                                        : Colors.blue),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // delete condition
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

                  // ২. Customer Box থেকে ওই কাস্টমারের সব এন্ট্রি খুঁজে বের করা
                  final keysToDelete =
                      box.keys.where((key) {
                        final customer = box.get(key);
                        return customer?.title == data.title;
                      }).toList();

                  if (keysToDelete.isNotEmpty) {
                    await box.deleteAll(keysToDelete);
                  }

                  // ৪. ইউজারকে হোম পেজে পাঠিয়ে দেওয়া
                  Get.offAll(() => HomePage());

                  // ৫. একটি কনফার্মেশন মেসেজ দেখানো
                  Get.snackbar(
                    "সফলভাবে মুছে ফেলা হয়েছে",
                    "${data.title} এর ডাটাবেস এখন খালি।",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                    margin: EdgeInsets.all(10),
                    duration: Duration(seconds: 2),
                  );
                },
                child: Text("হ্যাঁ", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
    );
  }

  void addTransaction(BuildContext context, Transaction data) {
    bool localisCredit = false;
    final productController = TextEditingController();
    final noteController = TextEditingController();
    final amountController = TextEditingController();

    final paidamountController = TextEditingController();
    String transactionType = "pabo";

    showDialog(
      context: context,
      builder: (context) {
        {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return AlertDialog(
                title: Center(child: Text("নতুন লেনদেন তৈরি করুন")),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10),
                      TextField(
                        controller: productController,

                        decoration: InputDecoration(
                          labelText: "পণ্যের নাম",
                          labelStyle: TextStyle(color: Colors.black),
                          prefixIcon: Icon(
                            Icons.production_quantity_limits,
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Note
                      TextField(
                        controller: noteController,

                        decoration: InputDecoration(
                          labelText: "নোট লিখুন",
                          labelStyle: TextStyle(color: Colors.black),
                          prefixIcon: Icon(
                            Icons.note_add_outlined,
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      TextField(
                        controller: amountController,

                        decoration: InputDecoration(
                          labelText: "মোট টাকা",
                          labelStyle: TextStyle(color: Colors.black),
                          prefixIcon: Icon(
                            Icons.attach_money_outlined,
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),

                      // Amount
                      TextField(
                        controller: paidamountController,

                        decoration: InputDecoration(
                          labelText: "টাকা দিয়েছেন",
                          labelStyle: TextStyle(color: Colors.black),
                          prefixIcon: Icon(
                            Icons.attach_money_outlined,
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: 'pabo',
                            label: Text(
                              'টাকা পাবো',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          ButtonSegment(
                            value: 'dibo',
                            label: Text(
                              'টাকা পাবে',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          ButtonSegment(
                            value: 'paid',
                            label: Text(
                              'পরিশোধ',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                        selected: {transactionType},
                        onSelectionChanged: (newSelection) {
                          setModalState(() {
                            transactionType = newSelection.first;
                          });
                        },
                        style: ButtonStyle(
                          // ব্যাকগ্রাউন্ড কালার পরিবর্তন
                          backgroundColor: WidgetStateProperty.resolveWith<
                            Color
                          >((states) {
                            if (states.contains(WidgetState.selected)) {
                              if (transactionType == 'pabo') return Colors.red;
                              if (transactionType == 'dibo')
                                return Colors.green;
                              if (transactionType == 'paid') return Colors.blue;
                            }
                            return Colors.white; // ডিফল্ট সাদা
                          }),

                          // টেক্সট এবং আইকন কালার (ForegroundColor)
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.white; // সিলেক্টেড অবস্থায় সাদা
                                }
                                return Colors.black; // নরমাল অবস্থায় কালো
                              }),

                          side: WidgetStateProperty.resolveWith<BorderSide>((
                            states,
                          ) {
                            Color borderColor = Colors.grey;
                            if (states.contains(WidgetState.selected)) {
                              if (transactionType == 'pabo')
                                borderColor = Colors.red;
                              if (transactionType == 'dibo')
                                borderColor = Colors.black;
                              if (transactionType == 'paid')
                                borderColor = Colors.blue;
                            }
                            return BorderSide(color: borderColor);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text("বাতিল"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String productName = productController.text.trim();
                      String note = noteController.text.trim();

                      double totalAmount =
                          double.tryParse(amountController.text) ?? 0.0;
                      double paidAmount =
                          double.tryParse(paidamountController.text) ?? 0.0;

                      if (productName.isEmpty ||
                          amountController.text.isEmpty) {
                        Get.snackbar(
                          "ভুল হয়েছে",
                          "দয়া করে পণ্যের নাম এবং মোট টাকা লিখুন",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      if (transactionType == 'pabo') {
                        localisCredit = false;
                      } else if (transactionType == 'dibo') {
                        localisCredit = true;
                      } else if (transactionType == 'paid') {
                        localisCredit = false;
                        paidAmount = totalAmount;
                      }
                      additem(
                        data.title,
                        productName,
                        totalAmount,
                        paidAmount,
                        localisCredit,
                      );

                      // 5. Close the dialog
                      Get.back();

                      // 6. Optional: Show success message
                      Get.snackbar(
                        "সফল",
                        "নতুন লেনদেন যোগ করা হয়েছে",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    child: const Text("যোগ করুন"),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }
}

Widget summarycard(var title, var amount, Color color) {
  return Expanded(
    child: Card(
      elevation: 5,
      shadowColor: Colors.blue,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              "৳ $amount",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
