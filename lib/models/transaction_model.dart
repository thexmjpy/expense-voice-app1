class ExpenseTransaction {
  final int? id;
  final double amount;
  final String category;
  final String description;
  final String rawVoiceText;
  final DateTime date;
  final bool isIncome;

  ExpenseTransaction({
    this.id,
    required this.amount,
    required this.category,
    required this.description,
    this.rawVoiceText = '',
    required this.date,
    this.isIncome = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'raw_voice_text': rawVoiceText,
      'date': date.toIso8601String(),
      'is_income': isIncome ? 1 : 0,
    };
  }

  factory ExpenseTransaction.fromMap(Map<String, dynamic> map) {
    return ExpenseTransaction(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      description: map['description'] as String,
      rawVoiceText: map['raw_voice_text'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      isIncome: (map['is_income'] as int) == 1,
    );
  }

  ExpenseTransaction copyWith({
    int? id,
    double? amount,
    String? category,
    String? description,
    String? rawVoiceText,
    DateTime? date,
    bool? isIncome,
  }) {
    return ExpenseTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      rawVoiceText: rawVoiceText ?? this.rawVoiceText,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}

class ExpenseCategory {
  final int? id;
  final String name;
  final String icon;
  final int colorValue;
  final List<String> keywords;

  ExpenseCategory({
    this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.keywords,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color_value': colorValue,
      'keywords': keywords.join(','),
    };
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      colorValue: map['color_value'] as int,
      keywords: (map['keywords'] as String).split(',').where((e) => e.isNotEmpty).toList(),
    );
  }
}
