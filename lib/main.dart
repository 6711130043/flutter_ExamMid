import 'package:flutter/material.dart';

void main() {
  runApp(const RootApp());
}

// ---------------------------------------------------------
// 1. Root & Theme Management
// ---------------------------------------------------------
class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _showOnboarding = true;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void finishOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker Pro',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF28A8D6),
        cardColor: Colors.grey[300],
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      themeMode: _themeMode,
      home: _showOnboarding
          ? OnboardingScreen(onFinish: finishOnboarding)
          : ExpenseApp(onThemeChanged: toggleTheme, isDarkMode: _themeMode == ThemeMode.dark),
    );
  }
}

// ---------------------------------------------------------
// 2. Onboarding Screen
// ---------------------------------------------------------
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Welcome to MoneyApp",
      "desc": "Track your income and expenses easily.",
      "icon": "💰"
    },
    {
      "title": "Income & Expense",
      "desc": "Now you can add both income and expense transactions.",
      "icon": "📊"
    },
    {
      "title": "Manage Wisely",
      "desc": "Swipe left to delete, Swipe right to edit.",
      "icon": "✨"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_pages[index]['icon']!, style: const TextStyle(fontSize: 100)),
                      const SizedBox(height: 30),
                      Text(
                        _pages[index]['title']!,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          _pages[index]['desc']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.blue : Colors.grey[300],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: BouncingButton(
                onTap: () {
                  if (_currentPage == _pages.length - 1) {
                    widget.onFinish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? "Get Started" : "Next",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. Main App Logic
// ---------------------------------------------------------

// เพิ่ม Enum ประเภทรายการ
enum TransactionType { income, expense }

class TransactionItem {
  String id;
  String name;
  String date;
  double price;
  TransactionType type; // เพิ่ม field type

  TransactionItem({
    required this.id,
    required this.name,
    required this.date,
    required this.price,
    required this.type,
  });
}

class ExpenseApp extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const ExpenseApp({super.key, required this.onThemeChanged, required this.isDarkMode});

  @override
  State<ExpenseApp> createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {
  int _currentPage = 0;

  // Data
  List<TransactionItem> allTransactions = [
    // ตัวอย่างข้อมูลเริ่มต้น
    TransactionItem(id: '1', name: "Salary", date: "01/01/2026", price: 25000, type: TransactionType.income),
    TransactionItem(id: '2', name: "Food", date: "19/01/2026", price: 100, type: TransactionType.expense),
    TransactionItem(id: '3', name: "Bill", date: "19/01/2026", price: 300, type: TransactionType.expense),
  ];
  List<TransactionItem> filteredTransactions = [];

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // ตัวแปรเก็บสถานะการเลือกประเภท (หน้า Add)
  TransactionType _selectedType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    filteredTransactions = allTransactions;
  }

  void _runFilter(String keyword) {
    List<TransactionItem> results = [];
    if (keyword.isEmpty) {
      results = allTransactions;
    } else {
      results = allTransactions
          .where((item) => item.name.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      filteredTransactions = results;
    });
  }

  // Logic: Calculate Totals (แก้ไขสูตรใหม่)
  double get totalIncome => allTransactions
      .where((item) => item.type == TransactionType.income)
      .fold(0, (sum, item) => sum + item.price);

  double get totalExpense => allTransactions
      .where((item) => item.type == TransactionType.expense)
      .fold(0, (sum, item) => sum + item.price);

  double get totalBalance => totalIncome - totalExpense;

  void _addTransaction() {
    if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      setState(() {
        allTransactions.add(TransactionItem(
          id: DateTime.now().toString(),
          name: _nameController.text,
          date: _dateController.text.isEmpty ? "19/01/2026" : _dateController.text,
          price: double.tryParse(_priceController.text) ?? 0,
          type: _selectedType, // บันทึกตามประเภทที่เลือก
        ));
        _nameController.clear();
        _dateController.clear();
        _priceController.clear();
        _selectedType = TransactionType.expense; // Reset กลับเป็นค่าใช้จ่าย
        _runFilter(_searchController.text);
        _currentPage = 1;
      });
    }
  }

  void _editTransaction(TransactionItem item) {
    setState(() {
      _nameController.text = item.name;
      _dateController.text = item.date;
      _priceController.text = item.price.toStringAsFixed(0);
      _selectedType = item.type; // ดึงประเภทเดิมมาแสดง

      allTransactions.removeWhere((element) => element.id == item.id);
      _runFilter(_searchController.text);
      
      _currentPage = 2;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Editing... Make changes and press Add")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Color navColor = widget.isDarkMode ? Colors.grey[900]! : Colors.blue[700]!;
    Color cardColor = Theme.of(context).cardColor;
    Color textColor = Theme.of(context).textTheme.bodyMedium!.color!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Navigation Bar ---
            Container(
              color: navColor,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavButton("Home", 0),
                  _buildNavButton("Edit", 1),
                  _buildNavButton("Add", 2),
                ],
              ),
            ),

            // --- Content ---
            Expanded(
              child: IndexedStack(
                index: _currentPage,
                children: [
                  // PAGE 0: HOME
                  Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // แสดงยอดคงเหลือ Total
                            _buildBox("Total", totalBalance.toStringAsFixed(0), 
                              size: 180, 
                              fontSize: 32, 
                              color: cardColor, 
                              textColor: totalBalance >= 0 ? textColor : Colors.red
                            ),
                            const SizedBox(height: 20),
                            // แสดงยอด Income (คำนวณจริง)
                            _buildBox("Income: ${totalIncome.toStringAsFixed(0)}", "", 
                              size: 250, height: 60, color: cardColor, textColor: Colors.green
                            ),
                            const SizedBox(height: 10),
                            // แสดงยอด Expense
                            _buildBox("Expense: ${totalExpense.toStringAsFixed(0)}", "", 
                              size: 250, height: 60, color: cardColor, textColor: Colors.red
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Row(
                          children: [
                            Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: textColor),
                            Switch(
                              value: widget.isDarkMode,
                              onChanged: widget.onThemeChanged,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  // PAGE 1: LIST / SEARCH
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text("Search:", style: TextStyle(fontSize: 18, color: textColor)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _runFilter,
                                  style: TextStyle(color: textColor),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    suffixIcon: Icon(Icons.search, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: filteredTransactions.isEmpty 
                          ? Center(child: Text("No items found", style: TextStyle(color: textColor)))
                          : ListView.builder(
                            itemCount: filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final item = filteredTransactions[index];
                              // กำหนดสีตัวเลขตามประเภท
                              Color priceColor = item.type == TransactionType.income ? Colors.green : Colors.red;
                              String prefix = item.type == TransactionType.income ? "+ " : "- ";
                              
                              return BouncingButton(
                                onTap: (){},
                                child: Dismissible(
                                  key: Key(item.id),
                                  background: Container(
                                    color: Colors.green,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: const Icon(Icons.edit, color: Colors.white),
                                  ),
                                  secondaryBackground: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  confirmDismiss: (direction) async {
                                    if (direction == DismissDirection.startToEnd) {
                                      _editTransaction(item);
                                      return false; 
                                    } else {
                                      setState(() {
                                        allTransactions.removeWhere((e) => e.id == item.id);
                                        _runFilter(_searchController.text);
                                      });
                                      return true;
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                                            Text(item.date, style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7))),
                                          ],
                                        ),
                                        Text("$prefix${item.price.toStringAsFixed(0)} \$", 
                                          style: TextStyle(fontSize: 18, color: priceColor, fontWeight: FontWeight.bold)
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
                  ),

                  // PAGE 2: ADD
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type Selector
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildTypeButton("Income", TransactionType.income, Colors.green),
                                _buildTypeButton("Expense", TransactionType.expense, Colors.red),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildInputLabel("Name", textColor),
                        _buildInputField(_nameController, cardColor, textColor),
                        const SizedBox(height: 15),
                        _buildInputLabel("Date", textColor),
                        _buildInputField(_dateController, cardColor, textColor, placeholder: "19/01/2026"),
                        const SizedBox(height: 15),
                        _buildInputLabel("Price", textColor),
                        _buildInputField(_priceController, cardColor, textColor, isNumber: true),
                        const SizedBox(height: 30),
                        Center(
                          child: BouncingButton(
                            onTap: _addTransaction,
                            child: Container(
                              width: 150,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _selectedType == TransactionType.income ? Colors.green : Colors.redAccent, // เปลี่ยนสีปุ่มตามประเภท
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                              ),
                              alignment: Alignment.center,
                              child: const Text("Save", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget สร้างปุ่มเลือก Income/Expense
  Widget _buildTypeButton(String title, TransactionType type, Color activeColor) {
    bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(String title, int index) {
    bool isActive = _currentPage == index;
    return BouncingButton(
      onTap: () => setState(() => _currentPage = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBox(String title, String value, {double size = 150, double height = 150, double fontSize = 18, required Color color, required Color textColor}) {
    return Container(
      width: size,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: fontSize, color: textColor)),
          if (value.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: textColor)),
          ]
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(label, style: TextStyle(fontSize: 20, color: color)),
    );
  }

  Widget _buildInputField(TextEditingController controller, Color bgColor, Color textColor, {bool isNumber = false, String? placeholder}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
    );
  }
}

// Animation Button Class (เหมือนเดิม)
class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const BouncingButton({super.key, required this.child, required this.onTap});

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}