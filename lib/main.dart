import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF28A8D6), // สีพื้นหลังฟ้าตามภาพ
      ),
      home: const ExpenseApp(),
    );
  }
}

// Model สำหรับเก็บข้อมูลรายการ
class TransactionItem {
  final String name;
  final String date;
  final double price;

  TransactionItem({required this.name, required this.date, required this.price});
}

class ExpenseApp extends StatefulWidget {
  const ExpenseApp({super.key});

  @override
  State<ExpenseApp> createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {
  // หน้าปัจจุบัน (0=Home, 1=Edit/List, 2=Add)
  int _currentPage = 0;

  // ข้อมูลจำลอง (Mock Data)
  List<TransactionItem> transactions = [
    TransactionItem(name: "Food", date: "19/01/2026", price: 1),
    TransactionItem(name: "Bill", date: "19/01/2026", price: 3),
    TransactionItem(name: "Cafe", date: "19/01/2026", price: 1),
  ];

  // ตัวแปรสำหรับฟอร์มเพิ่มข้อมูล
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // ฟังก์ชันคำนวณยอดรวม (สมมติว่า Income Fix ไว้ที่ 15000 ตามภาพ)
  double get totalIncome => 15000;
  double get totalExpense => transactions.fold(0, (sum, item) => sum + item.price);
  double get totalBalance => totalIncome - totalExpense;

  // ฟังก์ชันเพิ่มรายการ
  void _addTransaction() {
    if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      setState(() {
        transactions.add(TransactionItem(
          name: _nameController.text,
          date: _dateController.text.isEmpty ? "19/01/2026" : _dateController.text,
          price: double.tryParse(_priceController.text) ?? 0,
        ));
        // เคลียร์ค่าและกลับไปหน้า List
        _nameController.clear();
        _dateController.clear();
        _priceController.clear();
        _currentPage = 1; // สลับไปหน้า List เพื่อดูผลลัพธ์
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- ส่วน Navigation Bar ด้านบน (ตามดีไซน์) ---
            Container(
              color: Colors.blue[700],
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavButton("Home", 0),
                  _buildNavButton("Edit", 1), // ใช้เป็นหน้า List
                  _buildNavButton("Add", 2),  // ใช้เป็นหน้า Add (ในภาพเขียน History แต่บริบทคือ Add)
                ],
              ),
            ),
            
            // --- ส่วนเนื้อหาที่จะเปลี่ยนไปตามหน้า ---
            Expanded(
              child: IndexedStack(
                index: _currentPage,
                children: [
                  _buildHomePage(), // หน้า 0
                  _buildListPage(), // หน้า 1
                  _buildAddPage(),  // หน้า 2
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget ปุ่มเมนูด้านบน
  Widget _buildNavButton(String title, int index) {
    bool isActive = _currentPage == index;
    return TextButton(
      onPressed: () => setState(() => _currentPage = index),
      style: TextButton.styleFrom(
        backgroundColor: isActive ? Colors.blue[900] : Colors.transparent,
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- หน้า 1: สรุปยอดเงิน (Home) ---
  Widget _buildHomePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBox("Total", totalBalance.toStringAsFixed(0), size: 180, fontSize: 32),
          const SizedBox(height: 20),
          _buildBox("Income: ${totalIncome.toStringAsFixed(0)}", "", size: 250, height: 60),
          const SizedBox(height: 10),
          _buildBox("Expense: ${totalExpense.toStringAsFixed(0)}", "", size: 250, height: 60),
        ],
      ),
    );
  }

  // --- หน้า 2: รายการ (Edit/List) ---
  Widget _buildListPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Search Bar
          Row(
            children: [
              const Text("Search:", style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.check_box, color: Colors.green, size: 30),
            ],
          ),
          const SizedBox(height: 20),
          // List Items
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final item = transactions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  color: Colors.grey[300],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(item.date, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      Text("${item.price.toStringAsFixed(0)} \$", style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- หน้า 3: เพิ่มรายการ (Add) ---
  Widget _buildAddPage() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel("Name"),
          _buildInputField(_nameController),
          const SizedBox(height: 15),
          _buildInputLabel("Date"),
          _buildInputField(_dateController, placeholder: "19/01/2026"),
          const SizedBox(height: 15),
          _buildInputLabel("Price"),
          _buildInputField(_priceController, isNumber: true),
          const SizedBox(height: 30),
          Center(
            child: SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                onPressed: _addTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                ),
                child: const Text("Add", style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers Widgets ---
  Widget _buildBox(String title, String value, {double size = 150, double height = 150, double fontSize = 18}) {
    return Container(
      width: size,
      height: height,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: fontSize)),
          if (value.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
          ]
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(label, style: const TextStyle(fontSize: 20, color: Colors.black)),
    );
  }

  Widget _buildInputField(TextEditingController controller, {bool isNumber = false, String? placeholder}) {
    return Container(
      color: Colors.grey[300],
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: placeholder,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }
}