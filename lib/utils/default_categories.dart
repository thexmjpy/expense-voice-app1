import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

List<ExpenseCategory> defaultCategories() {
  return [
    ExpenseCategory(
      name: 'خوراک',
      icon: 'restaurant',
      colorValue: Colors.orange.value,
      keywords: ['ناهار', 'شام', 'صبحانه', 'رستوران', 'غذا', 'خوراک', 'فست فود', 'کافه', 'قهوه'],
    ),
    ExpenseCategory(
      name: 'خواربار',
      icon: 'shopping_basket',
      colorValue: Colors.brown.value,
      keywords: ['نون', 'نان', 'لبنیات', 'میوه', 'سبزی', 'خرید خونه', 'سوپرمارکت', 'بقالی'],
    ),
    ExpenseCategory(
      name: 'حمل و نقل',
      icon: 'directions_car',
      colorValue: Colors.blue.value,
      keywords: ['تاکسی', 'اسنپ', 'تپسی', 'بنزین', 'مترو', 'اتوبوس', 'پارکینگ', 'کرایه'],
    ),
    ExpenseCategory(
      name: 'قبض و اجاره',
      icon: 'receipt_long',
      colorValue: Colors.red.value,
      keywords: ['قبض', 'اجاره', 'برق', 'آب', 'گاز', 'اینترنت', 'شارژ', 'موبایل'],
    ),
    ExpenseCategory(
      name: 'پوشاک',
      icon: 'checkroom',
      colorValue: Colors.purple.value,
      keywords: ['لباس', 'کفش', 'پوشاک', 'مانتو', 'شلوار'],
    ),
    ExpenseCategory(
      name: 'سلامت',
      icon: 'medical_services',
      colorValue: Colors.green.value,
      keywords: ['دارو', 'دکتر', 'پزشک', 'دندونپزشک', 'داروخانه', 'درمان', 'ویزیت'],
    ),
    ExpenseCategory(
      name: 'تفریح',
      icon: 'sports_esports',
      colorValue: Colors.pink.value,
      keywords: ['سینما', 'تفریح', 'بازی', 'کنسرت', 'مسافرت', 'سفر'],
    ),
    ExpenseCategory(
      name: 'درآمد',
      icon: 'attach_money',
      colorValue: Colors.teal.value,
      keywords: ['حقوق', 'درآمد', 'دستمزد', 'پروژه', 'فریلنس', 'واریز'],
    ),
    ExpenseCategory(
      name: 'متفرقه',
      icon: 'category',
      colorValue: Colors.grey.value,
      keywords: [],
    ),
  ];
}
