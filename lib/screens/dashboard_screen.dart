import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _db = DatabaseService.instance;

  Map<String, double> _categoryTotals = {};
  double _totalExpense = 0;
  double _totalIncome = 0;
  List<ExpenseTransaction> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final totals = await _db.getCategoryTotals(startOfMonth, endOfMonth);
    final expense = await _db.getTotalByType(startOfMonth, endOfMonth, false);
    final income = await _db.getTotalByType(startOfMonth, endOfMonth, true);
    final recent = await _db.getAllTransactions();

    setState(() {
      _categoryTotals = totals;
      _totalExpense = expense;
      _totalIncome = income;
      _recentTransactions = recent.take(10).toList();
    });
  }

  String _formatMoney(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('داشبورد ماهانه')),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _summaryCard('هزینه این ماه', _totalExpense, Colors.red),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard('درآمد این ماه', _totalIncome, Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_categoryTotals.isNotEmpty) ...[
                const Text('هزینه به تفکیک دسته‌بندی',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: SfCircularChart(
                    legend: const Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
                    series: <PieSeries<MapEntry<String, double>, String>>[
                      PieSeries<MapEntry<String, double>, String>(
                        dataSource: _categoryTotals.entries.toList(),
                        xValueMapper: (entry, _) => entry.key,
                        yValueMapper: (entry, _) => entry.value,
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              const Text('تراکنش‌های اخیر',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_recentTransactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('هنوز تراکنشی ثبت نشده', style: TextStyle(color: Colors.grey))),
                )
              else
                ..._recentTransactions.map((tx) => Card(
                      child: ListTile(
                        leading: Icon(
                          tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: tx.isIncome ? Colors.green : Colors.red,
                        ),
                        title: Text(tx.category),
                        subtitle: Text(tx.description.isEmpty ? '—' : tx.description),
                        trailing: Text(
                          '${_formatMoney(tx.amount)} تومان',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: tx.isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, double value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              '${_formatMoney(value)} تومان',
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
