import 'dart:typed_data';

import 'package:accountant/pages/Home_paged/user_pages.dart';
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
    ); // কোয়ালিটি কমিয়ে রাখা ভালো

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
    bool isCredit,
    int phonenumber,
    String productname,
    Uint8List? image,
  ) {
    final newentery = Transaction(
      title: title,
      amount: amount,
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
    final productController = TextEditingController();
    final amountController = TextEditingController();

    bool isCredit = true;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Center(
                  child: Text(
                    "নতুন লেনদেন যোগ করুন",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),

                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: "ফোন নাম্বার",
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
                      SizedBox(height: 16),
                      TextField(
                        controller: productController,
                        decoration: InputDecoration(
                          labelText: "পণ্যের নাম",
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
                      SizedBox(height: 16),
                      TextField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: "বিলের পরিমান",
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
                      SizedBox(height: 10),
                      SwitchListTile(
                        title: Text(
                          isCredit ? "আমার কাছে পাবে" : "আমি টাকা পাবো",
                        ),
                        value: isCredit,
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                        onChanged: (value) {
                          setModalState(() {
                            isCredit = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
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
                              amountController.text.isNotEmpty) {
                            addTransaction(
                              nameController.text,
                              double.tryParse(amountController.text) ?? 0.0,
                              isCredit,
                              int.tryParse(phoneController.text) ?? 0,
                              productController.text,
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
      appBar: AppBar(title: Text('হিসাবরক্ষক'), centerTitle: true),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Transaction> box, _) {
          // হিসাব নিকেশ
          double totalIn = 0;
          double totalOut = 0;
          for (var item in box.values) {
            if (item.isCradit)
              totalIn += item.amount;
            else
              totalOut += item.amount;
          }

          final transactions = box.values.toList().reversed.toList();

          return Column(
            children: [
              // সামারি কার্ড
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    summaryCard("মোট দেবো", "৳ $totalIn", Colors.green),
                    summaryCard("মোট পাবো", "৳ $totalOut", Colors.red),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "কাস্টমার লিস্ট",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              // লিস্ট ভিউ
              Expanded(
                child:
                    transactions.isEmpty
                        ? Center(child: Text("কোনো হিসাব নেই!"))
                        : ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final item = transactions[index];
                            return GestureDetector(
                              onTap: () {
                                Get.offAll(() =>UserPages(transaction: item,));
                              },
                              child: Card(
                                elevation: 5,
                                shadowColor: Colors.blue,
                                color: Colors.teal.shade50,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: Color.fromARGB(99, 33, 149, 243),
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
                                                ? Icon(
                                                  item.isCradit
                                                      ? Icons
                                                          .arrow_upward_outlined
                                                      : Icons
                                                          .arrow_downward_outlined,
                                                  size: 30,
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
                                              "${item.date.day}-${item.date.month}-${item.date.year}",
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
                                        "Price ${item.amount}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              item.isCradit
                                                  ? Colors.green
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget summaryCard(var title, var amount, Color color) {
    return Card(
      elevation: 10,
      shadowColor: Colors.blue,
      child: Container(
        padding: EdgeInsets.all(30),

        decoration: BoxDecoration(
          color: const Color.fromARGB(125, 255, 193, 7),
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
    );
  }
}
