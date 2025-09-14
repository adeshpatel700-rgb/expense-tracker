import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0A0A0B),
        primaryColor: Color(0xFF6C5CE7),
      ),
      home: ExpenseHomePage(),
    );
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      category: json['category'] ?? 'Food & Dining',
    );
  }
}

class ExpenseHomePage extends StatefulWidget {
  @override
  _ExpenseHomePageState createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  List<Expense> expenses = [];
  String selectedCurrency = 'USD';
  bool _isLoading = false;

  final categories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Travel',
    'Investment',
  ];

  final categoryIcons = {
    'Food & Dining': Icons.restaurant,
    'Transportation': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Bills & Utilities': Icons.receipt_long,
    'Healthcare': Icons.local_hospital,
    'Travel': Icons.flight,
    'Investment': Icons.trending_up,
  };

  final categoryGradients = {
    'Food & Dining': [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
    'Transportation': [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    'Shopping': [Color(0xFFFFD93D), Color(0xFFFF8C42)],
    'Entertainment': [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    'Bills & Utilities': [Color(0xFF00B894), Color(0xFF00CEC9)],
    'Healthcare': [Color(0xFFE17055), Color(0xFFE84393)],
    'Travel': [Color(0xFF0984E3), Color(0xFF74B9FF)],
    'Investment': [Color(0xFFD63031), Color(0xFFE84393)],
  };

  final currencies = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'INR': '₹',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CHF': 'Fr',
    'CNY': '¥',
    'KRW': '₩',
  };

  void _addExpense(Expense expense) {
    setState(() {
      expenses.insert(0, expense);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Expense added successfully'),
        backgroundColor: Color(0xFF6C5CE7),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteExpense(String expenseId) {
    setState(() {
      expenses.removeWhere((expense) => expense.id == expenseId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Expense deleted'),
        backgroundColor: Color(0xFF6C5CE7),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double get totalExpenses {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> get categoryTotals {
    Map<String, double> totals = {};
    for (var expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  double getMonthlyTotal() {
    DateTime now = DateTime.now();
    return expenses
        .where(
          (expense) =>
              expense.date.year == now.year && expense.date.month == now.month,
        )
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          ).createShader(bounds),
          child: Text(
            'Expense Tracker',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCurrency,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  currencies[selectedCurrency] ?? '\$',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.currency_exchange, color: Color(0xFF6C5CE7)),
            onPressed: () => showCurrencyDialog(),
          ),
        ],
      ),
      body: expenses.isEmpty ? buildEmptyState() : buildMainContent(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6C5CE7).withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _isLoading ? null : () => showAddExpenseDialog(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: _isLoading
              ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6C5CE7).withOpacity(0.2),
                  Color(0xFFA29BFE).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              size: 60,
              color: Color(0xFF6C5CE7),
            ),
          ),
          SizedBox(height: 32),
          Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start tracking your spending',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
          SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6C5CE7).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => showAddExpenseDialog(),
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Your First Expense',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMainContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          buildStatsCards(),
          SizedBox(height: 24),
          if (categoryTotals.isNotEmpty) buildChart(),
          SizedBox(height: 24),
          buildExpensesList(),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget buildStatsCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: buildGlassCard(
              'Total Spent',
              '${currencies[selectedCurrency] ?? '\$'}${totalExpenses.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: buildGlassCard(
              'This Month',
              '${currencies[selectedCurrency] ?? '\$'}${getMonthlyTotal().toStringAsFixed(2)}',
              Icons.calendar_month,
              [Color(0xFF00B894), Color(0xFF00CEC9)],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGlassCard(
    String title,
    String amount,
    IconData icon,
    List<Color> gradient,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChart() {
    if (categoryTotals.isEmpty || totalExpenses == 0) {
      return Container();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: getPieChartSections(),
                centerSpaceRadius: 60,
                sectionsSpace: 4,
                startDegreeOffset: -90,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExpensesList() {
    if (expenses.isEmpty) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recent Transactions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: expenses.length,
          itemBuilder: (context, index) => buildExpenseItem(expenses[index]),
        ),
      ],
    );
  }

  Widget buildExpenseItem(Expense expense) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Dismissible(
        key: Key(expense.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) => _deleteExpense(expense.id),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.red, Colors.redAccent]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 24),
              child: Icon(Icons.delete, color: Colors.white, size: 28),
            ),
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: categoryGradients[expense.category] ??
                        [Colors.grey, Colors.grey],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryIcons[expense.category] ?? Icons.help,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${expense.category} • ${DateFormat('MMM dd').format(expense.date)}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Text(
                '-${currencies[selectedCurrency] ?? '\$'}${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> getPieChartSections() {
    if (categoryTotals.isEmpty || totalExpenses == 0) {
      return [];
    }

    List<Color> colors = [
      Color(0xFFFF6B6B),
      Color(0xFF4ECDC4),
      Color(0xFFFFD93D),
      Color(0xFF6C5CE7),
      Color(0xFF00B894),
      Color(0xFFE17055),
      Color(0xFF0984E3),
      Color(0xFFD63031),
    ];

    int index = 0;
    return categoryTotals.entries.map((entry) {
      final percentage = (entry.value / totalExpenses) * 100;
      final color = colors[index % colors.length];
      index++;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: color,
        radius: 70,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  void showAddExpenseDialog() {
    String title = '';
    double amount = 0;
    String selectedCategory = categories[0];
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1A1A1D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Add Expense',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildTextField('Title', (value) => title = value),
                    SizedBox(height: 16),
                    buildTextField(
                      'Amount',
                      (value) => amount = double.tryParse(value) ?? 0,
                      isNumber: true,
                    ),
                    SizedBox(height: 20),
                    buildCategorySelector(selectedCategory, (category) {
                      setDialogState(() => selectedCategory = category);
                    }),
                    SizedBox(height: 20),
                    buildDateSelector(selectedDate, (date) {
                      setDialogState(() => selectedDate = date);
                    }),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  if (title.isNotEmpty && amount > 0) {
                    final expense = Expense(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      amount: amount,
                      date: selectedDate,
                      category: selectedCategory,
                    );
                    _addExpense(expense);
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Add Expense',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTextField(
    String label,
    Function(String) onChanged, {
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextField(
        onChanged: onChanged,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget buildCategorySelector(String selected, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = category == selected;
            return GestureDetector(
              onTap: () => onChanged(category),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: categoryGradients[category] ??
                              [Colors.grey, Colors.grey],
                        )
                      : null,
                  color: isSelected ? null : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      categoryIcons[category] ?? Icons.help,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      category,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildDateSelector(DateTime selected, Function(DateTime) onChanged) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selected,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Color(0xFF6C5CE7),
                  surface: Color(0xFF1A1A1D),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMM dd, yyyy').format(selected),
              style: TextStyle(color: Colors.white),
            ),
            Icon(Icons.calendar_today, color: Color(0xFF6C5CE7)),
          ],
        ),
      ),
    );
  }

  void showCurrencyDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1A1A1D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.currency_exchange,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Select Currency',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Container(
            width: 300,
            height: 400,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies.keys.elementAt(index);
                final symbol = currencies[currency]!;
                final isSelected = currency == selectedCurrency;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCurrency = currency;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.2),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(0xFF6C5CE7).withOpacity(0.3),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          symbol,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          currency,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Done', style: TextStyle(color: Color(0xFF6C5CE7))),
            ),
          ],
        );
      },
    );
  }
}
