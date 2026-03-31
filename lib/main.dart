import 'package:accountant/pages/Home_paged/home_page.dart';
import 'package:accountant/pages/data/customer.dart';

import 'package:accountant/pages/data/transaction.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  Hive .registerAdapter(CustomerAdapter());
  
  await Hive.openBox<Transaction>('tally_box');
  await Hive.openBox<Customer>('customer_box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Accountant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      home: HomePage(),
    );
  }
}
