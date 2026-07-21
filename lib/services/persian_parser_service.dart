import '../models/transaction_model.dart';

class ParsedExpense {
  final double? amount;
  final String? categoryName;
  final bool isIncome;
  final String cleanedDescription;

  ParsedExpense({
    this.amount,
    this.categoryName,
    this.isIncome = false,
    required this.cleanedDescription,
  });
}

class PersianParserService {
  static final Map<String, int> _numberWords = {
    'صفر': 0, 'یک': 1, 'دو': 2, 'سه': 3, 'چهار': 4, 'پنج': 5,
    'شش': 6, 'هفت': 7, 'هشت': 8, 'نه': 9, 'ده': 10,
    'یازده': 11, 'دوازده': 12, 'سیزده': 13, 'چهارده': 14, 'پانزده': 15,
    'شانزده': 16, 'هفده': 17, 'هجده': 18, 'نوزده': 19, 'بیست': 20,
    'سی': 30, 'چهل': 40, 'پنجاه': 50, 'شصت': 60, 'هفتاد': 70,
    'هشتاد': 80, 'نود': 90, 'صد': 100, 'دویست': 200, 'سیصد': 300,
    'چهارصد': 400, 'پانصد': 500, 'ششصد': 600, 'هفتصد': 700,
    'هشتصد': 800, 'نهصد': 900,
  };

  static final Map<String, int> _multipliers = {
    'هزار': 1000,
    'میلیون': 1000000,
    'تومان': 1,
    'تومن': 1,
  };

  static String _normalizeDigits(String input) {
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = input;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(persian[i], '$i');
      result = result.replaceAll(arabic[i], '$i');
    }
    return result;
  }

  static int? _parseWordNumber(String text) {
    final words = text.split(RegExp(r'\s+و\s+|\s+'));
    int total = 0;
    int current = 0;
    bool found = false;

    for (final w in words) {
      final clean = w.trim();
      if (_numberWords.containsKey(clean)) {
        current += _numberWords[clean]!;
        found = true;
      } else if (_multipliers.containsKey(clean)) {
        final mult = _multipliers[clean]!;
        if (mult == 1) continue;
        if (current == 0) current = 1;
        total += current * mult;
        current = 0;
        found = true;
      }
    }
    total += current;
    return found ? total : null;
  }

  static double? extractAmount(String rawText) {
    final text = _normalizeDigits(rawText);

    final digitUnitPattern = RegExp(r'(\d+(?:[.,]\d+)?)\s*(هزار|میلیون)?\s*(تومان|تومن)?');
    for (final match in digitUnitPattern.allMatches(text)) {
      final numStr = match.group(1);
      if (numStr == null) continue;
      var value = double.tryParse(numStr.replaceAll(',', '')) ?? 0;
      if (value == 0) continue;
      final unit = match.group(2);
      if (unit == 'هزار') value *= 1000;
      if (unit == 'میلیون') value *= 1000000;
      return value;
    }

    final wordValue = _parseWordNumber(text);
    if (wordValue != null && wordValue > 0) {
      return wordValue.toDouble();
    }

    return null;
  }

  static String? detectCategory(String rawText, List<ExpenseCategory> categories) {
    final text = rawText.trim();
    for (final cat in categories) {
      for (final keyword in cat.keywords) {
        if (text.contains(keyword)) {
          return cat.name;
        }
      }
    }
    return null;
  }

  static bool detectIsIncome(String rawText) {
    const incomeWords = ['حقوق', 'درآمد', 'دستمزد', 'واریز شد', 'گرفتم', 'دریافت کردم'];
    return incomeWords.any((w) => rawText.contains(w));
  }

  static String buildDescription(String rawText) {
    return rawText.trim();
  }

  static ParsedExpense parse(String rawText, List<ExpenseCategory> categories) {
    final amount = extractAmount(rawText);
    final category = detectCategory(rawText, categories);
    final isIncome = detectIsIncome(rawText);
    final description = buildDescription(rawText);

    return ParsedExpense(
      amount: amount,
      categoryName: category,
      isIncome: isIncome,
      cleanedDescription: description,
    );
  }
}
