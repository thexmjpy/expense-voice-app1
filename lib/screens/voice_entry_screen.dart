import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/speech_service.dart';
import '../services/database_service.dart';
import '../services/persian_parser_service.dart';

class VoiceEntryScreen extends StatefulWidget {
  const VoiceEntryScreen({super.key});

  @override
  State<VoiceEntryScreen> createState() => _VoiceEntryScreenState();
}

class _VoiceEntryScreenState extends State<VoiceEntryScreen> {
  final SpeechService _speechService = SpeechService();
  final DatabaseService _db = DatabaseService.instance;

  bool _isListening = false;
  String _recognizedText = '';
  ParsedExpense? _parsedResult;
  List<ExpenseCategory> _categories = [];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _selectedCategory;
  bool _isIncome = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _db.getAllCategories();
    setState(() => _categories = cats);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      setState(() => _isListening = false);
      return;
    }

    final granted = await _speechService.requestMicPermission();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('دسترسی به میکروفون لازم است')),
        );
      }
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _parsedResult = null;
    });

    await _speechService.startListening(
      onResult: (text, isFinal) {
        setState(() => _recognizedText = text);
        if (isFinal) {
          _processRecognizedText(text);
        }
      },
    );
  }

  void _processRecognizedText(String text) {
    if (text.trim().isEmpty) return;
    final parsed = PersianParserService.parse(text, _categories);

    setState(() {
      _isListening = false;
      _parsedResult = parsed;
      _amountController.text = parsed.amount?.toStringAsFixed(0) ?? '';
      _descController.text = parsed.cleanedDescription;
      _selectedCategory = parsed.categoryName ?? _categories.last.name;
      _isIncome = parsed.isIncome;
    });
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مبلغ معتبر وارد کنید')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('دسته‌بندی را انتخاب کنید')),
      );
      return;
    }

    final tx = ExpenseTransaction(
      amount: amount,
      category: _selectedCategory!,
      description: _descController.text.trim(),
      rawVoiceText: _recognizedText,
      date: DateTime.now(),
      isIncome: _isIncome,
    );

    await _db.insertTransaction(tx);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ثبت شد ✓')),
      );
      setState(() {
        _recognizedText = '';
        _parsedResult = null;
        _amountController.clear();
        _descController.clear();
        _selectedCategory = null;
        _isIncome = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('ثبت هزینه با صدا')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _toggleListening,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening ? Colors.red : Theme.of(context).primaryColor,
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isListening ? 'در حال شنیدن... صحبت کنید' : 'برای ضبط صدا لمس کنید',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              if (_recognizedText.isNotEmpty) ...[
                Card(
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('متن تشخیص داده شده:',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(_recognizedText, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (_parsedResult != null) ...[
                _buildEditableForm(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTransaction,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    child: const Text('تایید و ذخیره', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],

              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _showManualEntryDialog(),
                child: const Text('یا به صورت دستی وارد کنید'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('هزینه'),
                selected: !_isIncome,
                onSelected: (_) => setState(() => _isIncome = false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('درآمد'),
                selected: _isIncome,
                onSelected: (_) => setState(() => _isIncome = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'مبلغ (تومان)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'دسته‌بندی',
            border: OutlineInputBorder(),
          ),
          items: _categories
              .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
              .toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descController,
          decoration: const InputDecoration(
            labelText: 'توضیحات',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  void _showManualEntryDialog() {
    setState(() {
      _parsedResult = ParsedExpense(cleanedDescription: '');
      _selectedCategory = _categories.isNotEmpty ? _categories.first.name : null;
    });
  }
}
