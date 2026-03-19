import 'dart:typed_data';

import 'package:accountant/pages/Home_paged/user_pages.dart';
import 'package:accountant/pages/data/customer.dart';
import 'package:accountant/pages/data/transaction.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = Hive.box<Transaction>('tally_box');

  Uint8List? _selectedImageBytes; // ইমেজ ডাটা রাখার জন্য

  Future<void> _pickImage(StateSetter setModalState) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    ); // কোয়ালিটি

    if (image != null) {
      Uint8List bytes = await image.readAsBytes();
      setModalState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  void addTransaction(
    String title,
    double amount,
    double paidamount,
    bool isCredit,
    int phonenumber,
    String productname,
    Uint8List? image,
  ) {
    final newentery = Transaction(
      title: title,
      amount: amount,
      paidamount: paidamount,
      phonenumber: phonenumber,
      productname: productname,
      isCradit: isCredit,
      date: DateTime.now(),
      image: image,
    );
    box.add(newentery);
    _selectedImageBytes = null;
  }

  void _showForm(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    bool isCredit = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Center(
                  child: Text(
                    "নতুন কাস্টমার তৈরি করুন",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),

                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 13),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "কাস্টমারের নাম",
                          fillColor: Colors.white54,
                          hintStyle: TextStyle(color: Colors.black),
                          prefixIcon: Icon(Icons.person, color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 13),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: "ফোন নাম্বার",
                          fillColor: Colors.white54,
                          hintStyle: TextStyle(color: Colors.black),
                          prefixIcon: Icon(
                            Icons.phone_outlined,
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
                      SizedBox(height: 16),

                      _selectedImageBytes != null
                          ? Image.memory(
                            _selectedImageBytes!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          )
                          : Text("কোনো ছবি বাছাই করা হয়নি"),
                      TextButton.icon(
                        onPressed: () => _pickImage(setModalState),
                        icon: Icon(Icons.image),
                        label: Text("ছবি যোগ করুন"),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        onPressed: () {
                          if (nameController.text.isNotEmpty &&
                              phoneController.text.isNotEmpty) {
                            addTransaction(
                              nameController.text,
                              0,
                              0,
                              isCredit,
                              int.parse(phoneController.text),
                              '',
                              _selectedImageBytes,
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          "হিসাব রাখুন",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('হিসাবরক্ষক'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Transaction> box, _) {
          final Box<Customer> customerBox = Hive.box<Customer>('customer_box');
          double totalIn = 0;
          double totalOut = 0;
          for (var customer in customerBox.values) {
            var balance = customer.amounta - customer.paidamount;
            if (balance > 0) {
              totalIn += balance;
            } else if (balance < 0) {
              totalOut += balance.abs();
            }
          }
          double netBalance = totalIn - totalOut;

          final transactions = box.values.toList().reversed.toList();

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
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      summaryCard(
                        "মোট দেবো",
                        "৳ ${netBalance > 0 ? 0 : netBalance.abs().toStringAsFixed(0)}",
                        Colors.black,
                      ),
                      SizedBox(width: 5),
                      summaryCard(
                        "মোট পাবো",
                        "৳ ${netBalance < 0 ? 0 : netBalance.abs().toStringAsFixed(0)}",
                        Colors.red,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(10),

                  child: Text(
                    "কাস্টমার লিস্ট",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                // লিস্ট ভিউ
                Expanded(
                  child:
                      transactions.isEmpty
                          ? Center(child: Text("কোনো হিসাব নেই!"))
                          : ListView.separated(
                            separatorBuilder:
                                (context, index) => SizedBox(height: 8),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final item = transactions[index];

                              // ক্যালকুলেশন
                              double balance = item.amount - item.paidamount;
                              double displayAmount = balance.abs();

                              String statusLabel = "";
                              Color statusColor = Colors.black;

                              if (item.isCradit) {
                                statusLabel =
                                    balance >= 0 ? "দেনা বাকি" : "বেশি দিয়েছি";
                                statusColor =
                                    balance >= 0 ? Colors.green : Colors.blue;
                              } else {
                                statusLabel =
                                    balance >= 0 ? "পাওনা বাকি" : "বেশি দিয়েছে";
                                statusColor =
                                    balance >= 0 ? Colors.red : Colors.orange;
                              }
                              return GestureDetector(
                                onTap: () {
                                  Get.offAll(
                                    () => UserPages(transaction: item),
                                  );
                                },
                                child: Card(
                                  elevation: 5,
                                  shadowColor: Colors.blue,
                                  color: Colors.teal.shade50,

                                  margin: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: Color.fromARGB(98, 3, 6, 8),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor:
                                              item.isCradit
                                                  ? Colors.green
                                                  : Colors.red,
                                          backgroundImage:
                                              item.image != null
                                                  ? MemoryImage(item.image!)
                                                  : null,
                                          child:
                                              item.image == null
                                                  ? Text(
                                                    item.title.isNotEmpty
                                                        ? item.title[0]
                                                            .toUpperCase()
                                                        : '?',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                  : null,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Name: ${item.title}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "${item.date.day}/${item.date.month}/${item.date.year}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacer(),

                                        Text(
                                          "Price ${displayAmount.toStringAsFixed(0)}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                item.isCradit
                                                    ? Colors.black
                                                    : Colors.red,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget summaryCard(var title, var amount, Color color) {
    return Expanded(
      child: Card(
        elevation: 10,
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
                amount,
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
}
